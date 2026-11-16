import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { ProgressService } from '../progress/progress.service';
import { sendSuccess } from '../../common/utils/response';
import { StudyStatus } from '@acedex/contracts';

export class StudyController {
  /**
   * Updates study status for a specific unit (e.g. 'completed', 'in_progress', 'not_started')
   */
  public static async updateUnitStatus(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const userId = req.user!.id;
    const unitId = req.params.unitId as string;
    const { status } = req.body as { status: StudyStatus };

    const result = await ProgressService.updateUnitStudyStatus(userId, unitId, status);
    return sendSuccess(res, result);
  }

  /**
   * Convenience 1-tap shortcut to mark a unit as finished/completed
   */
  public static async completeUnit(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const userId = req.user!.id;
    const unitId = req.params.unitId as string;

    const result = await ProgressService.updateUnitStudyStatus(userId, unitId, 'completed');
    return sendSuccess(res, result);
  }

  /**
   * Returns unit-by-unit study checklist and exam unlock status for a subject
   */
  public static async getSubjectStudyProgress(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const userId = req.user!.id;
    const subjectCode = req.params.subjectCode as string;
    const grade = req.query.grade ? Number(req.query.grade) : undefined;

    const result = await ProgressService.getSubjectStudyProgress(userId, subjectCode, grade);
    return sendSuccess(res, result);
  }

  /**
   * Returns overall study completion overview across enrolled subjects
   */
  public static async getStudyOverview(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const userId = req.user!.id;

    const result = await ProgressService.getStudyOverview(userId);
    return sendSuccess(res, result);
  }
}
