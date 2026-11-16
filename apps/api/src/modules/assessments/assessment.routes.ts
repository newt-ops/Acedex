import { Router } from 'express';
import { AssessmentController } from './assessment.controller';
import { requireAuth } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate';
import { AssessmentSubmissionSchema } from '@acedex/contracts';

const router = Router();

// All assessment endpoints require authentication
router.use(requireAuth);

// POST /api/v1/assessments/submit - submit answers for grading
router.post(
  '/submit',
  validate({ body: AssessmentSubmissionSchema }),
  AssessmentController.submit
);

// GET /api/v1/assessments/history - student's past attempts
router.get('/history', AssessmentController.getHistory);

// GET /api/v1/assessments/unit/:unitId/summary - unit performance summary
router.get('/unit/:unitId/summary', AssessmentController.getUnitSummary);

// GET /api/v1/assessments/:attemptId - specific attempt details & review
router.get('/:attemptId', AssessmentController.getAttemptById);

export default router;
