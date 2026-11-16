import { Types } from 'mongoose';
import {
  StudentProgressModel,
  IStudentProgressDocument,
  IProgressUnitSubdoc,
} from './models/student-progress.model';
import { UnitModel } from '../curriculum/models/unit.model';
import { SubjectModel } from '../curriculum/models/subject.model';
import { AssessmentAttemptModel } from '../assessments/models/assessment-attempt.model';
import { StudentProgressOverview, StudentAdStatusData } from '@acedex/contracts';
import { logger } from '../../common/utils/logger';

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

    // Format subject mastery with full names
    const subjectMasteryList = progress.subjectMastery.map((sm) => ({
      subjectCode: sm.subjectCode,
      subjectName: subjectMap.get(sm.subjectCode) || sm.subjectCode,
      unitsCompleted: sm.unitsCompleted,
      totalUnits: sm.totalUnits,
      masteryPercentage: sm.masteryPercentage,
    }));

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
   * Returns current ad monetization status for student
   */
  public static async getStudentAdStatus(userId: string | Types.ObjectId): Promise<StudentAdStatusData> {
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
      await progress.save();
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
}
