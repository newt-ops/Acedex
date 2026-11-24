import { Router } from 'express';
import { healthRoutes } from '../modules/health/health.routes';
import { authRoutes } from '../modules/auth/auth.routes';
import { curriculumRoutes } from '../modules/curriculum/curriculum.routes';
import assessmentRoutes from '../modules/assessments/assessment.routes';
import progressRoutes from '../modules/progress/progress.routes';
import { studyRoutes } from '../modules/study/study.routes';
import { adsRoutes } from '../modules/ads/ads.routes';
import adminRoutes from '../modules/admin/admin.routes';
import { collectorRoutes } from '../modules/collector/collector.routes';
import notesCollectorRoutes from '../modules/notes-collector/notes-collector.routes';

const router = Router();

// Health and Diagnostics
router.use('/health', healthRoutes);

// Authentication & Identity
router.use('/auth', authRoutes);

// Curriculum & Question Bank
router.use('/curriculum', curriculumRoutes);

// Assessments & Scoring
router.use('/assessments', assessmentRoutes);

// Study Management & Unit Tracking
router.use('/study', studyRoutes);

// Student Progress & Analytics
router.use('/progress', progressRoutes);

// Rewarded Ads & Monetization
router.use('/ads', adsRoutes);

// Administration & Management (Protected with RBAC)
router.use('/admin', adminRoutes);

// Temporary Subject Question Collector & Exporter
router.use('/collector', collectorRoutes);

// Quick Notes Collector & Ingestion Portal
router.use('/notes-collector', notesCollectorRoutes);

export const v1Routes = router;
