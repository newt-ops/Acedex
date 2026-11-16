import { Router } from 'express';
import { AdsController } from './ads.controller';
import { requireAuth, optionalAuth } from '../../middleware/auth.middleware';
import { asyncHandler } from '../../common/utils/async-handler';

const router = Router();

// Public / optional auth routes
router.get('/config', optionalAuth, asyncHandler(AdsController.getConfig));
router.get('/unity/callback', asyncHandler(AdsController.handleUnityS2SCallback));

// Authenticated student routes
router.get('/status', requireAuth, asyncHandler(AdsController.getStudentStatus));
router.post('/session/start', requireAuth, asyncHandler(AdsController.startSession));
router.post('/reward/claim', requireAuth, asyncHandler(AdsController.claimReward));

export const adsRoutes = router;
