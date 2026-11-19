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
} from '@acedex/contracts';
import { NotFoundError } from '../../common/errors/app-error';
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

    logger.info(
      { userId: userId.toString(), unitCode: unit.code, status, isCompleted },
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
}
