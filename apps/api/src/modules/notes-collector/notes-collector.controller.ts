import { Request, Response, NextFunction } from 'express';
import { NotesCollectorService } from './notes-collector.service';
import { NoteSanitizerService } from './services/note-sanitizer.service';
import { BadRequestError, NotFoundError } from '../../common/errors/app-error';

export class NotesCollectorController {
  public static async sanitize(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { rawText, expectedUnitCode } = req.body;
      const targetUnit = Array.isArray(expectedUnitCode) ? expectedUnitCode[0] : expectedUnitCode;
      const result = NoteSanitizerService.sanitize(rawText, targetUnit ? String(targetUnit) : undefined);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async getUnits(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const rawSubj = req.query.subjectCode;
      const subjectCode = (Array.isArray(rawSubj) ? rawSubj[0] : rawSubj) as string || 'ENG';
      const rawContrib = req.query.contributorId || req.headers['x-contributor-id'];
      const contributorId = (Array.isArray(rawContrib) ? rawContrib[0] : rawContrib) as string || 'GUEST';

      const data = await NotesCollectorService.getUnits(String(subjectCode), String(contributorId));
      res.status(200).json({
        success: true,
        data,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async getUnitDetail(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const unitCode = String(req.params.unitCode);
      const detail = await NotesCollectorService.getUnitDetail(unitCode);

      if (!detail) {
        throw new NotFoundError(`No submission found for unit ${unitCode}`);
      }

      res.status(200).json({
        success: true,
        data: detail,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async submitUnit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const unitCode = String(req.params.unitCode);
      const { contributorId, rawPastedText, notes } = req.body;
      const rawEffectiveId = contributorId || req.headers['x-contributor-id'] || 'GUEST';
      const effectiveContributorId = String(Array.isArray(rawEffectiveId) ? rawEffectiveId[0] : rawEffectiveId);

      if (!unitCode) {
        throw new BadRequestError('Unit code is required');
      }

      const submission = await NotesCollectorService.submitUnitNote(
        unitCode,
        effectiveContributorId,
        rawPastedText,
        notes
      );

      res.status(201).json({
        success: true,
        data: submission,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async submitGradeNotes(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { grade, subjectCode, contributorId, rawPastedText, notes } = req.body;
      const rawEffectiveId = contributorId || req.headers['x-contributor-id'] || 'GUEST';
      const effectiveContributorId = String(Array.isArray(rawEffectiveId) ? rawEffectiveId[0] : rawEffectiveId);

      if (!grade || !subjectCode) {
        throw new BadRequestError('Grade and subjectCode are required');
      }

      const result = await NotesCollectorService.submitGradeNotes(
        Number(grade),
        String(subjectCode),
        effectiveContributorId,
        rawPastedText,
        notes
      );

      res.status(201).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async getAdminSubmissions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { status, subjectCode, grade } = req.query;
      const data = await NotesCollectorService.getAdminSubmissions({
        status: typeof status === 'string' ? status : undefined,
        subjectCode: typeof subjectCode === 'string' ? subjectCode : undefined,
        grade: grade ? parseInt(String(grade), 10) : undefined,
      });

      res.status(200).json({
        success: true,
        data,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async reviewSubmission(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = String(req.params.id);
      const { action, notes } = req.body;
      const rawAdminKey = req.headers['x-admin-key'] || 'ADMIN';
      const adminUserId = String(Array.isArray(rawAdminKey) ? rawAdminKey[0] : rawAdminKey);

      if (!action || !['approve', 'reject'].includes(action)) {
        throw new BadRequestError('Action must be either "approve" or "reject"');
      }

      const updated = await NotesCollectorService.reviewSubmission(id, adminUserId, action, notes);
      res.status(200).json({
        success: true,
        data: updated,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async syncLocalFiles(_req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await NotesCollectorService.syncLocalFiles();
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async seedMainDatabase(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { subjectCode, grade } = req.body || {};
      const result = await NotesCollectorService.seedAllApprovedToMainDb({
        subjectCode: typeof subjectCode === 'string' ? subjectCode : undefined,
        grade: grade ? Number(grade) : undefined,
      });

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  public static async exportGradeNotes(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { subjectCode, grade, status, download } = req.query;

      if (!subjectCode || !grade) {
        throw new BadRequestError('subjectCode and grade are required');
      }

      const result = await NotesCollectorService.getGradeNotesForExport(
        String(subjectCode),
        parseInt(String(grade), 10),
        typeof status === 'string' ? status : undefined
      );

      if (download === 'true') {
        const gStr = result.grade.toString().padStart(2, '0');
        const filename = `${result.subjectName}-Grade-${gStr}-Notes.json`.replace(/\s+/g, '-');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.send(JSON.stringify(result.notes, null, 2));
        return;
      }

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }
}
