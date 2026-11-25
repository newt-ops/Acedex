import { Types } from 'mongoose';
import {
  StudentProgressModel,
  IStudentProgressDocument,
  IProgressUnitSubdoc,
} from './models/student-progress.model';
import { UnitModel } from '../curriculum/models/unit.model';
import { SubjectModel } from '../curriculum/models/subject.model';
import { UserModel } from '../users/user.model';
import { AssessmentAttemptModel } from '../assessments/models/assessment-attempt.model';
import {
  StudentProgressOverview,
  StudentAdStatusData,
  StudyStatus,
  UnitStudyProgressItem,
  SubjectStudyProgressResponse,
  StudyOverviewResponse,
  StudentProgressAnalytics,
  AnalyticsTimeframeDataset,
  AnalyticsTrendPoint,
  HeatmapDayAnalytics,
  SimulatorSubjectBaseline,
} from '@acedex/contracts';
import { NotFoundError } from '../../common/errors/app-error';
import { logger } from '../../common/utils/logger';
import { ACE_COINS_CONFIG, EconomyService } from '../economy/economy.service';

export interface RecordAttemptInput {
  userId: string | Types.ObjectId;
  unit: {
    _id: Types.ObjectId;
    code: string;
    subjectCode: string;
    grade: number;
  };
  score: number;
  totalQuestions: number;
  percentage: number;
  passed: boolean;
  durationSeconds: number;
}

export class ProgressService {
  /** Returns YYYY-MM-DD in East Africa Time (UTC+3). */
  public static getEatDateKey(date: Date = new Date()): string {
    const eatMs = date.getTime() + 3 * 60 * 60 * 1000;
    return new Date(eatMs).toISOString().slice(0, 10);
  }

  /**
   * Appends study minutes / assessment question metrics into `progress.dailyActivity`
   * for the specified EAT calendar day (`YYYY-MM-DD`).
   */
  public static logDailyActivity(
    progress: IStudentProgressDocument,
    input: {
      dateKey?: string;
      minutesDelta?: number;
      questionsDelta?: number;
      correctDelta?: number;
    }
  ): void {
    const dateKey = input.dateKey || this.getEatDateKey();
    const minDelta = input.minutesDelta ?? 0;
    const qDelta = input.questionsDelta ?? 0;
    const cDelta = input.correctDelta ?? 0;
    if (minDelta === 0 && qDelta === 0 && cDelta === 0) return;

    if (!Array.isArray(progress.dailyActivity)) {
      progress.dailyActivity = [];
    }

    let entry = progress.dailyActivity.find((d) => d.date === dateKey);
    if (!entry) {
      entry = {
        date: dateKey,
        minutes: 0,
        questionsAnswered: 0,
        correctAnswers: 0,
      };
      progress.dailyActivity.push(entry);
    }

    entry.minutes = Math.max(0, entry.minutes + minDelta);
    entry.questionsAnswered = Math.max(0, entry.questionsAnswered + qDelta);
    entry.correctAnswers = Math.max(0, Math.min(entry.questionsAnswered, entry.correctAnswers + cDelta));

    if (progress.dailyActivity.length > 365) {
      progress.dailyActivity.sort((a, b) => a.date.localeCompare(b.date));
      progress.dailyActivity = progress.dailyActivity.slice(-365);
    }
    progress.markModified('dailyActivity');
  }

  /**
   * Records an assessment attempt and updates progress, streak, and subject mastery
   */
  public static async recordAttempt(input: RecordAttemptInput): Promise<IStudentProgressDocument> {
    const userObjectId = new Types.ObjectId(input.userId);

    let progress = await StudentProgressModel.findOne({ userId: userObjectId });

    if (!progress) {
      progress = new StudentProgressModel({
        userId: userObjectId,
        overallStats: {
          totalAssessmentsTaken: 0,
          totalAssessmentsPassed: 0,
          averageScore: 0,
          totalTimeSpentSeconds: 0,
        },
        streak: {
          currentStreak: 0,
          longestStreak: 0,
          lastActivityDate: '',
          previousBrokenStreak: 0,
        },
        examAccess: {
          ticketsAvailable: 1,
          totalAdsWatched: 0,
        },
        offlineAccess: {
          unlockedUnits: [],
        },
        units: [],
        subjectMastery: [],
      });
    }

    // 1. Update overall statistics
    const stats = progress.overallStats;
    const previousTotal = stats.totalAssessmentsTaken;
    const newTotal = previousTotal + 1;
    const currentTotalScore = stats.averageScore * previousTotal + input.percentage;
    stats.averageScore = Math.round((currentTotalScore / newTotal) * 10) / 10;
    stats.totalAssessmentsTaken = newTotal;
    if (input.passed) {
      stats.totalAssessmentsPassed += 1;
    }
    stats.totalTimeSpentSeconds += input.durationSeconds || 0;

    // 1b. Record real daily study time & quiz accuracy log
    const attemptMinutes = Math.max(1, Math.round((input.durationSeconds || 60) / 60));
    this.logDailyActivity(progress, {
      minutesDelta: attemptMinutes,
      questionsDelta: input.totalQuestions || 0,
      correctDelta: input.score || 0,
    });

    // 2. Update Daily Streak
    const todayStr = new Date().toISOString().split('T')[0];
    const lastDateStr = progress.streak.lastActivityDate;

    if (!lastDateStr) {
      progress.streak.currentStreak = 1;
      progress.streak.longestStreak = 1;
      progress.streak.lastActivityDate = todayStr;
    } else if (lastDateStr !== todayStr) {
      const lastDate = new Date(lastDateStr);
      const todayDate = new Date(todayStr);
      const diffTime = todayDate.getTime() - lastDate.getTime();
      const diffDays = Math.round(diffTime / (1000 * 3600 * 24));

      if (diffDays === 1) {
        progress.streak.currentStreak += 1;
        if (progress.streak.currentStreak > progress.streak.longestStreak) {
          progress.streak.longestStreak = progress.streak.currentStreak;
        }
      } else if (diffDays > 1) {
        progress.streak.previousBrokenStreak = progress.streak.currentStreak;
        progress.streak.currentStreak = 1;
      }
      progress.streak.lastActivityDate = todayStr;
    }

    // 3. Update Unit Progress
    let unitEntry = progress.units.find(
      (u) => u.unitId.toString() === input.unit._id.toString() || u.unitCode === input.unit.code
    );

    if (!unitEntry) {
      progress.units.push({
        unitId: input.unit._id,
        unitCode: input.unit.code,
        subjectCode: input.unit.subjectCode,
        grade: input.unit.grade,
        bestScore: input.score,
        bestPercentage: input.percentage,
        totalQuestions: input.totalQuestions,
        passed: input.passed,
        attemptsCount: 1,
        lastAttemptAt: new Date(),
      } as IProgressUnitSubdoc);
    } else {
      unitEntry.attemptsCount += 1;
      unitEntry.lastAttemptAt = new Date();
      if (input.score > unitEntry.bestScore) {
        unitEntry.bestScore = input.score;
        unitEntry.bestPercentage = input.percentage;
      }
      if (input.passed) {
        unitEntry.passed = true;
      }
    }

    // 4. Update Subject Mastery
    const subjectUnitsCount = await UnitModel.countDocuments({
      grade: input.unit.grade,
      subjectCode: input.unit.subjectCode,
      isPublished: true,
    });

    const passedUnitsForSubject = progress.units.filter(
      (u) => u.subjectCode === input.unit.subjectCode && u.grade === input.unit.grade && u.passed
    ).length;

    const masteryPct =
      subjectUnitsCount > 0
        ? Math.round((passedUnitsForSubject / subjectUnitsCount) * 100)
        : 0;

    let subMastery = progress.subjectMastery.find(
      (sm) => sm.subjectCode === input.unit.subjectCode
    );

    if (!subMastery) {
      progress.subjectMastery.push({
        subjectCode: input.unit.subjectCode,
        unitsCompleted: passedUnitsForSubject,
        totalUnits: subjectUnitsCount,
        masteryPercentage: masteryPct,
      });
    } else {
      subMastery.unitsCompleted = passedUnitsForSubject;
      subMastery.totalUnits = subjectUnitsCount;
      subMastery.masteryPercentage = masteryPct;
    }

    await progress.save();
    logger.info(
      { userId: input.userId, unitCode: input.unit.code, score: input.score },
      'Student progress recorded successfully'
    );

    return progress;
  }

