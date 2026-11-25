import mongoose, { Types } from 'mongoose';
import {
  AiCalibrationInput,
  AiStudyProgram,
  AiTopicProgramOverviewResponse,
  AiTopicSubjectSummary,
  StudentStream,
  StudyStatus,
  ToggleTopicUnitMasteryRequest,
  TopicModuleItem,
  TopicUnitMasteryResponse,
  UpdateTopicProgressRequest,
} from '@acedex/contracts';
import { UserModel } from '../users/user.model';
import {
  IProgressUnitSubdoc,
  ITopicModuleProgressSubdoc,
  StudentProgressModel,
} from '../progress/models/student-progress.model';
import { EUEE_SUBJECTS } from '../curriculum/curriculum-seeder.service';
import { UnitModel } from '../curriculum/models/unit.model';
import { TopicModuleModel, ITopicModuleDocument } from './models/topic-module.model';
import { ProgressService } from '../progress/progress.service';
import { ACE_COINS_CONFIG, EconomyService } from '../economy/economy.service';
import { AdConfigModel } from '../ads/models/ad-config.model';
import { AdSessionModel, IAdSessionDocument } from '../ads/models/ad-session.model';
import { GeminiPlannerService } from './gemini-planner.service';
import {
  ForbiddenError,
  NotFoundError,
  TooManyRequestsError,
} from '../../common/errors/app-error';

export class TopicsService {
  /**
   * Computes current Ethiopia (EAT, UTC+3) calendar day key and next midnight reset timestamp
   */
  private static getEatDayInfo(now = new Date()): {
    todayKey: string;
    nextResetAt: string;
  } {
    const eatOffsetMs = 3 * 60 * 60 * 1000;
    const eatNow = new Date(now.getTime() + eatOffsetMs);
    const todayKey = eatNow.toISOString().slice(0, 10);
    const nextMidnightUtcMs =
      Date.UTC(
        eatNow.getUTCFullYear(),
        eatNow.getUTCMonth(),
        eatNow.getUTCDate() + 1
      ) - eatOffsetMs;

    return {
      todayKey,
      nextResetAt: new Date(nextMidnightUtcMs).toISOString(),
    };
  }

  /**
   * Resolves the set of curriculum unitCodes that currently have Quick Notes
   * (either in UnitModel.hasQuickNotes / UnitModel.quickNotes or acedex.quick_notes).
   */
  private static async getQuickNotesUnitCodeSet(
    candidateUnitCodes?: string[]
  ): Promise<Set<string>> {
    const unitFilter: Record<string, any> = {
      $or: [{ hasQuickNotes: true }, { quickNotes: { $ne: null } }],
    };
    const quickNotesFilter: Record<string, any> = {};

    if (candidateUnitCodes && candidateUnitCodes.length > 0) {
      unitFilter.code = { $in: candidateUnitCodes };
      quickNotesFilter.unitCode = { $in: candidateUnitCodes };
    } else if (candidateUnitCodes && candidateUnitCodes.length === 0) {
      return new Set<string>();
    }

    const [unitsWithNotes, quickNoteDocs] = await Promise.all([
      UnitModel.find(unitFilter).select('code').lean(),
      mongoose.connection
        .useDb('acedex')
        .collection('quick_notes')
        .find(quickNotesFilter, { projection: { unitCode: 1 } })
        .toArray(),
    ]);

    const codes = new Set<string>();
    for (const u of unitsWithNotes) {
      if (u.code) codes.add(String(u.code).toUpperCase().trim());
    }
    for (const doc of quickNoteDocs) {
      if (doc.unitCode) codes.add(String(doc.unitCode).toUpperCase().trim());
    }
    return codes;
  }

  /**
   * Computes real module progress percentage (0%..100%) from completed steps or full completion flag
   */
  private static calculateModuleProgressPct(
    mod: ITopicModuleDocument,
    rec?: ITopicModuleProgressSubdoc
  ): number {
    if (!rec) return 0;
    if (rec.isCompleted) return 100;
    const totalSteps = mod.sequence?.length || 0;
    if (totalSteps === 0) return 0;
    return Math.min(99, Math.round((rec.completedSteps.length / totalSteps) * 100));
  }

