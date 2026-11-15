import { Router } from 'express';
import {
  GoogleAuthRequestSchema,
  RefreshTokenRequestSchema,
} from '@acedex/contracts';
import { AuthController } from './auth.controller';
import { validate } from '../../middleware/validate';
import { requireAuth } from '../../middleware/auth.middleware';
import { asyncHandler } from '../../common/utils/async-handler';

const router = Router();

router.post(
  '/google',
  validate({ body: GoogleAuthRequestSchema }),
  asyncHandler(AuthController.google)
);

router.post(
  '/refresh',
  validate({ body: RefreshTokenRequestSchema }),
  asyncHandler(AuthController.refresh)
);

router.post('/logout', asyncHandler(AuthController.logout));

router.get('/me', requireAuth, AuthController.me);

export const authRoutes = router;
