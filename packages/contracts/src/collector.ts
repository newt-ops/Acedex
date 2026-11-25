import { z } from 'zod';
import { RawQuestionItem } from './curriculum';

// ==========================================
// Question & Quick Note Collector Contracts
// ==========================================

export const ContributorLoginRequestSchema = z.object({
  contributorId: z.string().min(3, 'Contributor ID must be at least 3 characters').trim(),
});
export type ContributorLoginRequest = z.infer<typeof ContributorLoginRequestSchema>;

export interface ContributorProfile {
  contributorId: string;
  name: string;
  subjectCode: string;
  subjectName: string;
  role?: 'student' | 'admin';
}

export const UnitSubmissionStatusSchema = z.enum([
  'not_started',
  'submitted',
  'approved',
  'rejected',
]);
export type UnitSubmissionStatus = z.infer<typeof UnitSubmissionStatusSchema>;

export interface CollectorUnitProgressItem {
  unitCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  status: UnitSubmissionStatus;
  questionCount?: number;
  submittedAt?: string;
  approvedAt?: string;
  reviewNotes?: string;
}

export interface CollectorSubjectUnitsResponse {
  subjectCode: string;
  subjectName: string;
  contributorId: string;
  totalUnits: number;
  approvedUnits: number;
  submittedUnits: number;
  grades: {
    grade: number;
    units: CollectorUnitProgressItem[];
  }[];
}

export const CollectorQuestionSubmissionItemSchema = z.object({
  id: z.string().optional(),
  type: z.string().default('multiple_choice'),
  difficulty: z.string().default('medium'),
  question: z.string().min(1, 'Question text cannot be empty'),
  options: z
    .array(
      z.object({
        id: z.string().min(1),
        text: z.string().min(1, 'Option text cannot be empty'),
      })
    )
    .length(4, 'Exactly 4 options (A, B, C, D) are required'),
  correctOptionId: z.string().min(1),
  explanation: z.string().min(1, 'Explanation cannot be empty'),
  sourceReference: z.string().optional(),
});
export type CollectorQuestionSubmissionItem = z.infer<
  typeof CollectorQuestionSubmissionItemSchema
>;

export const SubmitUnitQuestionsRequestSchema = z.object({
  unitCode: z.string().optional(),
  contributorId: z.string().min(3, 'contributorId must be at least 3 characters'),
  questions: z
    .array(CollectorQuestionSubmissionItemSchema)
    .length(15, 'Must contain exactly 15 questions')
    .optional(),
  rawPastedText: z.string().optional(),
});
export type SubmitUnitQuestionsRequest = z.infer<typeof SubmitUnitQuestionsRequestSchema>;

export const SanitizeQuestionsRequestSchema = z.object({
  rawText: z.string().min(1, 'Raw text cannot be empty'),
  expectedUnitCode: z.string().optional(),
});
export type SanitizeQuestionsRequest = z.infer<typeof SanitizeQuestionsRequestSchema>;

export const AdminReviewSubmissionRequestSchema = z.object({
  action: z.enum(['approve', 'reject']),
  notes: z.string().optional(),
});
export type AdminReviewSubmissionRequest = z.infer<typeof AdminReviewSubmissionRequestSchema>;

export interface CollectorAdminSubmissionSummary {
  _id: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  contributorId: string;
  questionCount: number;
  status: UnitSubmissionStatus;
  submittedAt: string;
  reviewedAt?: string;
  reviewNotes?: string;
}

export interface CollectorAdminSubmissionDetail extends CollectorAdminSubmissionSummary {
  questions: RawQuestionItem[];
  rawPastedText?: string;
}

// --- Quick Note Collector & Ingestion ---

export const CollectorNoteFormulaSchema = z.object({
  label: z.string().min(1, 'Formula label is required'),
  expr: z.string().min(1, 'Formula expression is required'),
});
export type CollectorNoteFormula = z.infer<typeof CollectorNoteFormulaSchema>;

