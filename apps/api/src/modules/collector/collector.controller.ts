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

      const profile = await CollectorService.login(contributorId);
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
      const contributorId = (req.query.contributorId as string) || '';

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
   * Contributor submits 15 questions for a unit
   * POST /api/v1/collector/units/:unitCode/submit
   */
  public static async submitUnit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const unitCode = req.params.unitCode as string;
      const { contributorId, questions, rawPastedText } = req.body;

      if (!contributorId) {
        throw new BadRequestError('contributorId is required in request body');
      }

      if (!questions || !Array.isArray(questions) || questions.length !== 15) {
        throw new BadRequestError('questions array with exactly 15 questions is required');
      }

      const submission = await CollectorService.submitUnitQuestions(
        unitCode,
        contributorId,
        questions,
        rawPastedText
      );

      res.status(201).json({
        success: true,
        data: {
          unitCode: submission.unitCode,
          status: submission.status,
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
   * Admin: Lists all submissions
   * GET /api/v1/collector/admin/submissions
   */
  public static async listSubmissions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { subjectCode, status, grade } = req.query;
      const list = await CollectorService.listAdminSubmissions({
        subjectCode: subjectCode as string,
        status: status as string,
        grade: grade ? Number(grade) : undefined,
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
   * Admin: Approve submission
   * POST /api/v1/collector/admin/submissions/:id/approve
   */
  public static async approveSubmission(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const authReq = req as AuthenticatedRequest;
      const adminUserId = authReq.user?.id || 'admin';

      const approved = await CollectorService.approveSubmission(id, adminUserId);

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

      const rejected = await CollectorService.rejectSubmission(id, adminUserId, notes);

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
      const fileData = await CollectorService.exportUnitJson(id);

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
}
