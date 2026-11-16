import { Types } from 'mongoose';
import {
  StudentProgressModel,
  IStudentProgressDocument,
  IProgressUnitSubdoc,
} from './models/student-progress.model';
import { UnitModel } from '../curriculum/models/unit.model';
import { SubjectModel } from '../curriculum/models/subject.model';
import { AssessmentAttemptModel } from '../assessments/models/assessment-attempt.model';
import { StudentProgressOverview } from '@acedex/contracts';
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
}
