import { z } from 'zod';
import {
  StudentStream,
  SubjectStreamCategory,
  SubjectStreamCategorySchema,
} from './auth';
import { StudyStatus, StudyStatusSchema } from './study';

// ==========================================
// AI Cross-Grade Topic Study & Calibration Contracts
// ==========================================

export const AiTargetTierSchema = z.enum(['solid', 'competitive', 'merit']);
export type AiTargetTier = z.infer<typeof AiTargetTierSchema>;

export const AiPeakWindowSchema = z.enum(['Morning', 'Afternoon', 'Night']);
export type AiPeakWindow = z.infer<typeof AiPeakWindowSchema>;

export const AiPrepStageSchema = z.enum(['starting', 'reviewing', 'sprint']);
export type AiPrepStage = z.infer<typeof AiPrepStageSchema>;

export const AiCalibrationInputSchema = z.object({
  tierId: AiTargetTierSchema.default('competitive'),
  targetScore: z.number().int().min(400).max(600),
  weakSubjectCodes: z
    .array(z.string().min(2).max(5))
    .min(1, 'Select at least 1 priority subject')
    .max(3, 'Select at most 3 priority subjects'),
  dailyMinutes: z.number().int().min(15).max(600),
  peakWindow: AiPeakWindowSchema.default('Morning'),
  prepStageId: AiPrepStageSchema.default('reviewing'),
  adSessionId: z.string().min(1).optional(),
  useCoinPass: z.boolean().optional(),
});
export type AiCalibrationInput = z.infer<typeof AiCalibrationInputSchema>;

export const UpdateTopicProgressSchema = z.object({
  stepNumber: z.number().int().min(1).optional(),
  stepCompleted: z.boolean().optional(),
  isCompleted: z.boolean().optional(),
});
export type UpdateTopicProgressRequest = z.infer<typeof UpdateTopicProgressSchema>;

export const ToggleTopicUnitMasterySchema = z.object({
  completed: z.boolean(),
  moduleId: z.string().min(4).optional(),
});
export type ToggleTopicUnitMasteryRequest = z.infer<typeof ToggleTopicUnitMasterySchema>;

export interface TopicUnitMasteryResponse {
  unitCode: string;
  isStudyCompleted: boolean;
  studyStatus: StudyStatus;
  syncedStepNumbers: number[];
  coinsAwarded?: number;
  newCoinBalance?: number;
  updatedModule?: {
    moduleId: string;
    subjectCode: string;
    completedSteps: number[];
    isCompleted: boolean;
    progressPercentage: number;
  };
}

export const TopicReadingReferenceSchema = z.object({
  grade: z.number().int().min(9).max(12),
  unitNumber: z.number().int().min(1),
  unitCode: z.string().min(5),
  unitTitle: z.string().min(1),
  pages: z.string().min(1),
  hasQuickNotes: z.boolean().optional(),
  isUnitCompleted: z.boolean().optional(),
  studyStatus: StudyStatusSchema.optional(),
});
export type TopicReadingReference = z.infer<typeof TopicReadingReferenceSchema>;

export const TopicLearningStepSchema = z.object({
  stepNumber: z.number().int().min(1),
  text: z.string().min(1),
  grade: z.number().int().min(9).max(12).optional(),
  unitNumber: z.number().int().min(1).optional(),
  unitCode: z.string().min(5).optional(),
  pages: z.string().optional(),
});
export type TopicLearningStep = z.infer<typeof TopicLearningStepSchema>;

export const TopicModuleSeedSchema = z.object({
  moduleId: z.string().min(4),
  subjectCode: z.string().min(2).max(5),
  subjectName: z.string().min(2),
  streamCategory: SubjectStreamCategorySchema,
  moduleNumber: z.number().int().min(1),
  phase: z.string().min(1),
  title: z.string().min(1),
  rationale: z.string(),
  references: z.array(TopicReadingReferenceSchema),
  sequence: z.array(TopicLearningStepSchema),
  prerequisites: z.array(z.string()),
  masteryCheckpoint: z.string(),
  sourceFile: z.string(),
});
export type TopicModuleSeed = z.infer<typeof TopicModuleSeedSchema>;

export const SubjectTopicBankJsonSchema = z.object({
  schemaVersion: z.literal(1),
  subjectCode: z.string().min(2).max(5),
  subjectName: z.string().min(2),
  streamCategory: SubjectStreamCategorySchema,
  compiledAt: z.string().min(1),
  sourceFile: z.string().min(1),
  modules: z.array(TopicModuleSeedSchema).min(1),
});
export type SubjectTopicBankJson = z.infer<typeof SubjectTopicBankJsonSchema>;

export interface TopicModuleItem {
  moduleId: string;
  subjectCode: string;
  subjectName: string;
  streamCategory: SubjectStreamCategory;
  moduleNumber: number;
  phase: string;
  title: string;
  rationale: string;
  references: TopicReadingReference[];
  sequence: TopicLearningStep[];
  prerequisites: string[];
  masteryCheckpoint: string;
  completedSteps: number[];
  isCompleted: boolean;
  progressPercentage: number;
}

export interface AiSubjectAllocation {
  subjectCode: string;
  subjectName: string;
  priorityRank: number | null;
  weeklyMinutes: number;
  sharePercentage: number;
}

export interface AiDailyTaskItem {
  id: string;
  moduleId: string;
  subjectCode: string;
  subjectName: string;
  title: string;
  durationMinutes: number;
  priorityTag: string;
  whereToRead: string;
  coachingNote?: string;
}

export interface AiTopicSubjectSummary {
  subjectCode: string;
  subjectName: string;
  totalModules: number;
  completedModules: number;
  masteryPercentage: number;
  priorityRank: number | null;
  hasTopicBank: boolean;
}

export interface AiStudyProgram {
  calibration: AiCalibrationInput;
  stream: StudentStream;
  projectedScore: number;
  diagnosticSummary: string;
  subjectAllocations: AiSubjectAllocation[];
  dailyFocusTasks: AiDailyTaskItem[];
  modulePriorityBySubject: Record<string, string[]>;
  generatedBy: 'gemini' | 'deterministic';
  generatedDate?: string;
  generatedAt: string;
}

export interface AiTopicProgramOverviewResponse {
  hasProgram: boolean;
  canGenerateToday: boolean;
  requiresAd: boolean;
  nextGenerationAt?: string | null;
  program: AiStudyProgram | null;
  subjectSummaries: AiTopicSubjectSummary[];
}
