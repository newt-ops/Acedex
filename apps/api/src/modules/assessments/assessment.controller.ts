import { Request, Response, NextFunction } from 'express';
import { AssessmentService } from './assessment.service';
import { AssessmentSubmission } from '@acedex/contracts';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { UnauthorizedError } from '../../common/errors/app-error';

export class AssessmentController {
  public static async submit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const submission = req.body as AssessmentSubmission;
      const result = await AssessmentService.submitAssessment(authReq.user.id, submission);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async getHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const unitId = req.query.unitId as string | undefined;
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;

      const result = await AssessmentService.getAttemptHistory(
        authReq.user.id,
        unitId,
        page,
        limit
      );

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async getAttemptById(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const attemptId = req.params.attemptId as string;
      const result = await AssessmentService.getAttemptById(authReq.user.id, attemptId);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async getUnitSummary(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const unitId = req.params.unitId as string;
      const result = await AssessmentService.getUnitSummary(authReq.user.id, unitId);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }
}
