import { Request, Response, NextFunction } from 'express';
import { ProgressService } from './progress.service';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { UnauthorizedError } from '../../common/errors/app-error';

export class ProgressController {
  public static async getOverview(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const overview = await ProgressService.getOverview(authReq.user.id);

      res.status(200).json({
        success: true,
        data: overview,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async getSubjectProgress(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const subjectCode = req.params.subjectCode as string;
      const grade = req.query.grade
        ? parseInt(req.query.grade as string, 10)
        : authReq.user.grade || 9;

      const progress = await ProgressService.getSubjectProgress(
        authReq.user.id,
        subjectCode,
        grade
      );

      res.status(200).json({
        success: true,
        data: progress,
      });
    } catch (err) {
      next(err);
    }
  }
}
