import { Request, Response, NextFunction } from 'express';
import { AdminService } from './admin.service';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { PublicationStatus } from '@acedex/contracts';
import { UnauthorizedError } from '../../common/errors/app-error';

export class AdminController {
  public static async getDashboard(
    _req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const stats = await AdminService.getDashboardStats();
      res.status(200).json({
        success: true,
        data: stats,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async previewQuestionBank(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const result = AdminService.previewQuestionBank(req.body);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async importQuestionBank(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const result = await AdminService.importQuestionBank(req.body, authReq.user.id);
      res.status(201).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async updateUnitStatus(
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
      const status = req.body.status as PublicationStatus;

      const unit = await AdminService.updateUnitStatus(unitId, status, authReq.user.id);
      res.status(200).json({
        success: true,
        data: {
          unitId: unit._id.toString(),
          unitCode: unit.code,
          status: unit.status,
          isPublished: unit.isPublished,
        },
      });
    } catch (err) {
      next(err);
    }
  }

  public static async listStudents(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const search = req.query.search as string | undefined;
      const grade = req.query.grade ? parseInt(req.query.grade as string, 10) : undefined;
      const stream = req.query.stream as string | undefined;
      const status = req.query.status as string | undefined;
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;

      const result = await AdminService.listStudents({
        search,
        grade,
        stream,
        status,
        page,
        limit,
      });

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async updateStudentStatus(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const authReq = req as AuthenticatedRequest;
      if (!authReq.user) {
        throw new UnauthorizedError('Authentication required');
      }
      const studentId = req.params.studentId as string;
      const status = req.body.status as 'active' | 'suspended';

      const student = await AdminService.updateStudentStatus(
        studentId,
        status,
        authReq.user.id
      );

      res.status(200).json({
        success: true,
        data: {
          id: student._id.toString(),
          acedexId: student.acedexId,
          displayName: student.displayName,
          status: student.status,
        },
      });
    } catch (err) {
      next(err);
    }
  }

  public static async listAuditLogs(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const action = req.query.action as string | undefined;
      const resource = req.query.resource as string | undefined;
      const userId = req.query.userId as string | undefined;
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;

      const result = await AdminService.listAuditLogs({
        action,
        resource,
        userId,
        page,
        limit,
      });

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }
}
