import { Router } from 'express';
import { healthRoutes } from '../modules/health/health.routes';

const router = Router();

// Health and Diagnostics
router.use('/health', healthRoutes);

// Modular Mounts (Prepared for Phase 2+)
// router.use('/auth', authRoutes);
// router.use('/curriculum', curriculumRoutes);
// router.use('/assessments', assessmentRoutes);
// router.use('/progress', progressRoutes);

export const v1Routes = router;