export const CollectorNoteDefinitionSchema = z.object({
  term: z.string().min(1, 'Term is required'),
  definition: z.string().min(1, 'Definition is required'),
});
export type CollectorNoteDefinition = z.infer<typeof CollectorNoteDefinitionSchema>;

export const CollectorNoteItemSchema = z.object({
  grade: z.number().int().min(9).max(12),
  subject: z.string().min(1, 'Subject is required'),
  subjectCode: z.string().min(2).max(5),
  unitNumber: z.number().int().min(1),
  unitCode: z.string().min(5),
  unitTitle: z.string().min(1, 'Unit title is required'),
  examWeight: z.string().optional(),
  summaryPoints: z.array(z.string().min(1)).min(2, 'At least 2 summary points are required'),
  formulas: z.array(CollectorNoteFormulaSchema).default([]),
  examTip: z.string().min(1, 'Exam tip is required'),
  keyDefinitions: z.array(CollectorNoteDefinitionSchema).default([]),
  eueeFocusTopics: z.array(z.string().min(1)).default([]),
});
export type CollectorNoteItem = z.infer<typeof CollectorNoteItemSchema>;

export const SubmitUnitNoteRequestSchema = z.object({
  unitCode: z.string().min(5),
  contributorId: z.string().min(3, 'Contributor ID must be at least 3 characters'),
  notes: CollectorNoteItemSchema.optional(),
  rawPastedText: z.string().optional(),
});
export type SubmitUnitNoteRequest = z.infer<typeof SubmitUnitNoteRequestSchema>;

export const SubmitGradeNotesRequestSchema = z.object({
  grade: z.number().int().min(9).max(12),
  subjectCode: z.string().min(2).max(5),
  contributorId: z.string().min(3, 'Contributor ID must be at least 3 characters'),
  notes: z.array(CollectorNoteItemSchema).optional(),
  rawPastedText: z.string().optional(),
});
export type SubmitGradeNotesRequest = z.infer<typeof SubmitGradeNotesRequestSchema>;

export const SanitizeNoteRequestSchema = z.object({
  rawText: z.string().min(1, 'Raw text cannot be empty'),
  expectedUnitCode: z.string().optional(),
});
export type SanitizeNoteRequest = z.infer<typeof SanitizeNoteRequestSchema>;

export const AdminReviewNoteRequestSchema = z.object({
  action: z.enum(['approve', 'reject']),
  notes: z.string().optional(),
});
export type AdminReviewNoteRequest = z.infer<typeof AdminReviewNoteRequestSchema>;

export interface CollectorNoteUnitProgressItem {
  unitCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  status: UnitSubmissionStatus;
  summaryPointCount?: number;
  formulaCount?: number;
  definitionCount?: number;
  submittedAt?: string;
  approvedAt?: string;
  reviewNotes?: string;
}

export interface CollectorNoteSubjectUnitsResponse {
  subjectCode: string;
  subjectName: string;
  contributorId: string;
  totalUnits: number;
  approvedUnits: number;
  submittedUnits: number;
  grades: {
    grade: number;
    units: CollectorNoteUnitProgressItem[];
  }[];
}

export interface CollectorNoteSubmissionSummary {
  _id: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  unitNumber: number;
  unitTitle: string;
  contributorId: string;
  status: UnitSubmissionStatus;
  summaryPointCount: number;
  formulaCount: number;
  definitionCount: number;
  submittedAt: string;
  reviewedAt?: string;
  reviewNotes?: string;
}

export interface CollectorNoteSubmissionDetail extends CollectorNoteSubmissionSummary {
  note: CollectorNoteItem;
  rawPastedText?: string;
}

export interface NoteSanitizeResult {
  success: boolean;
  errors?: string[];
  warnings?: string[];
  fixesApplied?: string[];
  autoFixedIssues?: string[];
  note?: CollectorNoteItem;
  notes?: CollectorNoteItem[];
  unitCount?: number;
}
