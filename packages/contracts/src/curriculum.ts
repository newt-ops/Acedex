import { z } from 'zod';

// ==========================================
// Curriculum, Publication, Question Banks & Bookmarks
// ==========================================

export const PublicationStatusSchema = z.enum([
  'draft',
  'in_review',
  'published',
  'archived',
]);
export type PublicationStatus = z.infer<typeof PublicationStatusSchema>;

export const QuestionDifficultySchema = z.enum(['easy', 'medium', 'challenging']);
export type QuestionDifficulty = z.infer<typeof QuestionDifficultySchema>;

export const QuestionOptionSchema = z.object({
  id: z.enum(['A', 'B', 'C', 'D']),
  text: z.string().min(1, 'Option text cannot be empty'),
});
export type QuestionOption = z.infer<typeof QuestionOptionSchema>;

export const QuestionIdRegex = /^[A-Z]{3}-G(09|10|11|12)-U\d{2}-Q\d{3}$/;

export const RawQuestionItemSchema = z.object({
  id: z
    .string()
    .regex(
      QuestionIdRegex,
      'Question ID must follow pattern AAA-Gxx-Uxx-Qxxx (e.g. PHY-G09-U01-Q001)'
    ),
  type: z.literal('multiple_choice'),
  difficulty: QuestionDifficultySchema,
  question: z.string().min(1, 'Question text cannot be empty'),
  options: z.array(QuestionOptionSchema).length(4, 'Exactly 4 options (A, B, C, D) are required'),
  correctOptionId: z.enum(['A', 'B', 'C', 'D']),
  explanation: z.string().min(1, 'Explanation cannot be empty'),
  sourceReference: z.string().optional(),
});
export type RawQuestionItem = z.infer<typeof RawQuestionItemSchema>;

export const QuestionBankFileSchema = z.object({
  grade: z.number().int().min(9).max(12),
  subject: z.string().min(1, 'Subject name is required'),
  unitNumber: z.number().int().positive('Unit number must be positive'),
  unitTitle: z.string().min(1, 'Unit title is required'),
  questions: z
    .array(RawQuestionItemSchema)
    .length(15, 'Each approved unit must contain exactly 15 questions'),
});
export type QuestionBankFile = z.infer<typeof QuestionBankFileSchema>;

// Student-facing Question (Correct answer & explanation sanitized)
export interface PublicQuestionItem {
  id: string;
  type: 'multiple_choice';
  difficulty: QuestionDifficulty;
  question: string;
  options: QuestionOption[];
}

export const CreateBookmarkRequestSchema = z.object({
  notes: z.string().max(500, 'Notes cannot exceed 500 characters').optional(),
});
export type CreateBookmarkRequest = z.infer<typeof CreateBookmarkRequestSchema>;

export interface BookmarkedQuestionItem {
  bookmarkId: string;
  questionId: string;
  externalId: string;
  unitId: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  question: string;
  difficulty: QuestionDifficulty;
  options: QuestionOption[];
  correctOptionId?: 'A' | 'B' | 'C' | 'D';
  explanation?: string;
  notes?: string;
  bookmarkedAt: string;
}

export interface BookmarkListResponse {
  total: number;
  bookmarks: BookmarkedQuestionItem[];
}

export interface ModelExamQuestionItem extends PublicQuestionItem {
  unitCode: string;
  unitTitle: string;
  unitNumber: number;
}

export interface ModelExamSessionResponse {
  examSessionId: string;
  subjectCode: string;
  subjectName: string;
  grade: number;
  totalQuestions: number;
  timeLimitMinutes: number;
  questions: ModelExamQuestionItem[];
}
