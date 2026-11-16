import { Types } from 'mongoose';
import crypto from 'crypto';
import {
  AssessmentSubmission,
  AssessmentResultData,
  GradedAnswerItem,
} from '@acedex/contracts';
import { UnitModel } from '../curriculum/models/unit.model';
import { QuestionModel } from '../curriculum/models/question.model';
import { AnswerKeyModel } from '../curriculum/models/answer-key.model';
import { AssessmentAttemptModel } from './models/assessment-attempt.model';
import { ProgressService } from '../progress/progress.service';
import { NotFoundError, BadRequestError } from '../../common/errors/app-error';
import { AuditService } from '../audit/audit.service';
import { logger } from '../../common/utils/logger';

export class AssessmentService {
  /**
   * Evaluates student answers strictly server-side against answer keys,
   * records the attempt, and updates student progress and streak.
   */
  public static async submitAssessment(
    userId: string,
    submission: AssessmentSubmission
  ): Promise<AssessmentResultData> {
    const userObjectId = new Types.ObjectId(userId);

    // 1. Resolve unit by ObjectId or Unit Code
    let unit = null;
    if (Types.ObjectId.isValid(submission.unitId)) {
      unit = await UnitModel.findById(submission.unitId);
    }
    if (!unit) {
      unit = await UnitModel.findOne({ code: submission.unitId.toUpperCase() });
    }

    if (!unit) {
      throw new NotFoundError(`Unit '${submission.unitId}' not found`);
    }

    // 2. Fetch all published questions for this unit
    const questions = await QuestionModel.find({
      unitId: unit._id,
      isPublished: true,
    });

    if (questions.length === 0) {
      throw new BadRequestError(`Unit '${unit.code}' has no published questions to assess`);
    }

    // 3. Fetch Answer Keys strictly server-side
    const questionIds = questions.map((q) => q._id);
    const answerKeys = await AnswerKeyModel.find({
      questionId: { $in: questionIds },
    });

    const keyByQuestionId = new Map(
      answerKeys.map((k) => [k.questionId.toString(), k])
    );
    const keyByExternalId = new Map(
      answerKeys.map((k) => [k.externalId, k])
    );
    const questionMap = new Map<string, any>();
    for (const q of questions) {
      questionMap.set(q._id.toString(), q);
      questionMap.set(q.externalId, q);
    }

    // 4. Grade answers
    const gradedAnswers: GradedAnswerItem[] = [];
    let score = 0;

    for (const ans of submission.answers) {
      const qDoc = questionMap.get(ans.questionId);
      if (!qDoc) {
        continue;
      }

      const answerKey =
        keyByQuestionId.get(qDoc._id.toString()) ||
        keyByExternalId.get(qDoc.externalId);

      if (!answerKey) {
        logger.error({ questionId: qDoc.externalId }, 'Answer key missing for question');
        continue;
      }

      const isCorrect =
        ans.selectedOptionId !== null &&
        ans.selectedOptionId === answerKey.correctOptionId;

      if (isCorrect) {
        score++;
      }

      gradedAnswers.push({
        questionId: qDoc._id.toString(),
        externalId: qDoc.externalId,
        selectedOptionId: ans.selectedOptionId,
        correctOptionId: answerKey.correctOptionId,
        isCorrect,
        explanation: answerKey.explanation,
      });
    }

    const totalQuestions = questions.length;
    const percentage = Math.round((score / totalQuestions) * 100 * 10) / 10;
    const passed = percentage >= 70;
    const attemptId = submission.attemptId || crypto.randomUUID();
    const durationSeconds = submission.durationSeconds || 0;

    // 5. Store Attempt Record
    const attemptDoc = await AssessmentAttemptModel.create({
      userId: userObjectId,
      unitId: unit._id,
      unitCode: unit.code,
      attemptId,
      score,
      totalQuestions,
      percentage,
      passed,
      durationSeconds,
      answers: gradedAnswers.map((g) => ({
        questionId: new Types.ObjectId(g.questionId),
        externalId: g.externalId,
        selectedOptionId: g.selectedOptionId,
        correctOptionId: g.correctOptionId,
        isCorrect: g.isCorrect,
        explanation: g.explanation,
      })),
      status: 'completed',
      completedAt: new Date(),
    });

    // 6. Update Student Progress & Streak
    await ProgressService.recordAttempt({
      userId: userObjectId,
      unit: {
        _id: unit._id,
        code: unit.code,
        subjectCode: unit.subjectCode,
        grade: unit.grade,
      },
      score,
      totalQuestions,
      percentage,
      passed,
      durationSeconds,
    });

    // 7. Audit log
    AuditService.record({
      action: 'ASSESSMENT_SUBMITTED',
      resource: 'assessments',
      resourceId: attemptDoc._id.toString(),
      userId: userId,
      details: {
        unitCode: unit.code,
        score,
        totalQuestions,
        percentage,
        passed,
      },
    });

    return {
      attemptId,
      unitId: unit._id.toString(),
      unitCode: unit.code,
      score,
      totalQuestions,
      percentage,
      passed,
      durationSeconds,
      answers: gradedAnswers,
      completedAt: attemptDoc.completedAt.toISOString(),
    };
  }

