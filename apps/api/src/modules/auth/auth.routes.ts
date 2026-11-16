import { Router } from 'express';
import {
  GoogleAuthRequestSchema,
  RefreshTokenRequestSchema,
  PhoneRegisterRequestSchema,
  PhoneLoginRequestSchema,
  ChangePinRequestSchema,
} from '@acedex/contracts';
import { AuthController } from './auth.controller';
import { validate } from '../../middleware/validate';
import { requireAuth } from '../../middleware/auth.middleware';
import { asyncHandler } from '../../common/utils/async-handler';

const router = Router();

// Student Phone & PIN Authentication
router.post(
  '/register-phone',
  validate({ body: PhoneRegisterRequestSchema }),
  asyncHandler(AuthController.registerPhone)
);

router.post(
  '/login-phone',
  validate({ body: PhoneLoginRequestSchema }),
  asyncHandler(AuthController.loginPhone)
);

router.post(
  '/change-pin',
  requireAuth,
  validate({ body: ChangePinRequestSchema }),
  asyncHandler(AuthController.changePin)
);

// Staff & Admin Google OAuth
router.post(
  '/google',
  validate({ body: GoogleAuthRequestSchema }),
  asyncHandler(AuthController.google)
);

// Shared Session Management
router.post(
  '/refresh',
  validate({ body: RefreshTokenRequestSchema }),
  asyncHandler(AuthController.refresh)
);

router.post('/logout', asyncHandler(AuthController.logout));

router.get('/me', requireAuth, AuthController.me);

export const authRoutes = router;