  private static async buildSubjectSummaries(
    stream: StudentStream,
    allModules: ITopicModuleDocument[],
    topicProgressMap: Map<string, ITopicModuleProgressSubdoc>,
    weakSubjectCodes: string[] = []
  ): Promise<AiTopicSubjectSummary[]> {
    const streamSubjects = EUEE_SUBJECTS.filter(
      (s) => s.streamCategory === 'common' || s.streamCategory === stream
    );
    const weakUpper = weakSubjectCodes.map((c) => c.toUpperCase().trim());

    const modulesBySubj = new Map<string, ITopicModuleDocument[]>();
    for (const m of allModules) {
      const arr = modulesBySubj.get(m.subjectCode) || [];
      arr.push(m);
      modulesBySubj.set(m.subjectCode, arr);
    }

    const summaries: AiTopicSubjectSummary[] = streamSubjects.map((subj) => {
      const mods = modulesBySubj.get(subj.code) || [];
      const totalModules = mods.length;
      const completedModules = mods.filter(
        (m) => topicProgressMap.get(m.moduleId)?.isCompleted === true
      ).length;

      let masteryPercentage = 0;
      if (totalModules > 0) {
        const sumPct = mods.reduce(
          (acc, m) => acc + this.calculateModuleProgressPct(m, topicProgressMap.get(m.moduleId)),
          0
        );
        masteryPercentage = Math.round(sumPct / totalModules);
      }

      const rankIdx = weakUpper.indexOf(subj.code);
      return {
        subjectCode: subj.code,
        subjectName: subj.name,
        totalModules,
        completedModules,
        masteryPercentage,
        priorityRank: rankIdx !== -1 ? rankIdx + 1 : null,
        hasTopicBank: totalModules > 0,
      };
    });

    // Place priority subjects (#1, #2, #3) first, followed by subjects with available topic banks
    return summaries.sort((a, b) => {
      if (a.priorityRank && b.priorityRank) return a.priorityRank - b.priorityRank;
      if (a.priorityRank) return -1;
      if (b.priorityRank) return 1;
      if (a.hasTopicBank !== b.hasTopicBank) return a.hasTopicBank ? -1 : 1;
      return 0;
    });
  }

  /**
   * Returns the student's saved AI study program (or null) plus real 0%-baseline subject mastery summaries
   */
  public static async getProgramOverview(
    userId: string
  ): Promise<AiTopicProgramOverviewResponse> {
    const userObjectId = new Types.ObjectId(userId);
    const user = await UserModel.findById(userObjectId).lean();
    if (!user) throw new NotFoundError('User account not found');

    const stream: StudentStream = user.stream === 'social' ? 'social' : 'natural';
    const progress = await StudentProgressModel.findOne({ userId: userObjectId }).lean();

    const allModules = await TopicModuleModel.find({
      streamCategory: { $in: ['common', stream] },
    })
      .sort({ subjectCode: 1, moduleNumber: 1 })
      .lean();

    const topicProgressMap = new Map<string, ITopicModuleProgressSubdoc>();
    for (const tm of progress?.topicModules || []) {
      topicProgressMap.set(tm.moduleId, tm);
    }

    const savedProgram = (progress?.aiStudyProgram as AiStudyProgram | undefined) || null;
    const weakCodes = savedProgram?.calibration?.weakSubjectCodes || [];

    const { todayKey, nextResetAt } = this.getEatDayInfo();
    const existingGenDate =
      savedProgram?.generatedDate ||
      (savedProgram?.generatedAt
        ? this.getEatDayInfo(new Date(savedProgram.generatedAt)).todayKey
        : undefined);
    const canGenerateToday = existingGenDate !== todayKey;

    const adConfig = await AdConfigModel.findOne({ singletonId: 'global_ad_config' }).lean();
    const requiresAd = adConfig ? adConfig.isAdsEnabled : true;

    const subjectSummaries = await this.buildSubjectSummaries(
      stream,
      allModules as unknown as ITopicModuleDocument[],
      topicProgressMap,
      weakCodes
    );

    return {
      hasProgram: Boolean(savedProgram),
      canGenerateToday,
      requiresAd,
      nextGenerationAt: canGenerateToday ? null : nextResetAt,
      program: savedProgram,
      subjectSummaries,
    };
  }

