import { z } from 'zod';

// ==========================================
// Study Management & Unit Tracking Contracts
// ==========================================

export const StudyStatusSchema = z.enum(['not_started', 'in_progress', 'completed']);
export type StudyStatus = z.infer<typeof StudyStatusSchema>;

export const UpdateUnitStudyStatusSchema = z.object({
  status: StudyStatusSchema,
});
export type UpdateUnitStudyStatusRequest = z.infer<typeof UpdateUnitStudyStatusSchema>;

export interface UnitStudyProgressItem {
  unitId: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  title: string;
  studyStatus: StudyStatus;
  isStudyCompleted: boolean;
  isExamUnlocked: boolean;
  studyCompletedAt?: string;
  bestScore?: number;
  bestPercentage?: number;
  passed?: boolean;
  attemptsCount?: number;
  coinsAwarded?: number;
  newCoinBalance?: number;
}

export interface SubjectStudyProgressResponse {
  subjectCode: string;
  subjectName: string;
  grade: number;
  totalUnits: number;
  completedUnits: number;
  inProgressUnits: number;
  completionPercentage: number;
  units: UnitStudyProgressItem[];
}

export interface StudyOverviewResponse {
  totalUnits: number;
  completedUnits: number;
  inProgressUnits: number;
  completionPercentage: number;
  subjects: Array<{
    subjectCode: string;
    subjectName: string;
    grade: number;
    totalUnits: number;
    completedUnits: number;
    completionPercentage: number;
  }>;
}
