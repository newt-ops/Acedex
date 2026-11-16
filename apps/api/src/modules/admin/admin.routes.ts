import { Router } from 'express';
import { z } from 'zod';
import { AdminController } from './admin.controller';
import { AdminAdsController } from '../ads/admin-ads.controller';
import { requireAuth, requireRole } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate';
import { asyncHandler } from '../../common/utils/async-handler';
import { PublicationStatusSchema } from '@acedex/contracts';

const router = Router();

// Guard all admin routes with authentication and role check
router.use(requireAuth);
router.use(requireRole('admin', 'super_admin'));

// GET /api/v1/admin/dashboard - High-level metrics
router.get('/dashboard', AdminController.getDashboard);

// Question Bank Ingestion & Review
router.post('/question-bank/preview', AdminController.previewQuestionBank);
router.post('/question-bank/import', AdminController.importQuestionBank);

// Unit Publication Status Management
router.patch(
  '/units/:unitId/status',
  validate({
    body: z.object({
      status: PublicationStatusSchema,
    }),
  }),
  AdminController.updateUnitStatus
);

// Student Account Management
router.get('/students', AdminController.listStudents);
router.patch(
  '/students/:studentId/status',
  validate({
    body: z.object({
      status: z.enum(['active', 'suspended']),
    }),
  }),
  AdminController.updateStudentStatus
);

// Rewarded Ads Analytics & Remote Configuration
router.get('/ads/analytics', asyncHandler(AdminAdsController.getAnalytics));
router.get('/ads/sessions', asyncHandler(AdminAdsController.getSessions));
router.get('/ads/config', asyncHandler(AdminAdsController.getConfig));
router.put('/ads/config', asyncHandler(AdminAdsController.updateConfig));

// System Audit Logs
router.get('/audit-logs', AdminController.listAuditLogs);

export default router;