  /**
   * Retrieves previous attempts for the student with pagination
   */
  public static async getAttemptHistory(
    userId: string,
    unitId?: string,
    page: number = 1,
    limit: number = 20
  ) {
    const userObjectId = new Types.ObjectId(userId);
    const filter: Record<string, any> = { userId: userObjectId };

    if (unitId) {
      if (Types.ObjectId.isValid(unitId)) {
        filter.unitId = new Types.ObjectId(unitId);
      } else {
        filter.unitCode = unitId.toUpperCase();
      }
    }

    const skip = (page - 1) * limit;

    const [attempts, total] = await Promise.all([
      AssessmentAttemptModel.find(filter)
        .sort({ completedAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('-answers.explanation -answers.correctOptionId') // sanitize summary
        .lean(),
      AssessmentAttemptModel.countDocuments(filter),
    ]);

    return {
      items: attempts.map((a) => ({
        attemptId: a.attemptId,
        unitId: a.unitId.toString(),
        unitCode: a.unitCode,
        score: a.score,
        totalQuestions: a.totalQuestions,
        percentage: a.percentage,
        passed: a.passed,
        durationSeconds: a.durationSeconds,
        completedAt: a.completedAt.toISOString(),
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Retrieves full details of a specific past attempt, including questions and explanations
   */
  public static async getAttemptById(
    userId: string,
    attemptId: string
  ): Promise<AssessmentResultData> {
    const userObjectId = new Types.ObjectId(userId);

    const attempt = await AssessmentAttemptModel.findOne({
      userId: userObjectId,
      attemptId,
    }).lean();

    if (!attempt) {
      throw new NotFoundError(`Assessment attempt '${attemptId}' not found`);
    }

    return {
      attemptId: attempt.attemptId,
      unitId: attempt.unitId.toString(),
      unitCode: attempt.unitCode,
      score: attempt.score,
      totalQuestions: attempt.totalQuestions,
      percentage: attempt.percentage,
      passed: attempt.passed,
      durationSeconds: attempt.durationSeconds,
      answers: attempt.answers.map((a) => ({
        questionId: a.questionId.toString(),
        externalId: a.externalId,
        selectedOptionId: a.selectedOptionId as any,
        correctOptionId: a.correctOptionId as any,
        isCorrect: a.isCorrect,
        explanation: a.explanation,
      })),
      completedAt: attempt.completedAt.toISOString(),
    };
  }

  /**
   * Retrieves summary performance for a student on a specific unit
   */
  public static async getUnitSummary(userId: string, unitId: string) {
    const userObjectId = new Types.ObjectId(userId);

    let unit = null;
    if (Types.ObjectId.isValid(unitId)) {
      unit = await UnitModel.findById(unitId);
    }
    if (!unit) {
      unit = await UnitModel.findOne({ code: unitId.toUpperCase() });
    }

    if (!unit) {
      throw new NotFoundError(`Unit '${unitId}' not found`);
    }

    const attempts = await AssessmentAttemptModel.find({
      userId: userObjectId,
      unitId: unit._id,
    })
      .sort({ score: -1 })
      .lean();

    if (attempts.length === 0) {
      return {
        unitId: unit._id.toString(),
        unitCode: unit.code,
        hasAttempted: false,
        bestScore: 0,
        bestPercentage: 0,
        passed: false,
        totalAttempts: 0,
        latestAttemptAt: null,
      };
    }

    const bestAttempt = attempts[0];
    const latestAttempt = [...attempts].sort(
      (a, b) => b.completedAt.getTime() - a.completedAt.getTime()
    )[0];

    return {
      unitId: unit._id.toString(),
      unitCode: unit.code,
      hasAttempted: true,
      bestScore: bestAttempt.score,
      bestPercentage: bestAttempt.percentage,
      passed: attempts.some((a) => a.passed),
      totalAttempts: attempts.length,
      latestAttemptAt: latestAttempt.completedAt.toISOString(),
    };
  }
}