  /**
   * Retrieves overall student progress overview
   */
  public static async getOverview(userId: string): Promise<StudentProgressOverview> {
    const userObjectId = new Types.ObjectId(userId);

    const progress = await StudentProgressModel.findOne({ userId: userObjectId });
    const allSubjects = await SubjectModel.find({ isActive: true });
    const subjectMap = new Map(allSubjects.map((s) => [s.code, s.name]));

    const recentAttempts = await AssessmentAttemptModel.find({ userId: userObjectId })
      .sort({ completedAt: -1 })
      .limit(5)
      .lean();

    if (!progress) {
      return {
        overallStats: {
          totalAssessmentsTaken: 0,
          totalAssessmentsPassed: 0,
          averageScore: 0,
          totalTimeSpentSeconds: 0,
        },
        streak: {
          currentStreak: 0,
          longestStreak: 0,
          lastActivityDate: undefined,
        },
        studyStats: {
          totalUnits: 0,
          completedUnits: 0,
          inProgressUnits: 0,
          completionPercentage: 0,
        },
        subjectMastery: allSubjects.map((s) => ({
          subjectCode: s.code,
          subjectName: s.name,
          unitsCompleted: 0,
          totalUnits: 0,
          masteryPercentage: 0,
        })),
        recentAttempts: recentAttempts.map((a) => ({
          attemptId: a.attemptId,
          unitCode: a.unitCode,
          score: a.score,
          totalQuestions: a.totalQuestions,
          percentage: a.percentage,
          passed: a.passed,
          completedAt: a.completedAt.toISOString(),
        })),
      };
    }

    await this.replenishDailyFreeTickets(progress);

    // Format subject mastery with full names
    const subjectMasteryList = progress.subjectMastery.map((sm) => ({
      subjectCode: sm.subjectCode,
      subjectName: subjectMap.get(sm.subjectCode) || sm.subjectCode,
      unitsCompleted: sm.unitsCompleted,
      totalUnits: sm.totalUnits,
      masteryPercentage: sm.masteryPercentage,
    }));

    // Compute study completion stats
    const totalEnrolledUnits = progress.units.length;
    const completedUnits = progress.units.filter((u) => u.isStudyCompleted).length;
    const inProgressUnits = progress.units.filter((u) => u.studyStatus === 'in_progress').length;
    const studyCompletionPct =
      totalEnrolledUnits > 0 ? Math.round((completedUnits / totalEnrolledUnits) * 100) : 0;

    return {
      overallStats: {
        totalAssessmentsTaken: progress.overallStats.totalAssessmentsTaken,
        totalAssessmentsPassed: progress.overallStats.totalAssessmentsPassed,
        averageScore: progress.overallStats.averageScore,
        totalTimeSpentSeconds: progress.overallStats.totalTimeSpentSeconds,
      },
      streak: {
        currentStreak: progress.streak.currentStreak,
        longestStreak: progress.streak.longestStreak,
        lastActivityDate: progress.streak.lastActivityDate || undefined,
      },
      studyStats: {
        totalUnits: totalEnrolledUnits,
        completedUnits,
        inProgressUnits,
        completionPercentage: studyCompletionPct,
      },
      subjectMastery: subjectMasteryList,
      recentAttempts: recentAttempts.map((a) => ({
        attemptId: a.attemptId,
        unitCode: a.unitCode,
        score: a.score,
        totalQuestions: a.totalQuestions,
        percentage: a.percentage,
        passed: a.passed,
        completedAt: a.completedAt.toISOString(),
      })),
    };
  }

  /**
   * Retrieves detailed unit-by-unit progress for a specific subject
   */
  public static async getSubjectProgress(
    userId: string,
    subjectCode: string,
    grade: number
  ) {
    const userObjectId = new Types.ObjectId(userId);
    const progress = await StudentProgressModel.findOne({ userId: userObjectId });

    const units = await UnitModel.find({
      subjectCode: subjectCode.toUpperCase(),
      grade,
      isPublished: true,
    }).sort({ unitNumber: 1 });

    const studentUnitMap = new Map(
      (progress?.units || []).map((u) => [u.unitCode, u])
    );

    const detailedUnits = units.map((u) => {
      const studentRecord = studentUnitMap.get(u.code);
      return {
        unitId: u._id.toString(),
        unitCode: u.code,
        title: u.title,
        unitNumber: u.unitNumber,
        questionCount: u.questionCount,
        attemptsCount: studentRecord ? studentRecord.attemptsCount : 0,
        bestScore: studentRecord ? studentRecord.bestScore : 0,
        bestPercentage: studentRecord ? studentRecord.bestPercentage : 0,
        passed: studentRecord ? studentRecord.passed : false,
        lastAttemptAt: studentRecord ? studentRecord.lastAttemptAt.toISOString() : null,
      };
    });

    return {
      subjectCode: subjectCode.toUpperCase(),
      grade,
      units: detailedUnits,
    };
  }

  /**
   * Restores a broken study streak after watching an ad
   */
  public static async repairStreak(userId: string | Types.ObjectId): Promise<number> {
    const userObjectId = new Types.ObjectId(userId);
    const progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress) {
      throw new Error('Student progress record not found');
    }

    if (!progress.streak.previousBrokenStreak || progress.streak.previousBrokenStreak <= 0) {
      throw new Error('No broken streak available to repair');
    }

