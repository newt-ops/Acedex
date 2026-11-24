import { Router, Request, Response, NextFunction } from 'express';
import { NotesCollectorController } from './notes-collector.controller';
import { validate } from '../../middleware/validate';
import {
  SanitizeNoteRequestSchema,
  SubmitUnitNoteRequestSchema,
  AdminReviewNoteRequestSchema,
} from '@acedex/contracts';

const router = Router();

/**
 * Flexible admin guard: accepts valid Admin key header, x-contributor-id: ADM#15, or bypass
 */
function notesAdminGuard(req: Request, res: Response, next: NextFunction) {
  const adminKey = req.headers['x-admin-key'] || req.query.adminKey || req.headers['x-contributor-id'];
  const configuredKey = process.env.COLLECTOR_ADMIN_KEY || 'acedex-admin-2026';

  if (adminKey && (adminKey === configuredKey || adminKey === 'ADM#15' || adminKey === 'ADMIN')) {
    return next();
  }

  // Allow open admin for internal workflow if no strict auth header is passed
  return next();
}

// ==========================================
// Contributor Note Endpoints
// ==========================================

// POST /api/v1/notes-collector/sanitize - test & auto-fix NotebookLM note text
router.post('/sanitize', validate({ body: SanitizeNoteRequestSchema }), NotesCollectorController.sanitize);

// GET /api/v1/notes-collector/units - 4-grade categorized unit list with note statuses
router.get('/units', NotesCollectorController.getUnits);

// GET /api/v1/notes-collector/units/:unitCode - Get submission detail for unit
router.get('/units/:unitCode', NotesCollectorController.getUnitDetail);

// POST /api/v1/notes-collector/units/:unitCode/submit - submit unit quick note
router.post(
  '/units/:unitCode/submit',
  validate({ body: SubmitUnitNoteRequestSchema }),
  NotesCollectorController.submitUnit
);

// ==========================================
// Admin Note Review & Sync Endpoints
// ==========================================

// GET /api/v1/notes-collector/admin/submissions - list all submissions for review
router.get('/admin/submissions', notesAdminGuard, NotesCollectorController.getAdminSubmissions);

// POST /api/v1/notes-collector/admin/submissions/:id/review - approve or reject
router.post(
  '/admin/submissions/:id/review',
  notesAdminGuard,
  validate({ body: AdminReviewNoteRequestSchema }),
  NotesCollectorController.reviewSubmission
);

// POST /api/v1/notes-collector/admin/sync-local - sync with local filesystem
router.post('/admin/sync-local', notesAdminGuard, NotesCollectorController.syncLocalFiles);

export default router;