  /**
   * Calibrates and persists a personalized cross-grade AI study program using Gemini + Topic Bank.
   * Requires 1 claimed rewarded ad (when ads enabled) and is limited to once per calendar day.
   */
  public static async generateAndSaveProgram(
    userId: string,
    calibration: AiCalibrationInput
  ): Promise<AiTopicProgramOverviewResponse> {
    const userObjectId = new Types.ObjectId(userId);
    const user = await UserModel.findById(userObjectId).lean();
    if (!user) throw new NotFoundError('User account not found');

    const stream: StudentStream = user.stream === 'social' ? 'social' : 'natural';
    const grade = user.grade || 12;

    let progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress) {
      progress = new StudentProgressModel({
        userId: userObjectId,
        units: [],
        subjectMastery: [],
        topicModules: [],
      });
    }

    const { todayKey, nextResetAt } = this.getEatDayInfo();
    const existingProgram = progress.aiStudyProgram as AiStudyProgram | undefined;
    const existingGenDate =
      existingProgram?.generatedDate ||
      (existingProgram?.generatedAt
        ? this.getEatDayInfo(new Date(existingProgram.generatedAt)).todayKey
        : undefined);

    const usedCoinPass =
      calibration.useCoinPass === true &&
      (await EconomyService.consumeAiPlanPass(userObjectId));

    if (calibration.useCoinPass === true && !usedCoinPass) {
      throw new ForbiddenError(
        'No AI Study Program Pass available. Unlock one for 100 Ace Coins in your Wallet or watch 1 rewarded ad.',
        'AI_PLAN_PASS_REQUIRED'
      );
    }

    if (existingProgram && existingGenDate === todayKey && !usedCoinPass) {
      throw new TooManyRequestsError(
        'You can generate your AI study program once per day to prevent token abuse. Please try again tomorrow or use an AI Study Pass (100 AC).',
        'DAILY_PLAN_LIMIT_REACHED',
        { nextGenerationAt: nextResetAt }
      );
    }

    const adConfig = await AdConfigModel.findOne({ singletonId: 'global_ad_config' }).lean();
    const requiresAd = adConfig ? adConfig.isAdsEnabled : true;
    let verifiedAdSession: IAdSessionDocument | null = null;

    if (requiresAd && !usedCoinPass) {
      if (!calibration.adSessionId) {
        throw new ForbiddenError(
          'Please watch 1 rewarded ad (or spend a 100 AC AI Study Pass) to unlock AI study program generation.',
          'AD_REQUIRED_FOR_AI_PLAN'
        );
      }
      verifiedAdSession = await AdSessionModel.findOne({
        adSessionId: calibration.adSessionId,
        userId: userObjectId,
        rewardType: 'ai_study_plan',
        status: 'claimed',
        usedForAiPlan: { $ne: true },
      });
      if (!verifiedAdSession) {
        throw new ForbiddenError(
          'Valid completed rewarded ad required to generate your AI study program.',
          'AD_REQUIRED_FOR_AI_PLAN'
        );
      }
    }

    // Re-read fresh progress if a coin pass was atomically decremented
    if (usedCoinPass) {
      progress = (await StudentProgressModel.findOne({ userId: userObjectId })) || progress;
    }

    const allModules = await TopicModuleModel.find({
      streamCategory: { $in: ['common', stream] },
    })
      .sort({ subjectCode: 1, moduleNumber: 1 })
      .lean();

    const completedUnitCodes = (progress.units || [])
      .filter((u) => u.isStudyCompleted || u.passed)
      .map((u) => u.unitCode);

    const weakAssessmentUnits = (progress.units || [])
      .filter((u) => u.attemptsCount > 0 && u.bestPercentage < 65)
      .map((u) => ({ unitCode: u.unitCode, bestPercentage: u.bestPercentage }));

    const quickNotesUnitSet = await this.getQuickNotesUnitCodeSet();
    const quickNotesUnitCodes = Array.from(quickNotesUnitSet);

