import { z } from 'zod';

// ==========================================
// Assessment & Progress Contracts
// ==========================================

export const QuestionIdentifierRegex = /^([A-Z]{3}-G(09|10|11|12)-U\d{2}-Q\d{3}|[0-9a-fA-F]{24})$/;

export const SubmitAnswerItemSchema = z.object({
  questionId: z
    .string()
    .regex(
      QuestionIdentifierRegex,
      'questionId must be an external question ID or MongoDB ObjectId'
    ),
  selectedOptionId: z.enum(['A', 'B', 'C', 'D']).nullable(),
});
export type SubmitAnswerItem = z.infer<typeof SubmitAnswerItemSchema>;

export const AssessmentSubmissionSchema = z.object({
  unitId: z.string().min(1),
  attemptId: z.string().uuid().optional(),
  answers: z.array(SubmitAnswerItemSchema).min(1),
  startedAt: z.string().datetime().optional(),
  completedAt: z.string().datetime().optional(),
  durationSeconds: z.number().int().nonnegative().optional(),
});
export type AssessmentSubmission = z.infer<typeof AssessmentSubmissionSchema>;

export interface GradedAnswerItem {
  questionId: string;
  externalId: string;
  selectedOptionId: 'A' | 'B' | 'C' | 'D' | null;
  correctOptionId: 'A' | 'B' | 'C' | 'D';
  isCorrect: boolean;
  explanation: string;
}

export interface AssessmentResultData {
  attemptId: string;
  unitId: string;
  unitCode: string;
  score: number;
  totalQuestions: number;
  percentage: number;
  passed: boolean;
  durationSeconds: number;
  answers: GradedAnswerItem[];
  completedAt: string;
  coinsSpent?: number;
  coinsAwarded?: number;
  newCoinBalance?: number;
}

export interface StudentStreakData {
  currentStreak: number;
  longestStreak: number;
  lastActivityDate?: string;
}

export interface StudentProgressOverview {
  overallStats: {
    totalAssessmentsTaken: number;
    totalAssessmentsPassed: number;
    averageScore: number;
    totalTimeSpentSeconds: number;
  };
  streak: StudentStreakData;
  studyStats?: {
    totalUnits: number;
    completedUnits: number;
    inProgressUnits: number;
    completionPercentage: number;
  };
  subjectMastery: Array<{
    subjectCode: string;
    subjectName: string;
    unitsCompleted: number;
    totalUnits: number;
    masteryPercentage: number;
  }>;
  recentAttempts: Array<{
    attemptId: string;
    unitCode: string;
    score: number;
    totalQuestions: number;
    percentage: number;
    passed: boolean;
    completedAt: string;
  }>;
}
