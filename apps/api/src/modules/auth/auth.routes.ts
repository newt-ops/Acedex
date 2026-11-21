import { Router } from 'express';
import {
  RefreshTokenRequestSchema,
  PhoneRegisterRequestSchema,
  PhoneLoginRequestSchema,
  ChangePinRequestSchema,
  UpdateProfileRequestSchema,
} from '@acedex/contracts';
import { AuthController } from './auth.controller';
import { validate } from '../../middleware/validate';
import { requireAuth } from '../../middleware/auth.middleware';
import { asyncHandler } from '../../common/utils/async-handler';

const router = Router();

// Student Phone & PIN Authentication
router.get('/check-phone', asyncHandler(AuthController.checkPhone));

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

// Shared Session Management
router.post(
  '/refresh',
  validate({ body: RefreshTokenRequestSchema }),
  asyncHandler(AuthController.refresh)
);

router.post('/logout', asyncHandler(AuthController.logout));

router.get('/me', requireAuth, asyncHandler(AuthController.me));

router.patch(
  '/profile',
  requireAuth,
  validate({ body: UpdateProfileRequestSchema }),
  asyncHandler(AuthController.updateProfile)
);

router.patch(
  '/me',
  requireAuth,
  validate({ body: UpdateProfileRequestSchema }),
  asyncHandler(AuthController.updateProfile)
);

export const authRoutes = router;