    const completedModuleIds = (progress.topicModules || [])
      .filter((tm) => tm.isCompleted)
      .map((tm) => tm.moduleId);

    const { adSessionId: _discardAdId, useCoinPass: _discardCoinPass, ...cleanCalibration } =
      calibration;
    const normalizedCalibration: AiCalibrationInput = {
      ...cleanCalibration,
      weakSubjectCodes: cleanCalibration.weakSubjectCodes.map((c) => c.toUpperCase().trim()),
    };

    const program = await GeminiPlannerService.generateStudyProgram({
      stream,
      grade,
      calibration: normalizedCalibration,
      modules: allModules as unknown as ITopicModuleDocument[],
      completedUnitCodes,
      weakAssessmentUnits,
      quickNotesUnitCodes,
      completedModuleIds,
    });
    program.generatedDate = todayKey;

    progress.aiStudyProgram = program;
    progress.markModified('aiStudyProgram');
    await progress.save();

    if (verifiedAdSession) {
      verifiedAdSession.usedForAiPlan = true;
      await verifiedAdSession.save();
    }

    const topicProgressMap = new Map<string, ITopicModuleProgressSubdoc>();
    for (const tm of progress.topicModules || []) {
      topicProgressMap.set(tm.moduleId, tm);
    }

    const subjectSummaries = await this.buildSubjectSummaries(
      stream,
      allModules as unknown as ITopicModuleDocument[],
      topicProgressMap,
      normalizedCalibration.weakSubjectCodes
    );

