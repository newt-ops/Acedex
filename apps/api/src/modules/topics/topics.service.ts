import { Types } from 'mongoose';
import {
  AiCalibrationInput,
  AiStudyProgram,
  AiTopicProgramOverviewResponse,
  AiTopicSubjectSummary,
  StudentStream,
  TopicModuleItem,
  UpdateTopicProgressRequest,
} from '@acedex/contracts';
import { UserModel } from '../users/user.model';
import {
  ITopicModuleProgressSubdoc,
  StudentProgressModel,
} from '../progress/models/student-progress.model';
import { EUEE_SUBJECTS } from '../curriculum/curriculum-seeder.service';
import { UnitModel } from '../curriculum/models/unit.model';
import { TopicModuleModel, ITopicModuleDocument } from './models/topic-module.model';
import { GeminiPlannerService } from './gemini-planner.service';
import { NotFoundError, TooManyRequestsError } from '../../common/errors/app-error';

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

    const subjectSummaries = await this.buildSubjectSummaries(
      stream,
      allModules as unknown as ITopicModuleDocument[],
      topicProgressMap,
      weakCodes
    );

    return {
      hasProgram: Boolean(savedProgram),
      canGenerateToday,
      nextGenerationAt: canGenerateToday ? null : nextResetAt,
      program: savedProgram,
      subjectSummaries,
    };
  }

  /**
   * Calibrates and persists a personalized cross-grade AI study program using Gemini + Topic Bank.
   * Limited to once per calendar day per student to prevent token abuse.
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

    if (existingProgram && existingGenDate === todayKey) {
      throw new TooManyRequestsError(
        'You can generate your AI study program once per day to prevent token abuse. Please try again tomorrow.',
        'DAILY_PLAN_LIMIT_REACHED',
        { nextGenerationAt: nextResetAt }
      );
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

    const unitsWithQuickNotes = await UnitModel.find({ hasQuickNotes: true })
      .select('code')
      .lean();
    const quickNotesUnitCodes = unitsWithQuickNotes.map((u) => u.code);

    const completedModuleIds = (progress.topicModules || [])
      .filter((tm) => tm.isCompleted)
      .map((tm) => tm.moduleId);

    const normalizedCalibration: AiCalibrationInput = {
      ...calibration,
      weakSubjectCodes: calibration.weakSubjectCodes.map((c) => c.toUpperCase().trim()),
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
    const cleanCode = subjectCode.toUpperCase().trim();
    const userObjectId = new Types.ObjectId(userId);

    const modules = await TopicModuleModel.find({ subjectCode: cleanCode })
      .sort({ moduleNumber: 1 })
      .lean();

    const progress = await StudentProgressModel.findOne({ userId: userObjectId }).lean();
    const progressMap = new Map<string, ITopicModuleProgressSubdoc>();
    for (const tm of progress?.topicModules || []) {
      progressMap.set(tm.moduleId, tm);
    }

    // Check which referenced curriculum units already have Quick Notes seeded in acedex.units
    const allRefUnitCodes = new Set<string>();
    for (const mod of modules) {
      for (const ref of mod.references || []) {
        if (ref.unitCode) allRefUnitCodes.add(ref.unitCode);
      }
    }

    const unitsWithNotes =
      allRefUnitCodes.size > 0
        ? await UnitModel.find({
            code: { $in: Array.from(allRefUnitCodes) },
            hasQuickNotes: true,
          })
            .select('code')
            .lean()
        : [];
    const quickNotesUnitSet = new Set(unitsWithNotes.map((u) => u.code));

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
        references: (mod.references || []).map((r) => ({
          grade: r.grade,
          unitNumber: r.unitNumber,
          unitCode: r.unitCode,
          unitTitle: r.unitTitle,
          pages: r.pages,
          hasQuickNotes: quickNotesUnitSet.has(r.unitCode),
        })),
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
    };
  }
}
