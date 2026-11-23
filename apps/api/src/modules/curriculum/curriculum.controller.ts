import { Response } from 'express';
import { Types } from 'mongoose';
import { CurriculumService } from './curriculum.service';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { StudentProgressModel } from '../progress/models/student-progress.model';
import { UnitModel } from './models/unit.model';
import { QuestionModel } from './models/question.model';
import { sendSuccess } from '../../common/utils/response';
import { BadRequestError } from '../../common/errors/app-error';
import { StudentStream } from '@acedex/contracts';

export class CurriculumController {
  public static getGrades(_req: AuthenticatedRequest, res: Response): Response {
    const grades = CurriculumService.getGrades();
    return sendSuccess(res, grades, 200);
  }

  public static async getSubjects(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const gradeQuery = req.query.grade ? parseInt(req.query.grade as string, 10) : undefined;
    const grade = gradeQuery || req.user?.grade;

    // Stream can come from query param or authenticated user profile
    const streamQuery = req.query.stream as StudentStream | undefined;
    const stream = streamQuery || req.user?.stream || null;

    const subjects = await CurriculumService.getSubjects(grade, stream);
    return sendSuccess(res, subjects, 200);
  }

  public static async getUnits(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const gradeStr = req.query.grade as string;
    const subjectCode = req.query.subject as string;

    if (!gradeStr || !subjectCode) {
      throw new BadRequestError('Query parameters "grade" and "subject" are required');
    }

    const grade = parseInt(gradeStr, 10);
    if (isNaN(grade) || grade < 9 || grade > 12) {
      throw new BadRequestError('Grade must be an integer between 9 and 12');
    }

    // Admins can see all units, students only published units
    const isStaff = req.user?.role === 'admin' || req.user?.role === 'super_admin';
    const units = await CurriculumService.getUnits(grade, subjectCode, !isStaff);

    // If authenticated as a student, decorate with study tracking and exam unlock status
    const studentId = req.user?.id;
    if (studentId && !isStaff) {
      const progress = await StudentProgressModel.findOne({ userId: new Types.ObjectId(studentId) });
      const studentUnitMap = new Map((progress?.units || []).map((u) => [u.unitCode, u]));
      const decorated = units.map((u: any) => {
        const record = studentUnitMap.get(u.code);
        const isCompleted = record ? record.isStudyCompleted === true : false;
        const studyStatus = record
          ? record.studyStatus || (isCompleted ? 'completed' : 'not_started')
          : 'not_started';
        return {
          ...u,
          studyStatus,
          isStudyCompleted: isCompleted,
          isExamUnlocked: isCompleted,
          bestScore: record ? record.bestScore : 0,
          bestPercentage: record ? record.bestPercentage : 0,
          passed: record ? record.passed : false,
        };
      });
      return sendSuccess(res, decorated, 200);
    }

    return sendSuccess(res, units, 200);
  }

  public static async getUnitById(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const unitId = req.params.unitId as string;
    const unit = await CurriculumService.getUnitById(unitId);
    return sendSuccess(res, unit, 200);
  }

  public static async getQuestionsForUnit(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const unitId = req.params.unitId as string;
    const isStaff = req.user?.role === 'admin' || req.user?.role === 'super_admin';
    const questions = await CurriculumService.getQuestionsForUnit(unitId, !isStaff);

    return sendSuccess(
      res,
      questions,
      200,
      { total: questions.length }
    );
  }

  public static async getUnitAssessment(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const unitId = req.params.unitId as string;
    const questions = await CurriculumService.getAssessmentQuestionsForUnit(unitId);
    return sendSuccess(
      res,
      questions,
      200,
      { total: questions.length }
    );
  }

  public static async getOfflinePack(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const userId = req.user!.id;
    const unitId = req.params.unitId as string;
    const pack = await CurriculumService.getOfflinePack(userId, unitId);
    return sendSuccess(res, pack, 200);
  }

  public static async bookmarkQuestion(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const userId = req.user!.id;
    const questionId = req.params.questionId as string;
    const notes = req.body?.notes as string | undefined;

    const result = await CurriculumService.bookmarkQuestion(userId, questionId, notes);
    return sendSuccess(res, result, 201);
  }

  public static async removeBookmark(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const userId = req.user!.id;
    const questionId = req.params.questionId as string;

    const removed = await CurriculumService.removeBookmark(userId, questionId);
    return sendSuccess(res, { removed }, 200);
  }

  public static async listBookmarks(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const userId = req.user!.id;
    const subjectCode = req.query.subject as string | undefined;
    const gradeStr = req.query.grade as string | undefined;
    const grade = gradeStr ? parseInt(gradeStr, 10) : undefined;

    const bookmarks = await CurriculumService.listBookmarks(userId, { subjectCode, grade });
    return sendSuccess(res, bookmarks, 200);
  }

  public static async getModelExam(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const subjectCode = req.params.subjectCode as string;
    const gradeStr = req.query.grade as string | undefined;
    const countStr = req.query.count as string | undefined;

    const grade = gradeStr ? parseInt(gradeStr, 10) : 12;
    const count = countStr ? parseInt(countStr, 10) : 50;

    const session = await CurriculumService.generateModelExam(subjectCode, grade, count);
    return sendSuccess(res, session, 200);
  }

  public static async getExamCountdown(
    _req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const targetDate = new Date('2026-06-08T06:00:00.000Z'); // June 8, 2026 (09:00 EAT)
    const now = new Date();
    const remainingMs = Math.max(0, targetDate.getTime() - now.getTime());
    const totalMinutes = Math.floor(remainingMs / (1000 * 60));
    const days = Math.floor(totalMinutes / (24 * 60));
    const hours = Math.floor((totalMinutes % (24 * 60)) / 60);
    const minutes = totalMinutes % 60;

    return sendSuccess(
      res,
      {
        targetDate: targetDate.toISOString(),
        label: 'EUEE 2026 Examination',
        academicYear: 2026,
        serverTime: now.toISOString(),
        totalMinutes,
        days,
        hours,
        minutes,
      },
      200
    );
  }

  public static async getCurriculumPulse(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const totalUnits = await UnitModel.countDocuments(); // 237 across G9-12
    const publishedUnits = await UnitModel.countDocuments({ isPublished: true }); // 237 published
    const totalQuestions = await QuestionModel.countDocuments(); // 3,555 questions

    let unitsMastered = 0;
    let accuracy = 0.0;
    let focusMinutes = 45;
    let standingPercentile = 5;
    let standingXp = 2480;

    const studentId = req.user?.id;
    if (studentId) {
      const progress = await StudentProgressModel.findOne({
        userId: new Types.ObjectId(studentId),
      });
      if (progress) {
        unitsMastered = (progress.units || []).filter(
          (u) => u.passed || u.isStudyCompleted
        ).length;
        accuracy = progress.overallStats.averageScore || 0;
        focusMinutes = Math.round(
          (progress.overallStats.totalTimeSpentSeconds || 0) / 60
        );
        standingXp = (progress as any).xp || 2480;
      }
    }

    return sendSuccess(
      res,
      {
        totalUnits,
        publishedUnits,
        totalQuestions,
        unitsMastered,
        accuracy,
        focusMinutes,
        standingPercentile,
        standingXp,
      },
      200
    );
  }
}
