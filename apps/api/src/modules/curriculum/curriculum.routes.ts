import { Router } from 'express';
import { CurriculumController } from './curriculum.controller';
import { requireAuth, optionalAuth } from '../../middleware/auth.middleware';
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
router.get(
  '/units/:unitId/offline-pack',
  requireAuth,
  asyncHandler(CurriculumController.getOfflinePack)
);

// Live Dashboard Metrics
router.get('/exam-countdown', asyncHandler(CurriculumController.getExamCountdown));
router.get('/pulse', optionalAuth, asyncHandler(CurriculumController.getCurriculumPulse));

// EUEE Subject Model Exam Generator
router.get(
  '/subjects/:subjectCode/model-exam',
  optionalAuth,
  asyncHandler(CurriculumController.getModelExam)
);

// Question Bookmarks / Saved Questions
router.post(
  '/questions/:questionId/bookmark',
  requireAuth,
  asyncHandler(CurriculumController.bookmarkQuestion)
);

router.delete(
  '/questions/:questionId/bookmark',
  requireAuth,
  asyncHandler(CurriculumController.removeBookmark)
);

router.get(
  '/bookmarks',
  requireAuth,
  asyncHandler(CurriculumController.listBookmarks)
);

export const curriculumRoutes = router;
