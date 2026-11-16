import { Response } from 'express';
import { CurriculumService } from './curriculum.service';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
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

  public static async getOfflinePack(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const userId = req.user!.id;
    const unitId = req.params.unitId as string;
    const pack = await CurriculumService.getOfflinePack(userId, unitId);
    return sendSuccess(res, pack, 200);
  }
}