    const restoredStreak = progress.streak.previousBrokenStreak + 1;
    progress.streak.currentStreak = restoredStreak;
    if (restoredStreak > progress.streak.longestStreak) {
      progress.streak.longestStreak = restoredStreak;
    }
    progress.streak.previousBrokenStreak = 0;
    progress.streak.lastRepairedAt = new Date();
    progress.streak.lastActivityDate = new Date().toISOString().split('T')[0];

    if (!progress.examAccess) {
      progress.examAccess = { ticketsAvailable: 1, totalAdsWatched: 0 };
    }
    progress.examAccess.totalAdsWatched += 1;

    await progress.save();
    logger.info({ userId: userId.toString(), restoredStreak }, 'Student streak successfully repaired');
    return restoredStreak;
  }

  /**
   * Grants exam access tickets after watching an ad
   */
  public static async grantExamTicket(
    userId: string | Types.ObjectId,
    count = 1
  ): Promise<number> {
    const userObjectId = new Types.ObjectId(userId);
    let progress = await StudentProgressModel.findOne({ userId: userObjectId });

    if (!progress) {
      progress = new StudentProgressModel({
        userId: userObjectId,
        overallStats: { totalAssessmentsTaken: 0, totalAssessmentsPassed: 0, averageScore: 0, totalTimeSpentSeconds: 0 },
        streak: { currentStreak: 0, longestStreak: 0, lastActivityDate: '', previousBrokenStreak: 0 },
        examAccess: { ticketsAvailable: 1, totalAdsWatched: 0 },
        offlineAccess: { unlockedUnits: [] },
        units: [],
        subjectMastery: [],
      });
    }

    if (!progress.examAccess) {
      progress.examAccess = { ticketsAvailable: 1, totalAdsWatched: 0 };
    }

    progress.examAccess.ticketsAvailable += count;
    progress.examAccess.totalAdsWatched += 1;
    await progress.save();

    logger.info({ userId: userId.toString(), newTicketCount: progress.examAccess.ticketsAvailable }, 'Exam tickets granted');
    return progress.examAccess.ticketsAvailable;
  }

  /**
   * Consumes one exam ticket when taking an assessment
   */
  public static async consumeExamTicket(userId: string | Types.ObjectId): Promise<boolean> {
    const userObjectId = new Types.ObjectId(userId);
    const progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress || !progress.examAccess || progress.examAccess.ticketsAvailable <= 0) {
      return false;
    }

    progress.examAccess.ticketsAvailable -= 1;
    await progress.save();
    return true;
  }

  /**
   * Grants 24-hour offline study pass for a specific unit
   */
  public static async grantOfflinePack(
    userId: string | Types.ObjectId,
    unitId: string | Types.ObjectId,
    unitCode: string,
    durationHours = 24
  ): Promise<{ unitId: string; unitCode: string; expiresAt: Date }> {
    const userObjectId = new Types.ObjectId(userId);
    const targetUnitObjectId = new Types.ObjectId(unitId);

    let progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress) {
      progress = new StudentProgressModel({
        userId: userObjectId,
        overallStats: { totalAssessmentsTaken: 0, totalAssessmentsPassed: 0, averageScore: 0, totalTimeSpentSeconds: 0 },
        streak: { currentStreak: 0, longestStreak: 0, lastActivityDate: '', previousBrokenStreak: 0 },
        examAccess: { ticketsAvailable: 1, totalAdsWatched: 0 },
        offlineAccess: { unlockedUnits: [] },
        units: [],
        subjectMastery: [],
      });
    }

    if (!progress.offlineAccess) {
      progress.offlineAccess = { unlockedUnits: [] };
    }

    const expiresAt = new Date(Date.now() + durationHours * 3600 * 1000);
    const existingIndex = progress.offlineAccess.unlockedUnits.findIndex(
      (u) => u.unitId.toString() === targetUnitObjectId.toString()
    );

    if (existingIndex >= 0) {
      progress.offlineAccess.unlockedUnits[existingIndex].expiresAt = expiresAt;
      progress.offlineAccess.unlockedUnits[existingIndex].unitCode = unitCode;
    } else {
      progress.offlineAccess.unlockedUnits.push({
        unitId: targetUnitObjectId,
        unitCode,
        expiresAt,
      });
    }

    if (!progress.examAccess) {
      progress.examAccess = { ticketsAvailable: 1, totalAdsWatched: 0 };
    }
    progress.examAccess.totalAdsWatched += 1;

    await progress.save();
    logger.info(
      { userId: userId.toString(), unitCode, expiresAt },
      'Offline study pack granted for 24 hours'
    );

    return {
      unitId: targetUnitObjectId.toString(),
      unitCode,
      expiresAt,
    };
  }

  /**
   * Checks if user has a valid unexpired offline pass for a unit
   */
  public static async hasOfflineAccess(
    userId: string | Types.ObjectId,
    unitId: string | Types.ObjectId
  ): Promise<boolean> {
    const userObjectId = new Types.ObjectId(userId);
    const targetUnitObjectId = new Types.ObjectId(unitId);
    const progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress || !progress.offlineAccess) return false;

    const entry = progress.offlineAccess.unlockedUnits.find(
      (u) => u.unitId.toString() === targetUnitObjectId.toString()
    );
    if (!entry) return false;

    return new Date(entry.expiresAt).getTime() > Date.now();
  }

  /**
   * Replenishes daily free exam tickets (minimum 2 tickets per calendar day)
   */
  public static async replenishDailyFreeTickets(progress: IStudentProgressDocument): Promise<boolean> {
    const today = new Date().toISOString().slice(0, 10);
    if (!progress.examAccess) {
      progress.examAccess = { ticketsAvailable: 2, totalAdsWatched: 0, lastDailyTicketDate: today };
      await progress.save();
      return true;
    }

    if (progress.examAccess.lastDailyTicketDate !== today) {
      if (progress.examAccess.ticketsAvailable < 2) {
        progress.examAccess.ticketsAvailable = 2;
      }
      progress.examAccess.lastDailyTicketDate = today;
      await progress.save();
      logger.info(
        { userId: progress.userId.toString(), tickets: progress.examAccess.ticketsAvailable },
        'Daily free exam tickets replenished'
      );
      return true;
    }

    return false;
  }

  /**
   * Returns current ad monetization status for student
   */
  public static async getStudentAdStatus(userId: string | Types.ObjectId): Promise<StudentAdStatusData> {
    const userObjectId = new Types.ObjectId(userId);
    let progress = await StudentProgressModel.findOne({ userId: userObjectId });

    if (!progress) {
      const today = new Date().toISOString().slice(0, 10);
      progress = new StudentProgressModel({
        userId: userObjectId,
        overallStats: { totalAssessmentsTaken: 0, totalAssessmentsPassed: 0, averageScore: 0, totalTimeSpentSeconds: 0 },
        streak: { currentStreak: 0, longestStreak: 0, lastActivityDate: '', previousBrokenStreak: 0 },
        examAccess: { ticketsAvailable: 2, totalAdsWatched: 0, lastDailyTicketDate: today },
        offlineAccess: { unlockedUnits: [] },
        units: [],
        subjectMastery: [],
      });
      await progress.save();
    } else {
      await this.replenishDailyFreeTickets(progress);
    }

    const now = Date.now();
    const activeOffline = (progress.offlineAccess?.unlockedUnits || [])
      .filter((u) => new Date(u.expiresAt).getTime() > now)
      .map((u) => ({
        unitId: u.unitId.toString(),
        unitCode: u.unitCode,
        expiresAt: new Date(u.expiresAt).toISOString(),
      }));

    const tickets = progress.examAccess?.ticketsAvailable ?? 1;
    const canRepair = (progress.streak?.previousBrokenStreak || 0) > 0;

    return {
      streak: {
        currentStreak: progress.streak?.currentStreak || 0,
        canRepair,
        brokenStreakCount: canRepair ? progress.streak.previousBrokenStreak : undefined,
      },
      examAccess: {
        canTakeExam: tickets > 0,
        ticketsAvailable: tickets,
        requiresAd: tickets <= 0,
      },
      offlineAccess: {
        unlockedUnits: activeOffline,
      },
    };
  }

  /**
   * Updates study status for a specific unit (mark finished, in_progress, not_started)
   * When status is 'completed', unlocks exam assessment and updates streak.
   */
  public static async updateUnitStudyStatus(
    userId: string | Types.ObjectId,
    unitIdOrCode: string,
    status: StudyStatus
  ): Promise<UnitStudyProgressItem> {
    const userObjectId = new Types.ObjectId(userId);

    // Resolve unit
    let unit = null;
    if (Types.ObjectId.isValid(unitIdOrCode)) {
      unit = await UnitModel.findById(unitIdOrCode);
    }
    if (!unit) {
      unit = await UnitModel.findOne({ code: unitIdOrCode.toUpperCase() });
    }
    if (!unit) {
      throw new NotFoundError(`Unit '${unitIdOrCode}' not found`);
    }

    let progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress) {
      progress = new StudentProgressModel({
        userId: userObjectId,
        overallStats: { totalAssessmentsTaken: 0, totalAssessmentsPassed: 0, averageScore: 0, totalTimeSpentSeconds: 0 },
        streak: { currentStreak: 0, longestStreak: 0, lastActivityDate: '', previousBrokenStreak: 0 },
        examAccess: { ticketsAvailable: 1, totalAdsWatched: 0 },
        offlineAccess: { unlockedUnits: [] },
        units: [],
        subjectMastery: [],
      });
    }

    let unitEntry = progress.units.find(
      (u) => u.unitId.toString() === unit._id.toString() || u.unitCode === unit.code
    );

    const isCompleted = status === 'completed';
    const wasAlreadyCompleted = unitEntry?.isStudyCompleted === true;

    if (!unitEntry) {
      unitEntry = {
        unitId: unit._id,
        unitCode: unit.code,
        subjectCode: unit.subjectCode,
        grade: unit.grade,
        studyStatus: status,
        isStudyCompleted: isCompleted,
        studyCompletedAt: isCompleted ? new Date() : undefined,
        bestScore: 0,
        bestPercentage: 0,
        totalQuestions: 15,
        passed: false,
        attemptsCount: 0,
        lastAttemptAt: new Date(),
      } as IProgressUnitSubdoc;
      progress.units.push(unitEntry);
    } else {
      unitEntry.studyStatus = status;
      unitEntry.isStudyCompleted = isCompleted;
      if (isCompleted) {
        unitEntry.studyCompletedAt = unitEntry.studyCompletedAt || new Date();
      } else {
        unitEntry.studyCompletedAt = undefined;
      }
    }

    if (isCompleted && !wasAlreadyCompleted) {
      this.logDailyActivity(progress, { minutesDelta: 15 });
    } else if (!isCompleted && wasAlreadyCompleted) {
      this.logDailyActivity(progress, { minutesDelta: -15 });
    }

    // If marked completed, record streak activity for today
    if (isCompleted) {
      const todayStr = new Date().toISOString().split('T')[0];
      const lastDateStr = progress.streak.lastActivityDate;
      if (!lastDateStr) {
        progress.streak.currentStreak = 1;
        progress.streak.longestStreak = 1;
        progress.streak.lastActivityDate = todayStr;
      } else if (lastDateStr !== todayStr) {
        const lastDate = new Date(lastDateStr);
        const todayDate = new Date(todayStr);
        const diffTime = todayDate.getTime() - lastDate.getTime();
        const diffDays = Math.round(diffTime / (1000 * 3600 * 24));
        if (diffDays === 1) {
          progress.streak.currentStreak += 1;
          if (progress.streak.currentStreak > progress.streak.longestStreak) {
            progress.streak.longestStreak = progress.streak.currentStreak;
          }
        } else if (diffDays > 1) {
          progress.streak.previousBrokenStreak = progress.streak.currentStreak;
          progress.streak.currentStreak = 1;
        }
        progress.streak.lastActivityDate = todayStr;
      }
    }

    await progress.save();

    let totalCoinsAwarded = 0;
    let latestBalance: number | undefined;
    if (isCompleted) {
      const unitAward = await EconomyService.awardMilestone({
        userId: userObjectId,
        milestoneKey: `UNIT:${unit.code}`,
        amount: ACE_COINS_CONFIG.UNIT_COMPLETE_REWARD,
        reason: `Completed Unit (${unit.code})`,
        metadata: { unitCode: unit.code },
      });
      totalCoinsAwarded += unitAward.coinsAwarded;
      latestBalance = unitAward.newCoinBalance;

      const todayStr = EconomyService.getEatTodayKey();
      const streakAward = await EconomyService.awardMilestone({
        userId: userObjectId,
        milestoneKey: `STREAK:${todayStr}`,
        amount: ACE_COINS_CONFIG.DAILY_STREAK_REWARD,
        reason: `Daily Study Streak (${todayStr})`,
      });
      totalCoinsAwarded += streakAward.coinsAwarded;
      if (streakAward.awarded) latestBalance = streakAward.newCoinBalance;

      const curStreak = progress.streak?.currentStreak || 0;
      if (curStreak >= 7 && curStreak % 7 === 0) {
        const sevenAward = await EconomyService.awardMilestone({
          userId: userObjectId,
          milestoneKey: `STREAK_7:${curStreak}`,
          amount: ACE_COINS_CONFIG.SEVEN_DAY_STREAK_BONUS,
          reason: `${curStreak}-Day Streak Milestone!`,
        });
        totalCoinsAwarded += sevenAward.coinsAwarded;
        if (sevenAward.awarded) latestBalance = sevenAward.newCoinBalance;
      }
    }

    logger.info(
      { userId: userId.toString(), unitCode: unit.code, status, isCompleted, totalCoinsAwarded },
      'Unit study status updated'
    );

    return {
      unitId: unit._id.toString(),
      unitCode: unit.code,
      subjectCode: unit.subjectCode,
      grade: unit.grade,
      unitNumber: unit.unitNumber,
      title: unit.title,
      studyStatus: unitEntry.studyStatus || status,
      isStudyCompleted: unitEntry.isStudyCompleted,
      isExamUnlocked: unitEntry.isStudyCompleted,
      studyCompletedAt: unitEntry.studyCompletedAt ? unitEntry.studyCompletedAt.toISOString() : undefined,
      bestScore: unitEntry.bestScore,
      bestPercentage: unitEntry.bestPercentage,
      passed: unitEntry.passed,
      attemptsCount: unitEntry.attemptsCount,
      ...(totalCoinsAwarded > 0 ? { coinsAwarded: totalCoinsAwarded } : {}),
      ...(latestBalance !== undefined ? { newCoinBalance: latestBalance } : {}),
    };
  }

  /**
   * Verifies if a unit's exam assessment is unlocked for this student
   */
  public static async isExamUnlocked(
    userId: string | Types.ObjectId,
    unitIdOrCode: string | Types.ObjectId
  ): Promise<boolean> {
    const userObjectId = new Types.ObjectId(userId);
    const progress = await StudentProgressModel.findOne({ userId: userObjectId });
    if (!progress || !progress.units) return false;

    const targetStr = unitIdOrCode.toString();
    const entry = progress.units.find(
      (u) => u.unitId.toString() === targetStr || u.unitCode === targetStr.toUpperCase()
    );

    return entry ? entry.isStudyCompleted === true : false;
  }

  /**
   * Returns subject-level study progress including each unit's study & exam status
   */
  public static async getSubjectStudyProgress(
    userId: string | Types.ObjectId,
    subjectCode: string,
    gradeInput?: number
  ): Promise<SubjectStudyProgressResponse> {
    const userObjectId = new Types.ObjectId(userId);
    let grade = gradeInput;
    if (!grade) {
      const user = await UserModel.findById(userObjectId);
      grade = user?.grade || 9;
    }

    const code = subjectCode.toUpperCase();
    const subject = await SubjectModel.findOne({ code });
    const subjectName = subject ? subject.name : code;

    const units = await UnitModel.find({
      subjectCode: code,
      grade,
      isPublished: true,
    }).sort({ unitNumber: 1 });

    const progress = await StudentProgressModel.findOne({ userId: userObjectId });
    const studentUnitMap = new Map(
      (progress?.units || []).map((u) => [u.unitCode, u])
    );

    let completedUnits = 0;
    let inProgressUnits = 0;

    const unitItems: UnitStudyProgressItem[] = units.map((u) => {
      const record = studentUnitMap.get(u.code);
      const isCompleted = record ? record.isStudyCompleted === true : false;
      const studyStatus: StudyStatus = record
        ? (record.studyStatus || (isCompleted ? 'completed' : 'not_started'))
        : 'not_started';

      if (isCompleted) {
        completedUnits++;
      } else if (studyStatus === 'in_progress') {
        inProgressUnits++;
      }

      return {
        unitId: u._id.toString(),
        unitCode: u.code,
        subjectCode: u.subjectCode,
        grade: u.grade,
        unitNumber: u.unitNumber,
        title: u.title,
        studyStatus,
        isStudyCompleted: isCompleted,
        isExamUnlocked: isCompleted,
        studyCompletedAt: record?.studyCompletedAt ? record.studyCompletedAt.toISOString() : undefined,
        bestScore: record ? record.bestScore : 0,
        bestPercentage: record ? record.bestPercentage : 0,
        passed: record ? record.passed : false,
        attemptsCount: record ? record.attemptsCount : 0,
      };
    });

    const totalUnits = units.length;
    const completionPercentage = totalUnits > 0 ? Math.round((completedUnits / totalUnits) * 100) : 0;

    return {
      subjectCode: code,
      subjectName,
      grade,
      totalUnits,
      completedUnits,
      inProgressUnits,
      completionPercentage,
      units: unitItems,
    };
  }

  /**
   * Returns student's overall study overview across enrolled subjects
   */
  public static async getStudyOverview(userId: string | Types.ObjectId): Promise<StudyOverviewResponse> {
    const userObjectId = new Types.ObjectId(userId);
    const user = await UserModel.findById(userObjectId);
    const grade = user?.grade || 9;
    const stream = user?.stream;

    let subjectFilter: Record<string, any> = { isActive: true };
    if (grade === 11 || grade === 12) {
      if (stream === 'natural') {
        subjectFilter.streamCategory = { $in: ['natural', 'common'] };
      } else if (stream === 'social') {
        subjectFilter.streamCategory = { $in: ['social', 'common'] };
      }
    }

    const subjects = await SubjectModel.find(subjectFilter).sort({ order: 1 });
    const progress = await StudentProgressModel.findOne({ userId: userObjectId });
    const studentUnitMap = new Map(
      (progress?.units || []).map((u) => [u.unitCode, u])
    );

    let totalUnitsOverall = 0;
    let completedUnitsOverall = 0;
    let inProgressUnitsOverall = 0;

    const subjectSummaries = await Promise.all(
      subjects.map(async (s) => {
        const units = await UnitModel.find({
          subjectCode: s.code,
          grade,
          isPublished: true,
        }).select('code');

        let subCompleted = 0;
        for (const u of units) {
          totalUnitsOverall++;
          const rec = studentUnitMap.get(u.code);
          if (rec?.isStudyCompleted) {
            subCompleted++;
            completedUnitsOverall++;
          } else if (rec?.studyStatus === 'in_progress') {
            inProgressUnitsOverall++;
          }
        }

        const subTotal = units.length;
        const subPct = subTotal > 0 ? Math.round((subCompleted / subTotal) * 100) : 0;

        return {
          subjectCode: s.code,
          subjectName: s.name,
          grade,
          totalUnits: subTotal,
          completedUnits: subCompleted,
          completionPercentage: subPct,
        };
      })
    );

    const overallPct =
      totalUnitsOverall > 0 ? Math.round((completedUnitsOverall / totalUnitsOverall) * 100) : 0;

    return {
      totalUnits: totalUnitsOverall,
      completedUnits: completedUnitsOverall,
      inProgressUnits: inProgressUnitsOverall,
      completionPercentage: overallPct,
      subjects: subjectSummaries,
    };
  }

  /**
   * Computes live progress analytics, study & accuracy trends, 28-day consistency heatmap,
   * and stream-aware 6-subject EUEE baseline scores (including English & SAT) from MongoDB.
   */
  public static async getAnalytics(userId: string): Promise<StudentProgressAnalytics> {
    const userObjectId = new Types.ObjectId(userId);
    const [user, progress, attempts] = await Promise.all([
      UserModel.findById(userObjectId).lean(),
      StudentProgressModel.findOne({ userId: userObjectId }).lean(),
      AssessmentAttemptModel.find({ userId: userObjectId }).sort({ completedAt: 1 }).lean(),
    ]);

    const stream: 'natural' | 'social' = user?.stream === 'social' ? 'social' : 'natural';
    const dailyGoalMinutes =
      progress?.aiStudyProgram?.calibration?.dailyMinutes &&
      progress.aiStudyProgram.calibration.dailyMinutes > 0
        ? progress.aiStudyProgram.calibration.dailyMinutes
        : 60;

    // Stream subjects (excluding APT from UnitModel since SAT is computed dynamically below)
    const curriculumCodes =
      stream === 'social'
        ? ['MAT', 'ECO', 'GEO', 'HIS', 'ENG']
        : ['MAT', 'PHY', 'BIO', 'CHE', 'ENG'];

    const publishedUnits = await UnitModel.find({
      subjectCode: { $in: curriculumCodes },
      isPublished: true,
    })
      .select('code subjectCode')
      .lean();

    const unitTotalsBySubj = new Map<string, number>();
    for (const u of publishedUnits) {
      const code = (u.subjectCode || '').toUpperCase();
      unitTotalsBySubj.set(code, (unitTotalsBySubj.get(code) || 0) + 1);
    }

    const totalStreamUnits = publishedUnits.length;
    const completedUnitsList = (progress?.units || []).filter(
      (u) => u.isStudyCompleted && curriculumCodes.includes((u.subjectCode || '').toUpperCase())
    );
    const completedStreamUnits = completedUnitsList.length;
    const coveragePct =
      totalStreamUnits > 0 ? Math.round((completedStreamUnits / totalStreamUnits) * 100) : 0;

    // Build real activity map keyed by EAT calendar date (YYYY-MM-DD)
    const activityMap = new Map<
      string,
      { minutes: number; questions: number; correct: number }
    >();
    const recordedDates = new Set<string>();

    for (const entry of progress?.dailyActivity || []) {
      recordedDates.add(entry.date);
      activityMap.set(entry.date, {
        minutes: entry.minutes || 0,
        questions: entry.questionsAnswered || 0,
        correct: entry.correctAnswers || 0,
      });
    }

    // Backfill historical attempts / completions for dates without explicit dailyActivity logs
    const backfillMap = new Map<
      string,
      { minutes: number; questions: number; correct: number }
    >();
    for (const a of attempts) {
      const dateKey = this.getEatDateKey(new Date(a.completedAt));
      const cur = backfillMap.get(dateKey) || { minutes: 0, questions: 0, correct: 0 };
      cur.minutes += Math.max(1, Math.round((a.durationSeconds || 60) / 60));
      cur.questions += a.totalQuestions || 0;
      cur.correct += a.score || 0;
      backfillMap.set(dateKey, cur);
    }
    for (const u of progress?.units || []) {
      if (u.isStudyCompleted && u.studyCompletedAt) {
        const dateKey = this.getEatDateKey(new Date(u.studyCompletedAt));
        const cur = backfillMap.get(dateKey) || { minutes: 0, questions: 0, correct: 0 };
        cur.minutes += 15;
        backfillMap.set(dateKey, cur);
      }
    }
    for (const tm of progress?.topicModules || []) {
      if (tm.isCompleted && tm.completedAt) {
        const dateKey = this.getEatDateKey(new Date(tm.completedAt));
        const cur = backfillMap.get(dateKey) || { minutes: 0, questions: 0, correct: 0 };
        cur.minutes += 15;
        backfillMap.set(dateKey, cur);
      }
    }
    for (const [dateKey, derived] of backfillMap.entries()) {
      if (!recordedDates.has(dateKey)) {
        activityMap.set(dateKey, derived);
      }
    }

    const todayKey = this.getEatDateKey(new Date());
    const parseUtc = (key: string) => new Date(`${key}T00:00:00.000Z`);
    const shiftKey = (baseKey: string, deltaDays: number): string => {
      const dt = parseUtc(baseKey);
      dt.setUTCDate(dt.getUTCDate() + deltaDays);
      return dt.toISOString().slice(0, 10);
    };

    const monthShortNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdayShortNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const weekdayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    const formatReadableDate = (key: string): string => {
      const dt = parseUtc(key);
      const m = monthShortNames[dt.getUTCMonth()];
      const d = String(dt.getUTCDate()).padStart(2, '0');
      const w = key === todayKey ? 'Today' : weekdayShortNames[dt.getUTCDay()];
      return `${m} ${d} • ${w}`;
    };

    // 28-day Consistency Heatmap ending today
    const heatmapDays: HeatmapDayAnalytics[] = [];
    for (let offset = 27; offset >= 0; offset--) {
      const dateKey = shiftKey(todayKey, -offset);
      const dt = parseUtc(dateKey);
      const act = activityMap.get(dateKey) || { minutes: 0, questions: 0, correct: 0 };
      const hours = Math.round((act.minutes / 60) * 10) / 10;
      const acc = act.questions > 0 ? Math.round((act.correct / act.questions) * 100) : 0;

      let level = 0;
      if (act.minutes > 0) {
        if (act.minutes >= Math.max(90, dailyGoalMinutes)) level = 4;
        else if (act.minutes >= Math.max(60, Math.round(dailyGoalMinutes * 0.75))) level = 3;
        else if (act.minutes >= 30) level = 2;
        else level = 1;
      }

      heatmapDays.push({
        dateKey,
        date: formatReadableDate(dateKey),
        weekdayShort: weekdayLetters[dt.getUTCDay()],
        hours,
        minutes: act.minutes,
        qs: act.questions,
        acc,
        level,
      });
    }

    // Compute real subject baselines (all 6 subjects including English + SAT)
    const subjectBestUnitPct = new Map<string, number[]>();
    for (const u of progress?.units || []) {
      if ((u.attemptsCount || 0) > 0) {
        const code = (u.subjectCode || '').toUpperCase();
        const arr = subjectBestUnitPct.get(code) || [];
        arr.push(u.bestPercentage || 0);
        subjectBestUnitPct.set(code, arr);
      }
    }

    const completedCountBySubj = new Map<string, number>();
    for (const u of completedUnitsList) {
      const code = (u.subjectCode || '').toUpperCase();
      completedCountBySubj.set(code, (completedCountBySubj.get(code) || 0) + 1);
    }

    const subjectDefs =
      stream === 'social'
        ? [
            { id: 'math', code: 'MAT', name: 'Mathematics' },
            { id: 'economics', code: 'ECO', name: 'Economics' },
            { id: 'geography', code: 'GEO', name: 'Geography' },
            { id: 'history', code: 'HIS', name: 'History' },
            { id: 'english', code: 'ENG', name: 'English' },
          ]
        : [
            { id: 'math', code: 'MAT', name: 'Mathematics' },
            { id: 'physics', code: 'PHY', name: 'Physics' },
            { id: 'biology', code: 'BIO', name: 'Biology' },
            { id: 'chemistry', code: 'CHE', name: 'Chemistry' },
            { id: 'english', code: 'ENG', name: 'English' },
          ];

    const simulatorSubjects: SimulatorSubjectBaseline[] = subjectDefs.map((def) => {
      const totalSubj = unitTotalsBySubj.get(def.code) || 0;
      const doneSubj = completedCountBySubj.get(def.code) || 0;
      const covPct = totalSubj > 0 ? (doneSubj / totalSubj) * 100 : 0;
      const scores = subjectBestUnitPct.get(def.code) || [];
      const avgBestPct =
        scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0;

      let liveScore = 0;
      if (scores.length > 0) {
        liveScore = Math.round(avgBestPct * 0.7 + covPct * 0.3);
      } else if (doneSubj > 0) {
        liveScore = Math.round(covPct * 0.65);
      }
      return {
        id: def.id,
        code: def.code,
        name: def.name,
        score: Math.max(0, Math.min(100, liveScore)),
      };
    });

    const overallAccuracyAll =
      attempts.length > 0
        ? attempts.reduce((sum, a) => sum + (a.percentage || 0), 0) / attempts.length
        : 0;

    // Derive live SAT (Scholastic Aptitude) score from MAT + ENG + analytical readiness (0 when fresh)
    const matScore = simulatorSubjects.find((s) => s.code === 'MAT')?.score ?? 0;
    const engScore = simulatorSubjects.find((s) => s.code === 'ENG')?.score ?? 0;
    const satBasis = [matScore, engScore].filter((v) => v > 0);
    const satScore =
      satBasis.length > 0
        ? Math.round(
            satBasis.reduce((a, b) => a + b, 0) / satBasis.length
          )
        : overallAccuracyAll > 0
          ? Math.round(overallAccuracyAll * 0.7 + coveragePct * 0.3)
          : Math.round(coveragePct * 0.65);

    simulatorSubjects.push({
      id: 'sat',
      code: 'SAT',
      name: 'SAT',
      score: Math.max(0, Math.min(100, satScore)),
    });

    const projectedScore = simulatorSubjects.reduce((sum, s) => sum + s.score, 0);

    const getPercentileLabel = (score: number): string => {
      if (score <= 0) return 'Baseline';
      if (score >= 510) return 'Top 1%';
      if (score >= 460) return 'Top 5%';
      if (score >= 400) return 'Top 12%';
      if (score >= 300) return 'Top 25%';
      return 'Building';
    };

    const getSubcopy = (score: number, avgAcc: number): string => {
      if (score <= 0) {
        return 'Complete units & assessments to build your live EUEE projection.';
      }
      if (score >= 480) {
        return 'On track for competitive Engineering & Medicine placement.';
      }
      if (avgAcc >= 75) {
        return 'Strong accuracy—expand syllabus coverage to lift your projection.';
      }
      return 'Keep completing daily focus blocks & assessments to raise readiness.';
    };

    const computeRangeStats = (startKey: string, endKey: string) => {
      let minutes = 0;
      let qs = 0;
      let correct = 0;
      let activeDays = 0;

      let cursor = startKey;
      while (cursor <= endKey) {
        const act = activityMap.get(cursor);
        if (act && (act.minutes > 0 || act.questions > 0)) {
          activeDays++;
          minutes += act.minutes;
          qs += act.questions;
          correct += act.correct;
        }
        cursor = shiftKey(cursor, 1);
      }

      const accExact = qs > 0 ? Math.round((correct / qs) * 1000) / 10 : 0;
      return {
        minutes,
        hoursExact: Math.round((minutes / 60) * 10) / 10,
        qs,
        correct,
        accRounded: Math.round(accExact),
        accExact,
        activeDays,
      };
    };

    const countAttemptsInRange = (startKey: string, endKey: string): number => {
      return attempts.filter((a) => {
        const k = this.getEatDateKey(new Date(a.completedAt));
        return k >= startKey && k <= endKey;
      }).length;
    };

    const computeDeltaLabel = (currentAcc: number, prevAcc: number): string => {
      if (currentAcc === 0 && prevAcc === 0) return '+0.0%';
      const diff = Math.round((currentAcc - prevAcc) * 10) / 10;
      const sign = diff >= 0 ? '+' : '';
      return `${sign}${diff.toFixed(1)}%`;
    };

    // 1) 7 Days dataset
    const sevenStart = shiftKey(todayKey, -6);
    const prevSevenStart = shiftKey(todayKey, -13);
    const prevSevenEnd = shiftKey(todayKey, -7);
    const sevenPoints: AnalyticsTrendPoint[] = [];
    for (let offset = 6; offset >= 0; offset--) {
      const k = shiftKey(todayKey, -offset);
      const dt = parseUtc(k);
      const act = activityMap.get(k) || { minutes: 0, questions: 0, correct: 0 };
      sevenPoints.push({
        dateKey: k,
        short: k === todayKey ? 'Today' : weekdayShortNames[dt.getUTCDay()],
        label: formatReadableDate(k),
        hours: Math.round((act.minutes / 60) * 10) / 10,
        minutes: act.minutes,
        qs: act.questions,
        acc: act.questions > 0 ? Math.round((act.correct / act.questions) * 100) : 0,
      });
    }
    const stats7d = computeRangeStats(sevenStart, todayKey);
    const prevStats7d = computeRangeStats(prevSevenStart, prevSevenEnd);
    const consistency7d = Math.min(100, Math.round((stats7d.activeDays / 7) * 100));
    const readiness7d = Math.round(
      0.4 * coveragePct + 0.4 * stats7d.accRounded + 0.2 * consistency7d
    );

    const ds7d: AnalyticsTimeframeDataset = {
      readinessPct: readiness7d,
      projectedScore,
      percentile: getPercentileLabel(projectedScore),
      delta: computeDeltaLabel(stats7d.accExact, prevStats7d.accExact),
      subcopy: getSubcopy(projectedScore, stats7d.accExact),
      coveragePct,
      accuracyPct: stats7d.accRounded,
      consistencyPct: consistency7d,
      completedUnits: completedStreamUnits,
      totalUnits: totalStreamUnits,
      assessmentsCount: countAttemptsInRange(sevenStart, todayKey),
      dailyGoalMinutes,
      activeDays: stats7d.activeDays,
      windowDays: 7,
      footerHours: `${stats7d.hoursExact.toFixed(1)} hrs`,
      footerAcc: `${stats7d.accExact.toFixed(1)}%`,
      footerQs: `${stats7d.qs} Qs`,
      points: sevenPoints,
    };

    // 2) 30 Days dataset (7 buckets spanning last 30 days)
    const thirtyStart = shiftKey(todayKey, -29);
    const prevThirtyStart = shiftKey(todayKey, -59);
    const prevThirtyEnd = shiftKey(todayKey, -30);
    const bucketSizes = [4, 4, 4, 4, 5, 4, 5]; // 30 days total
    const thirtyPoints: AnalyticsTrendPoint[] = [];
    let bucketCursor = thirtyStart;
    bucketSizes.forEach((len, idx) => {
      const bEnd = shiftKey(bucketCursor, len - 1);
      const bStats = computeRangeStats(bucketCursor, bEnd);
      const avgDailyHours = Math.round((bStats.minutes / len / 60) * 10) / 10;
      const startDt = parseUtc(bucketCursor);
      const endDt = parseUtc(bEnd);
      const sLabel = `${monthShortNames[startDt.getUTCMonth()]} ${String(startDt.getUTCDate()).padStart(2, '0')}`;
      const eLabel = `${monthShortNames[endDt.getUTCMonth()]} ${String(endDt.getUTCDate()).padStart(2, '0')}`;
      thirtyPoints.push({
        dateKey: bEnd,
        short: idx === bucketSizes.length - 1 ? 'Now' : `P${idx + 1}`,
        label: `${sLabel} – ${eLabel}`,
        hours: avgDailyHours,
        minutes: bStats.minutes,
        qs: bStats.qs,
        acc: bStats.accRounded,
      });
      bucketCursor = shiftKey(bEnd, 1);
    });
    const stats30d = computeRangeStats(thirtyStart, todayKey);
    const prevStats30d = computeRangeStats(prevThirtyStart, prevThirtyEnd);
    const consistency30d = Math.min(100, Math.round((stats30d.activeDays / 30) * 100));
    const readiness30d = Math.round(
      0.4 * coveragePct + 0.4 * stats30d.accRounded + 0.2 * consistency30d
    );

    const ds30d: AnalyticsTimeframeDataset = {
      readinessPct: readiness30d,
      projectedScore,
      percentile: getPercentileLabel(projectedScore),
      delta: computeDeltaLabel(stats30d.accExact, prevStats30d.accExact),
      subcopy: getSubcopy(projectedScore, stats30d.accExact),
      coveragePct,
      accuracyPct: stats30d.accRounded,
      consistencyPct: consistency30d,
      completedUnits: completedStreamUnits,
      totalUnits: totalStreamUnits,
      assessmentsCount: countAttemptsInRange(thirtyStart, todayKey),
      dailyGoalMinutes,
      activeDays: stats30d.activeDays,
      windowDays: 30,
      footerHours: `${stats30d.hoursExact.toFixed(1)} hrs`,
      footerAcc: `${stats30d.accExact.toFixed(1)}%`,
      footerQs: `${stats30d.qs} Qs`,
      points: thirtyPoints,
    };

    // 3) All Term dataset (trailing 7 calendar months ending this month)
    const todayDt = parseUtc(todayKey);
    const termPoints: AnalyticsTrendPoint[] = [];
    for (let mOffset = 6; mOffset >= 0; mOffset--) {
      const mStart = new Date(
        Date.UTC(todayDt.getUTCFullYear(), todayDt.getUTCMonth() - mOffset, 1)
      );
      const mEnd =
        mOffset === 0
          ? todayDt
          : new Date(
              Date.UTC(todayDt.getUTCFullYear(), todayDt.getUTCMonth() - mOffset + 1, 0)
            );
      const sKey = mStart.toISOString().slice(0, 10);
      const eKey = mEnd.toISOString().slice(0, 10);
      const daysInSlice = Math.max(1, Math.round((mEnd.getTime() - mStart.getTime()) / 86400000) + 1);
      const mStats = computeRangeStats(sKey, eKey);
      const mName = monthShortNames[mStart.getUTCMonth()];
      termPoints.push({
        dateKey: eKey,
        short: mName,
        label: `${mName} ${mStart.getUTCFullYear()}`,
        hours: Math.round((mStats.minutes / daysInSlice / 60) * 10) / 10,
        minutes: mStats.minutes,
        qs: mStats.qs,
        acc: mStats.accRounded,
      });
    }

    let termMinutes = 0;
    let termQs = 0;
    let termCorrect = 0;
    let termActiveDays = 0;
    for (const act of activityMap.values()) {
      if (act.minutes > 0 || act.questions > 0) {
        termActiveDays++;
        termMinutes += act.minutes;
        termQs += act.questions;
        termCorrect += act.correct;
      }
    }
    const termHoursExact = Math.round((termMinutes / 60) * 10) / 10;
    const termAccExact = termQs > 0 ? Math.round((termCorrect / termQs) * 1000) / 10 : 0;
    const termAccRounded = Math.round(termAccExact);
    const effectiveTermWindow = Math.max(28, termActiveDays);
    const consistencyTerm = Math.min(
      100,
      Math.round((termActiveDays / effectiveTermWindow) * 100)
    );
    const readinessTerm = Math.round(
      0.4 * coveragePct + 0.4 * termAccRounded + 0.2 * consistencyTerm
    );

    const dsTerm: AnalyticsTimeframeDataset = {
      readinessPct: readinessTerm,
      projectedScore,
      percentile: getPercentileLabel(projectedScore),
      delta: computeDeltaLabel(termAccExact, 0),
      subcopy: getSubcopy(projectedScore, termAccExact),
      coveragePct,
      accuracyPct: termAccRounded,
      consistencyPct: consistencyTerm,
      completedUnits: completedStreamUnits,
      totalUnits: totalStreamUnits,
      assessmentsCount: attempts.length,
      dailyGoalMinutes,
      activeDays: termActiveDays,
      windowDays: effectiveTermWindow,
      footerHours: `${termHoursExact.toFixed(1)} hrs`,
      footerAcc: `${termAccExact.toFixed(1)}%`,
      footerQs: `${termQs} Qs`,
      points: termPoints,
    };

    // Derive live streak (max of stored streak vs consecutive active days ending today/yesterday)
    let liveStreak = 0;
    let streakCursor = activityMap.has(todayKey) && (activityMap.get(todayKey)?.minutes ?? 0) > 0
      ? todayKey
      : shiftKey(todayKey, -1);
    while (true) {
      const act = activityMap.get(streakCursor);
      if (!act || act.minutes <= 0) break;
      liveStreak++;
      streakCursor = shiftKey(streakCursor, -1);
      if (liveStreak > 365) break;
    }

    const currentStreak = Math.max(progress?.streak?.currentStreak || 0, liveStreak);
    const longestStreak = Math.max(progress?.streak?.longestStreak || 0, currentStreak);

    return {
      stream,
      dailyGoalMinutes,
      streak: {
        currentStreak,
        longestStreak,
      },
      timeframes: {
        '7d': ds7d,
        '30d': ds30d,
        term: dsTerm,
      },
      heatmapDays,
      simulatorSubjects,
    };
  }
}
