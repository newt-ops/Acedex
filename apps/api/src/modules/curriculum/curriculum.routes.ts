import { Router } from 'express';
import { CurriculumController } from './curriculum.controller';
import { optionalAuth } from '../../middleware/auth.middleware';
import { asyncHandler } from '../../common/utils/async-handler';

const router = Router();

router.get('/grades', CurriculumController.getGrades);
router.get('/subjects', optionalAuth, asyncHandler(CurriculumController.getSubjects));
router.get('/units', optionalAuth, asyncHandler(CurriculumController.getUnits));
router.get('/units/:unitId', asyncHandler(CurriculumController.getUnitById));
router.get(
  '/units/:unitId/questions',
  optionalAuth,
  asyncHandler(CurriculumController.getQuestionsForUnit)
);

export const curriculumRoutes = router;