    return {
      hasProgram: true,
      canGenerateToday: false,
      requiresAd,
      nextGenerationAt: nextResetAt,
      program,
      subjectSummaries,
    };
  }

  /**
   * Lists all cross-grade topic modules for a subject, decorated with student progress
   * and whether ACEDEX Quick Notes exist for each referenced textbook unit
   */
  public static async getSubjectModules(
    userId: string,
    subjectCode: string
  ): Promise<TopicModuleItem[]> {
    const normalizedInput = subjectCode.trim();
    const matchedSubject = EUEE_SUBJECTS.find(
      (s) =>
        s.code === normalizedInput.toUpperCase() ||
        s.slug === normalizedInput.toLowerCase() ||
        s.name.toLowerCase() === normalizedInput.toLowerCase()
    );
    const cleanCode = matchedSubject
      ? matchedSubject.code
      : normalizedInput.toUpperCase();
    const userObjectId = new Types.ObjectId(userId);

    const modules = await TopicModuleModel.find({ subjectCode: cleanCode })
      .sort({ moduleNumber: 1 })
      .lean();

    const progress = await StudentProgressModel.findOne({ userId: userObjectId }).lean();
    const progressMap = new Map<string, ITopicModuleProgressSubdoc>();
    for (const tm of progress?.topicModules || []) {
      progressMap.set(tm.moduleId, tm);
    }

    const unitProgressMap = new Map<string, IProgressUnitSubdoc>();
    for (const u of progress?.units || []) {
      if (u.unitCode) {
        unitProgressMap.set(u.unitCode.toUpperCase().trim(), u);
      }
    }

    // Check which referenced curriculum units already have Quick Notes seeded in acedex.units
    const allRefUnitCodes = new Set<string>();
    for (const mod of modules) {
      for (const ref of mod.references || []) {
        if (ref.unitCode) allRefUnitCodes.add(ref.unitCode);
      }
    }

    const quickNotesUnitSet = await this.getQuickNotesUnitCodeSet(
      Array.from(allRefUnitCodes)
    );

    return modules.map((mod) => {
      const rec = progressMap.get(mod.moduleId);
      const completedSteps = rec ? [...rec.completedSteps].sort((a, b) => a - b) : [];
      const isCompleted = rec?.isCompleted === true;
      const progressPercentage = this.calculateModuleProgressPct(
        mod as unknown as ITopicModuleDocument,
        rec
      );

      return {
        moduleId: mod.moduleId,
        subjectCode: mod.subjectCode,
        subjectName: mod.subjectName,
        streamCategory: mod.streamCategory,
        moduleNumber: mod.moduleNumber,
        phase: mod.phase,
        title: mod.title,
        rationale: mod.rationale,
        references: (mod.references || []).map((r) => {
          const normalizedRefCode = r.unitCode.toUpperCase().trim();
          const unitRec = unitProgressMap.get(normalizedRefCode);
          const isUnitCompleted = unitRec?.isStudyCompleted === true;
          const studyStatus: StudyStatus =
            unitRec?.studyStatus || (isUnitCompleted ? 'completed' : 'not_started');

          return {
            grade: r.grade,
            unitNumber: r.unitNumber,
            unitCode: r.unitCode,
            unitTitle: r.unitTitle,
            pages: r.pages,
            hasQuickNotes: quickNotesUnitSet.has(normalizedRefCode),
            isUnitCompleted,
            studyStatus,
          };
        }),
        sequence: mod.sequence || [],
        prerequisites: mod.prerequisites || [],
        masteryCheckpoint: mod.masteryCheckpoint,
        completedSteps,
        isCompleted,
        progressPercentage,
      };
    });
  }

  /**
   * Toggles a learning sequence step or marks an entire topic module mastered/unmarked
   */
  public static async updateModuleProgress(
    userId: string,
    moduleId: string,
    payload: UpdateTopicProgressRequest
  ): Promise<{
    moduleId: string;
    subjectCode: string;
    completedSteps: number[];
    isCompleted: boolean;
    progressPercentage: number;
    subjectMasteryPercentage: number;
  }> {
    const cleanModuleId = moduleId.toUpperCase().trim();
    const mod = await TopicModuleModel.findOne({ moduleId: cleanModuleId }).lean();
    if (!mod) {
      throw new NotFoundError(`Topic module '${cleanModuleId}' not found`);
    }

    const userObjectId = new Types.ObjectId(userId);
    let progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress) {
      progress = new StudentProgressModel({
        userId: userObjectId,
        units: [],
        subjectMastery: [],
        topicModules: [],
      });
    }

    let entry = progress.topicModules.find((tm) => tm.moduleId === cleanModuleId);
    if (!entry) {
      entry = {
        moduleId: cleanModuleId,
        subjectCode: mod.subjectCode,
        moduleNumber: mod.moduleNumber,
        completedSteps: [],
        isCompleted: false,
      };
      progress.topicModules.push(entry);
      entry = progress.topicModules[progress.topicModules.length - 1];
    }

    const allStepNumbers = (mod.sequence || []).map((s) => s.stepNumber);

    if (typeof payload.isCompleted === 'boolean') {
      entry.isCompleted = payload.isCompleted;
      if (payload.isCompleted) {
        entry.completedAt = new Date();
        entry.completedSteps = allStepNumbers;
      } else {
        entry.completedAt = undefined;
        entry.completedSteps = [];
      }
    } else if (typeof payload.stepNumber === 'number') {
      const stepNum = payload.stepNumber;
      const stepSet = new Set(entry.completedSteps);
      const shouldComplete =
        typeof payload.stepCompleted === 'boolean'
          ? payload.stepCompleted
          : !stepSet.has(stepNum);

      if (shouldComplete) {
        stepSet.add(stepNum);
      } else {
        stepSet.delete(stepNum);
      }

      entry.completedSteps = Array.from(stepSet).sort((a, b) => a - b);
      if (allStepNumbers.length > 0 && entry.completedSteps.length >= allStepNumbers.length) {
        entry.isCompleted = true;
        entry.completedAt = entry.completedAt || new Date();
      } else if (!shouldComplete && entry.isCompleted) {
        entry.isCompleted = false;
        entry.completedAt = undefined;
      }
    }

    progress.markModified('topicModules');
    await progress.save();

    // Compute updated subject mastery percentage across all modules of this subject
    const subjectModules = await TopicModuleModel.find({ subjectCode: mod.subjectCode }).lean();
    const progressByMod = new Map<string, ITopicModuleProgressSubdoc>();
    for (const tm of progress.topicModules) {
      if (tm.subjectCode === mod.subjectCode) {
        progressByMod.set(tm.moduleId, tm);
      }
    }

    const totalPctSum = subjectModules.reduce(
      (sum, m) =>
        sum +
        this.calculateModuleProgressPct(
          m as unknown as ITopicModuleDocument,
          progressByMod.get(m.moduleId)
        ),
      0
    );
    const subjectMasteryPercentage =
      subjectModules.length > 0 ? Math.round(totalPctSum / subjectModules.length) : 0;

    let coinsAwarded = 0;
    let newCoinBalance: number | undefined;
    if (entry.isCompleted) {
      const modAward = await EconomyService.awardMilestone({
        userId: userObjectId,
        milestoneKey: `MODULE:${entry.moduleId}`,
        amount: ACE_COINS_CONFIG.MODULE_COMPLETE_REWARD,
        reason: `Mastered Topic Module (${entry.moduleId})`,
        metadata: { moduleId: entry.moduleId, subjectCode: entry.subjectCode },
      });
      coinsAwarded = modAward.coinsAwarded;
      newCoinBalance = modAward.newCoinBalance;
    }

    return {
      moduleId: entry.moduleId,
      subjectCode: entry.subjectCode,
      completedSteps: entry.completedSteps,
      isCompleted: entry.isCompleted,
      progressPercentage: this.calculateModuleProgressPct(
        mod as unknown as ITopicModuleDocument,
        entry
      ),
      subjectMasteryPercentage,
      ...(coinsAwarded > 0 ? { coinsAwarded } : {}),
      ...(newCoinBalance !== undefined ? { newCoinBalance } : {}),
    };
  }

  /**
   * Marks or unmarks a curriculum unit mastered from within AI Topic Modules,
   * keeping Study Screen's `progress.units` and module sequence steps unified.
   */
  public static async setTopicUnitMastery(
    userId: string,
    unitCode: string,
    payload: ToggleTopicUnitMasteryRequest
  ): Promise<TopicUnitMasteryResponse> {
    const cleanUnitCode = unitCode.toUpperCase().trim();
    const status: StudyStatus = payload.completed ? 'completed' : 'not_started';

    let coinsAwarded = 0;
    let newCoinBalance: number | undefined;

    const dbUnit = await UnitModel.findOne({ code: cleanUnitCode });
    if (dbUnit) {
      const unitRes = await ProgressService.updateUnitStudyStatus(userId, dbUnit.code, status);
      coinsAwarded += unitRes.coinsAwarded ?? 0;
      if (unitRes.newCoinBalance !== undefined) newCoinBalance = unitRes.newCoinBalance;
    } else {
      // Fallback for textbook unit references without a seeded row in `acedex.units` (e.g. PHY-G09-U06/U07)
      const existsInTopicBank = await TopicModuleModel.exists({
        'references.unitCode': cleanUnitCode,
      });
      if (!existsInTopicBank) {
        throw new NotFoundError(`Unit '${cleanUnitCode}' not found`);
      }

      const codeMatch = cleanUnitCode.match(/^([A-Z]{2,5})-G(\d{2})-/);
      const parsedSubject = codeMatch ? codeMatch[1] : cleanUnitCode.slice(0, 3);
      const parsedGrade = codeMatch ? parseInt(codeMatch[2], 10) : 9;

      const userObjectId = new Types.ObjectId(userId);
      let progressDoc = await StudentProgressModel.findOne({ userId: userObjectId });
      if (!progressDoc) {
        progressDoc = new StudentProgressModel({
          userId: userObjectId,
          units: [],
          subjectMastery: [],
          topicModules: [],
        });
      }

      let unitEntry = progressDoc.units.find(
        (u) => u.unitCode.toUpperCase().trim() === cleanUnitCode
      );
      if (!unitEntry) {
        unitEntry = {
          unitId: new Types.ObjectId(),
          unitCode: cleanUnitCode,
          subjectCode: parsedSubject,
          grade: parsedGrade,
          studyStatus: status,
          isStudyCompleted: payload.completed,
          studyCompletedAt: payload.completed ? new Date() : undefined,
          bestScore: 0,
          bestPercentage: 0,
          totalQuestions: 15,
          passed: false,
          attemptsCount: 0,
          lastAttemptAt: new Date(),
        } as IProgressUnitSubdoc;
        progressDoc.units.push(unitEntry);
      } else {
        unitEntry.studyStatus = status;
        unitEntry.isStudyCompleted = payload.completed;
        unitEntry.studyCompletedAt = payload.completed
          ? unitEntry.studyCompletedAt || new Date()
          : undefined;
      }

      progressDoc.markModified('units');
      await progressDoc.save();

      if (payload.completed) {
        const unitAward = await EconomyService.awardMilestone({
          userId: userObjectId,
          milestoneKey: `UNIT:${cleanUnitCode}`,
          amount: ACE_COINS_CONFIG.UNIT_COMPLETE_REWARD,
          reason: `Completed Unit (${cleanUnitCode})`,
          metadata: { unitCode: cleanUnitCode },
        });
        coinsAwarded += unitAward.coinsAwarded;
        newCoinBalance = unitAward.newCoinBalance;
      }
    }

    // Sync any learning steps tagged with `unitCode` inside the active module
    const syncedStepNumbers: number[] = [];
    let updatedModule: TopicUnitMasteryResponse['updatedModule'];

    if (payload.moduleId) {
      const cleanModuleId = payload.moduleId.toUpperCase().trim();
      const mod = await TopicModuleModel.findOne({ moduleId: cleanModuleId }).lean();
      if (mod) {
        const userObjectId = new Types.ObjectId(userId);
        const progress = await StudentProgressModel.findOne({ userId: userObjectId });
        if (progress) {
          const matchingSteps = (mod.sequence || [])
            .filter((s) => (s.unitCode || '').toUpperCase().trim() === cleanUnitCode)
            .map((s) => s.stepNumber);

          if (matchingSteps.length > 0) {
            let modEntry = progress.topicModules.find(
              (tm) => tm.moduleId === cleanModuleId
            );
            if (!modEntry && payload.completed) {
              progress.topicModules.push({
                moduleId: cleanModuleId,
                subjectCode: mod.subjectCode,
                moduleNumber: mod.moduleNumber,
                completedSteps: [],
                isCompleted: false,
              });
              modEntry = progress.topicModules[progress.topicModules.length - 1];
            }

            if (modEntry) {
              const stepSet = new Set(modEntry.completedSteps);
              for (const stepNum of matchingSteps) {
                if (payload.completed) {
                  stepSet.add(stepNum);
                } else {
                  stepSet.delete(stepNum);
                }
                syncedStepNumbers.push(stepNum);
              }

              modEntry.completedSteps = Array.from(stepSet).sort((a, b) => a - b);
              const totalSteps = (mod.sequence || []).length;
              if (
                payload.completed &&
                totalSteps > 0 &&
                modEntry.completedSteps.length >= totalSteps
              ) {
                modEntry.isCompleted = true;
                modEntry.completedAt = modEntry.completedAt || new Date();
              } else if (!payload.completed && modEntry.isCompleted) {
                modEntry.isCompleted = false;
                modEntry.completedAt = undefined;
              }

              progress.markModified('topicModules');
              await progress.save();

              updatedModule = {
                moduleId: modEntry.moduleId,
                subjectCode: modEntry.subjectCode,
                completedSteps: modEntry.completedSteps,
                isCompleted: modEntry.isCompleted,
                progressPercentage: this.calculateModuleProgressPct(
                  mod as unknown as ITopicModuleDocument,
                  modEntry
                ),
              };

              if (modEntry.isCompleted) {
                const modAward = await EconomyService.awardMilestone({
                  userId: userObjectId,
                  milestoneKey: `MODULE:${modEntry.moduleId}`,
                  amount: ACE_COINS_CONFIG.MODULE_COMPLETE_REWARD,
                  reason: `Mastered Topic Module (${modEntry.moduleId})`,
                });
                coinsAwarded += modAward.coinsAwarded;
                if (modAward.awarded) newCoinBalance = modAward.newCoinBalance;
              }
            }
          }
        }
      }
    }

    return {
      unitCode: cleanUnitCode,
      isStudyCompleted: payload.completed,
      studyStatus: status,
      syncedStepNumbers,
      ...(coinsAwarded > 0 ? { coinsAwarded } : {}),
      ...(newCoinBalance !== undefined ? { newCoinBalance } : {}),
      ...(updatedModule ? { updatedModule } : {}),
    };
  }
}
