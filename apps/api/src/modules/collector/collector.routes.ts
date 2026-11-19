import { Router, Request, Response, NextFunction } from 'express';
import { CollectorController } from './collector.controller';
import { requireAuth, requireRole, AuthenticatedRequest } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate';
import {
  ContributorLoginRequestSchema,
  SanitizeQuestionsRequestSchema,
  SubmitUnitQuestionsRequestSchema,
} from '@acedex/contracts';

const router = Router();

/**
 * Flexible admin guard: accepts valid Admin JWT OR x-admin-key header OR x-contributor-id: ADM#15
 */
function collectorAdminGuard(req: Request, res: Response, next: NextFunction) {
  const adminKey = req.headers['x-admin-key'] || req.query.adminKey || req.headers['x-contributor-id'];
  const configuredKey = process.env.COLLECTOR_ADMIN_KEY || 'acedex-admin-2026';

  if (adminKey && (adminKey === configuredKey || adminKey === 'ADM#15')) {
    (req as AuthenticatedRequest).user = {
      id: 'collector-admin',
      acedexId: 'ACEDEX-ADMIN',
      displayName: 'Master Administrator',
      role: 'admin',
      status: 'active',
      authProvider: 'phone',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    return next();
  }

  // Fallback to standard Bearer token authentication
  return requireAuth(req, res, () => {
    return requireRole('admin', 'super_admin')(req, res, next);
  });
}

// ==========================================
// Contributor Endpoints
// ==========================================

// POST /api/v1/collector/login - ID-only login
router.post('/login', validate({ body: ContributorLoginRequestSchema }), CollectorController.login);

// GET /api/v1/collector/profile - Get profile by contributorId
router.get('/profile', CollectorController.getProfile);

// GET /api/v1/collector/units - 4-grade categorized unit list with statuses
router.get('/units', CollectorController.getUnits);

// GET /api/v1/collector/units/:unitCode - Get submission detail for unit
router.get('/units/:unitCode', CollectorController.getUnitDetail);

// POST /api/v1/collector/units/:unitCode/submit - submit 15 questions
router.post(
  '/units/:unitCode/submit',
  validate({ body: SubmitUnitQuestionsRequestSchema }),
  CollectorController.submitUnit
);

// POST /api/v1/collector/sanitize - test & auto-fix NotebookLM text
router.post(
  '/sanitize',
  validate({ body: SanitizeQuestionsRequestSchema }),
  CollectorController.sanitize
);

// ==========================================
// Admin Review, In-Place Edit & Export Endpoints
// ==========================================

// GET /api/v1/collector/admin/stats - Global statistics
router.get('/admin/stats', collectorAdminGuard, CollectorController.getAdminStats);

// GET /api/v1/collector/admin/submissions - list all submissions
router.get('/admin/submissions', collectorAdminGuard, CollectorController.listSubmissions);

// GET /api/v1/collector/admin/submissions/:id - full submission detail with questions
router.get('/admin/submissions/:id', collectorAdminGuard, CollectorController.getSubmission);

// PATCH /api/v1/collector/admin/submissions/:id/questions - in-place edit questions
router.patch('/admin/submissions/:id/questions', collectorAdminGuard, CollectorController.updateQuestions);

// POST /api/v1/collector/admin/submissions/:id/approve - approve unit
router.post('/admin/submissions/:id/approve', collectorAdminGuard, CollectorController.approveSubmission);

// POST /api/v1/collector/admin/submissions/:id/reject - reject with feedback
router.post('/admin/submissions/:id/reject', collectorAdminGuard, CollectorController.rejectSubmission);

// GET /api/v1/collector/admin/submissions/:id/export - download canonical unit JSON
router.get('/admin/submissions/:id/export', collectorAdminGuard, CollectorController.exportJson);

// GET /api/v1/collector/admin/export/subject/:subjectCode - download all approved units for subject
router.get('/admin/export/subject/:subjectCode', collectorAdminGuard, CollectorController.exportSubject);

// GET /api/v1/collector/admin/audit-logs - view audit log trail
router.get('/admin/audit-logs', collectorAdminGuard, CollectorController.getAuditLogs);

export const collectorRoutes = router;
