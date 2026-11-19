import { Request, Response, NextFunction } from 'express';
import { CollectorService } from './collector.service';
import { JsonSanitizerService } from './services/sanitizer.service';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { BadRequestError } from '../../common/errors/app-error';

export class CollectorController {
  /**
   * Contributor Login (ID only)
   * POST /api/v1/collector/login
   */
  public static async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { contributorId } = req.body;
      if (!contributorId || typeof contributorId !== 'string') {
        throw new BadRequestError('contributorId is required');
      }

      const clientIp = req.ip || req.socket.remoteAddress;
      const profile = await CollectorService.login(contributorId, clientIp);
      res.status(200).json({
        success: true,
        data: profile,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get current contributor profile
   * GET /api/v1/collector/profile?contributorId=GEO#982
   */
  public static async getProfile(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const contributorId = (req.query.contributorId as string) || (req.headers['x-contributor-id'] as string);
      if (!contributorId) {
        throw new BadRequestError('contributorId query parameter or x-contributor-id header is required');
      }

      const profile = await CollectorService.getProfile(contributorId);
      res.status(200).json({
        success: true,
        data: profile,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Get all units for a subject across all 4 grades
   * GET /api/v1/collector/units?subjectCode=GEO&contributorId=GEO#982
   */
  public static async getUnits(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const subjectCode = (req.query.subjectCode as string) || '';
      const contributorId = (req.query.contributorId as string) || (req.headers['x-contributor-id'] as string) || '';

      if (!subjectCode) {
        throw new BadRequestError('subjectCode query parameter is required (e.g. GEO, PHY)');
      }

      const result = await CollectorService.getSubjectUnitTree(subjectCode, contributorId);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Contributor or Admin: Get unit submission details
   * GET /api/v1/collector/units/:unitCode
   */
  public static async getUnitDetail(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const unitCode = req.params.unitCode as string;
      const detail = await CollectorService.getSubmissionDetail(unitCode);
      res.status(200).json({
        success: true,
        data: detail,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Contributor submits 15 questions for a unit
   * POST /api/v1/collector/units/:unitCode/submit
   */
  public static async submitUnit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const unitCode = req.params.unitCode as string;
      let { contributorId, questions, rawPastedText } = req.body;

      if (!contributorId) {
        contributorId = req.headers['x-contributor-id'] as string;
      }

      if (!contributorId) {
        throw new BadRequestError('contributorId is required in request body or x-contributor-id header');
      }

      // Resilient fallback: auto-sanitize rawPastedText if questions is missing or empty
      if ((!questions || !Array.isArray(questions) || questions.length === 0) && rawPastedText) {
        const sanitized = JsonSanitizerService.sanitize(rawPastedText, unitCode);
        if (!sanitized.success || !sanitized.questions || sanitized.questions.length !== 15) {
          const errMsg =
            (sanitized.errors && sanitized.errors.join('; ')) ||
            'Could not extract exactly 15 valid questions from pasted text';
          throw new BadRequestError(errMsg);
        }
        questions = sanitized.questions;
      }

      if (!questions || !Array.isArray(questions) || questions.length !== 15) {
        throw new BadRequestError('questions array with exactly 15 questions is required');
      }

      const clientIp = req.ip || req.socket.remoteAddress;
      const submission = await CollectorService.submitUnitQuestions(
        unitCode,
        contributorId,
        questions,
        rawPastedText,
        clientIp
      );

      res.status(201).json({
        success: true,
        data: {
          unitCode: submission.unitCode,
          status: submission.status,
          version: submission.version,
          submittedAt: submission.submittedAt,
          questionCount: submission.questions.length,
        },
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Resiliently cleans and tests raw NotebookLM text
   * POST /api/v1/collector/sanitize
   */
  public static async sanitize(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { rawText, expectedUnitCode } = req.body;
      if (!rawText || typeof rawText !== 'string') {
        throw new BadRequestError('rawText string is required');
      }

      const result = JsonSanitizerService.sanitize(rawText, expectedUnitCode);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Overall collection statistics across subjects
   * GET /api/v1/collector/admin/stats
   */
  public static async getAdminStats(_req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await CollectorService.getAdminStats();
      res.status(200).json({
        success: true,
        data: stats,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Lists all submissions
   * GET /api/v1/collector/admin/submissions
   */
  public static async listSubmissions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { subjectCode, status, grade, contributorId } = req.query;
      const list = await CollectorService.listAdminSubmissions({
        subjectCode: subjectCode as string,
        status: status as string,
        grade: grade ? Number(grade) : undefined,
        contributorId: contributorId as string,
      });

      res.status(200).json({
        success: true,
        data: list,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Get submission detail with questions
   * GET /api/v1/collector/admin/submissions/:id
   */
  public static async getSubmission(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const detail = await CollectorService.getSubmissionDetail(id);

      res.status(200).json({
        success: true,
        data: detail,
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: In-place edit of questions in a unit
   * PATCH /api/v1/collector/admin/submissions/:id/questions
   */
  public static async updateQuestions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const { questions } = req.body;
      const authReq = req as AuthenticatedRequest;
      const adminUserId = authReq.user?.id || 'admin';
      const clientIp = req.ip || req.socket.remoteAddress;

      const updated = await CollectorService.updateSubmissionQuestions(id, adminUserId, questions, clientIp);

      res.status(200).json({
        success: true,
        data: {
          unitCode: updated.unitCode,
          questionsCount: updated.questions.length,
          status: updated.status,
        },
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Approve submission
   * POST /api/v1/collector/admin/submissions/:id/approve
   */
  public static async approveSubmission(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const authReq = req as AuthenticatedRequest;
      const adminUserId = authReq.user?.id || 'admin';
      const clientIp = req.ip || req.socket.remoteAddress;

      const approved = await CollectorService.approveSubmission(id, adminUserId, clientIp);

      res.status(200).json({
        success: true,
        data: {
          unitCode: approved.unitCode,
          status: approved.status,
          reviewedAt: approved.reviewedAt,
        },
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Reject submission
   * POST /api/v1/collector/admin/submissions/:id/reject
   */
  public static async rejectSubmission(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const { notes } = req.body;
      const authReq = req as AuthenticatedRequest;
      const adminUserId = authReq.user?.id || 'admin';
      const clientIp = req.ip || req.socket.remoteAddress;

      const rejected = await CollectorService.rejectSubmission(id, adminUserId, notes, clientIp);

      res.status(200).json({
        success: true,
        data: {
          unitCode: rejected.unitCode,
          status: rejected.status,
          reviewNotes: rejected.reviewNotes,
        },
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Export formatted QuestionBankFile JSON
   * GET /api/v1/collector/admin/submissions/:id/export
   */
  public static async exportJson(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const authReq = req as AuthenticatedRequest;
      const actorId = authReq.user?.id || 'admin';
      const clientIp = req.ip || req.socket.remoteAddress;

      const fileData = await CollectorService.exportUnitJson(id, actorId, clientIp);

      res.setHeader('Content-Type', 'application/json');
      res.setHeader(
        'Content-Disposition',
        `attachment; filename="${id.includes('-') ? id : 'unit'}.json"`
      );
      res.status(200).json(fileData);
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Export all approved units for a subject
   * GET /api/v1/collector/admin/export/subject/:subjectCode
   */
  public static async exportSubject(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const subjectCode = req.params.subjectCode as string;
      const authReq = req as AuthenticatedRequest;
      const actorId = authReq.user?.id || 'admin';

      const fileData = await CollectorService.exportSubjectUnits(subjectCode, actorId);

      res.setHeader('Content-Type', 'application/json');
      res.setHeader(
        'Content-Disposition',
        `attachment; filename="${subjectCode.toUpperCase()}_approved_units.json"`
      );
      res.status(200).json(fileData);
    } catch (err) {
      next(err);
    }
  }

  /**
   * Admin: Get audit logs
   * GET /api/v1/collector/admin/audit-logs
   */
  public static async getAuditLogs(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const limit = req.query.limit ? Number(req.query.limit) : 50;
      const offset = req.query.offset ? Number(req.query.offset) : 0;

      const logs = await CollectorService.listAuditLogs(limit, offset);
      res.status(200).json({
        success: true,
        data: logs,
      });
    } catch (err) {
      next(err);
    }
  }
}
