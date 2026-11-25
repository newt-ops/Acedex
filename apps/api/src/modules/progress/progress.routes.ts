import { Router } from 'express';
import { ProgressController } from './progress.controller';
import { requireAuth } from '../../middleware/auth.middleware';

const router = Router();

// All progress endpoints require student authentication
router.use(requireAuth);

// GET /api/v1/progress/overview - overall stats, streak, subject mastery
router.get('/overview', ProgressController.getOverview);

// GET /api/v1/progress/analytics - live readiness, trends, 28-day heatmap, and simulator baselines
router.get('/analytics', ProgressController.getAnalytics);

// GET /api/v1/progress/subjects/:subjectCode - unit-by-unit progress for a subject
router.get('/subjects/:subjectCode', ProgressController.getSubjectProgress);

export default router;
