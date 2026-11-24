import { Router } from 'express';
import {
  AiCalibrationInputSchema,
  UpdateTopicProgressSchema,
} from '@acedex/contracts';
import { requireAuth } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate';
import { asyncHandler } from '../../common/utils/async-handler';
import { TopicsController } from './topics.controller';

const router = Router();

// All cross-grade AI topic endpoints require an authenticated student
router.use(requireAuth);

// GET /api/v1/topics/program - Fetch saved AI study program & 0%-baseline subject summaries
router.get('/program', asyncHandler(TopicsController.getProgramOverview));

// POST /api/v1/topics/program - Generate & persist Gemini + Topic Bank study program
router.post(
  '/program',
  validate({ body: AiCalibrationInputSchema }),
  asyncHandler(TopicsController.generateAndSaveProgram)
);

// GET /api/v1/topics/subjects/:subjectCode/modules - Ordered cross-grade modules + page refs
router.get(
  '/subjects/:subjectCode/modules',
  asyncHandler(TopicsController.getSubjectModules)
);

// POST /api/v1/topics/modules/:moduleId/progress - Save step or full module completion
router.post(
  '/modules/:moduleId/progress',
  validate({ body: UpdateTopicProgressSchema }),
  asyncHandler(TopicsController.updateModuleProgress)
);

export const topicsRoutes = router;
export default router;
