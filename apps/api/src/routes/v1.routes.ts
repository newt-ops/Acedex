import { Router } from 'express';
import { healthRoutes } from '../modules/health/health.routes';
import { authRoutes } from '../modules/auth/auth.routes';

const router = Router();

// Health and Diagnostics
router.use('/health', healthRoutes);

// Authentication & Identity
router.use('/auth', authRoutes);
// router.use('/curriculum', curriculumRoutes);
// router.use('/assessments', assessmentRoutes);
// router.use('/progress', progressRoutes);

export const v1Routes = router;
