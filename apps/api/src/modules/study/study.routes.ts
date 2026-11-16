import { Router } from 'express';
import { StudyController } from './study.controller';
import { requireAuth } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate';
import { asyncHandler } from '../../common/utils/async-handler';
import { UpdateUnitStudyStatusSchema } from '@acedex/contracts';

const router = Router();

// All study management endpoints require an authenticated student
router.use(requireAuth);

// POST /api/v1/study/units/:unitId/status - update study status
router.post(
  '/units/:unitId/status',
  validate({ body: UpdateUnitStudyStatusSchema }),
  asyncHandler(StudyController.updateUnitStatus)
);

// POST /api/v1/study/units/:unitId/complete - 1-tap mark unit as finished
router.post(
  '/units/:unitId/complete',
  asyncHandler(StudyController.completeUnit)
);

// GET /api/v1/study/subjects/:subjectCode - subject study checklist & exam statuses
router.get(
  '/subjects/:subjectCode',
  asyncHandler(StudyController.getSubjectStudyProgress)
);

// GET /api/v1/study/overview - student study overview & completion metrics
router.get(
  '/overview',
  asyncHandler(StudyController.getStudyOverview)
);

export const studyRoutes = router;
export default router;
