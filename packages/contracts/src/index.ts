import { z } from 'zod';

// ==========================================
// 1. API Envelopes
// ==========================================

export interface ApiSuccessResponse<T> {
  success: true;
  data: T;
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
    totalPages?: number;
    [key: string]: unknown;
  };
}

export interface ApiErrorDetail {
  field?: string;
  message: string;
  code?: string;
}

export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: ApiErrorDetail[] | unknown;
    timestamp: string;
    path?: string;
  };
}

export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse;

// ==========================================
// 2. Health & System
// ==========================================

export type DatabaseConnectionState =
  | 'disconnected'
  | 'connected'
  | 'connecting'
  | 'disconnecting'
  | 'uninitialized';

export interface HealthCheckResponse {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  uptimeSeconds: number;
  environment: string;
  version: string;
  database: {
    status: DatabaseConnectionState;
    connected: boolean;
    name?: string;
    host?: string;
  };
  memory: {
    heapUsedMB: number;
    heapTotalMB: number;
    rssMB: number;
  };
}

// ==========================================
// 3. User & Authentication Contracts
// ==========================================

export const UserRoleSchema = z.enum([
  'student',
  'content_manager',
  'admin',
  'super_admin',
]);
export type UserRole = z.infer<typeof UserRoleSchema>;

export const AccountStatusSchema = z.enum([
  'active',
  'suspended',
  'pending_deletion',
]);
export type AccountStatus = z.infer<typeof AccountStatusSchema>;

export const AuthProviderSchema = z.enum(['google']);
export type AuthProvider = z.infer<typeof AuthProviderSchema>;

export const GoogleAuthRequestSchema = z.object({
  idToken: z.string().min(1, 'Google ID token is required'),
  platform: z.enum(['web', 'android', 'ios']).optional(),
});
export type GoogleAuthRequest = z.infer<typeof GoogleAuthRequestSchema>;

export const RefreshTokenRequestSchema = z.object({
  refreshToken: z.string().min(1).optional(),
});
export type RefreshTokenRequest = z.infer<typeof RefreshTokenRequestSchema>;

export interface AuthTokens {
  accessToken: string;
  refreshToken?: string;
  expiresIn: number; // in seconds
}

export interface AuthUserProfile {
  id: string;
  email: string;
  displayName: string;
  avatarUrl?: string;
  role: UserRole;
  status: AccountStatus;
  lastLoginAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface AuthResponseData {
  user: AuthUserProfile;
  tokens: AuthTokens;
}

// ==========================================
// 4. Curriculum, Publication & Question Banks
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
  id: z.string().regex(QuestionIdRegex, 'Question ID must follow pattern AAA-Gxx-Uxx-Qxxx (e.g. PHY-G09-U01-Q001)'),
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
  questions: z.array(RawQuestionItemSchema).length(30, 'Each approved unit must contain exactly 30 questions'),
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

// ==========================================
// 5. Assessment & Progress Contracts
// ==========================================

export const SubmitAnswerItemSchema = z.object({
  questionId: z.string().regex(QuestionIdRegex),
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

// ==========================================
// 6. Audit Logging Contracts
// ==========================================

export interface AuditLogEntry {
  id: string;
  userId?: string;
  userEmail?: string;
  action: string;
  resource: string;
  resourceId?: string;
  details?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
  timestamp: string;
}
