import { Response } from 'express';
import {
  AiCalibrationInput,
  UpdateTopicProgressRequest,
} from '@acedex/contracts';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { TopicsService } from './topics.service';
import { sendSuccess } from '../../common/utils/response';

export class TopicsController {
  /**
   * GET /api/v1/topics/program
   * Returns saved AI study program (if any) and 0%-baseline subject topic mastery summaries
   */
  public static async getProgramOverview(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const data = await TopicsService.getProgramOverview(req.user!.id);
    return sendSuccess(res, data, 200);
  }

  /**
   * POST /api/v1/topics/program
   * Generates a personalized AI cross-grade topic program using Gemini + Topic Bank and saves it
   */
  public static async generateAndSaveProgram(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const calibration = req.body as AiCalibrationInput;
    const data = await TopicsService.generateAndSaveProgram(req.user!.id, calibration);
    return sendSuccess(res, data, 200);
  }

  /**
   * GET /api/v1/topics/subjects/:subjectCode/modules
   * Lists sequential cross-grade modules with textbook reading pointers and student completion state
   */
  public static async getSubjectModules(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const subjectCode = req.params.subjectCode as string;
    const modules = await TopicsService.getSubjectModules(req.user!.id, subjectCode);
    return sendSuccess(res, modules, 200);
  }

  /**
   * POST /api/v1/topics/modules/:moduleId/progress
   * Toggles a learning sequence step or marks an entire cross-grade module mastered
   */
  public static async updateModuleProgress(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const moduleId = req.params.moduleId as string;
    const payload = req.body as UpdateTopicProgressRequest;
    const result = await TopicsService.updateModuleProgress(
      req.user!.id,
      moduleId,
      payload
    );
    return sendSuccess(res, result, 200);
  }
}
