import { Router } from 'express';
import { healthRoutes } from '../modules/health/health.routes';
import { authRoutes } from '../modules/auth/auth.routes';
import { curriculumRoutes } from '../modules/curriculum/curriculum.routes';
import assessmentRoutes from '../modules/assessments/assessment.routes';
import progressRoutes from '../modules/progress/progress.routes';

const router = Router();

// Health and Diagnostics
router.use('/health', healthRoutes);

// Authentication & Identity
router.use('/auth', authRoutes);

// Curriculum & Question Bank
router.use('/curriculum', curriculumRoutes);

// Assessments & Scoring
router.use('/assessments', assessmentRoutes);

// Student Progress & Analytics
router.use('/progress', progressRoutes);

export const v1Routes = router;
