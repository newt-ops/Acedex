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

export const AuthProviderSchema = z.enum(['google', 'phone']);
export type AuthProvider = z.infer<typeof AuthProviderSchema>;

export const StudentGenderSchema = z.enum(['male', 'female']);
export type StudentGender = z.infer<typeof StudentGenderSchema>;

export const StudentStreamSchema = z.enum(['natural', 'social']);
export type StudentStream = z.infer<typeof StudentStreamSchema>;

export const SubjectStreamCategorySchema = z.enum(['natural', 'social', 'common']);
export type SubjectStreamCategory = z.infer<typeof SubjectStreamCategorySchema>;

export const EthiopianPhoneRegex = /^(\+251|0)?[79]\d{8}$/;

/**
 * Normalizes any Ethiopian phone number representation into standard E.164: +2519XXXXXXXX or +2517XXXXXXXX
 */
export function normalizeEthiopianPhone(input: string): string {
  const cleaned = input.replace(/[\s\-\(\)]/g, '');
  if (cleaned.startsWith('+251')) {
    return cleaned;
  }
  if (cleaned.startsWith('251')) {
    return `+${cleaned}`;
  }
  if (cleaned.startsWith('0')) {
    return `+251${cleaned.slice(1)}`;
  }
  if (cleaned.startsWith('9') || cleaned.startsWith('7')) {
    return `+251${cleaned}`;
  }
  return cleaned;
}

export const PhoneRegisterRequestSchema = z
  .object({
    phone: z
      .string()
      .regex(EthiopianPhoneRegex, 'Must be a valid Ethiopian phone number (e.g. 0912345678 or +251912345678)'),
    pin: z.string().regex(/^\d{6,}$/, 'PIN must be at least 6 digits'),
    fullName: z.string().min(2, 'Full name must be at least 2 characters').max(100),
    gender: StudentGenderSchema,
    grade: z.union([z.literal(9), z.literal(10), z.literal(11), z.literal(12)]),
    stream: StudentStreamSchema.nullable().optional(),
  })
  .refine(
    (data) => {
      if ((data.grade === 11 || data.grade === 12) && !data.stream) {
        return false;
      }
      return true;
    },
    {
      message: 'Stream (natural or social) is required for Grades 11 and 12',
      path: ['stream'],
    }
  );
export type PhoneRegisterRequest = z.infer<typeof PhoneRegisterRequestSchema>;

export const PhoneLoginRequestSchema = z.object({
  phone: z.string().regex(EthiopianPhoneRegex, 'Valid Ethiopian phone number required'),
  pin: z.string().min(6, 'PIN must be at least 6 digits'),
});
export type PhoneLoginRequest = z.infer<typeof PhoneLoginRequestSchema>;

export const ChangePinRequestSchema = z.object({
  currentPin: z.string().min(6, 'Current PIN is required'),
  newPin: z.string().regex(/^\d{6,}$/, 'New PIN must be at least 6 digits'),
});
export type ChangePinRequest = z.infer<typeof ChangePinRequestSchema>;

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
  acedexId: string;
  email?: string;
  phone?: string;
  displayName: string;
  avatarUrl?: string;
  gender?: StudentGender;
  grade?: number;
  stream?: StudentStream | null;
  role: UserRole;
  status: AccountStatus;
  authProvider: AuthProvider;
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
  questions: z.array(RawQuestionItemSchema).length(15, 'Each approved unit must contain exactly 15 questions'),
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

export const QuestionIdentifierRegex = /^([A-Z]{3}-G(09|10|11|12)-U\d{2}-Q\d{3}|[0-9a-fA-F]{24})$/;

export const SubmitAnswerItemSchema = z.object({
  questionId: z.string().regex(QuestionIdentifierRegex, 'questionId must be an external question ID or MongoDB ObjectId'),
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

// ==========================================
// 7. Rewarded Ads & Monetization Contracts
// ==========================================

export const RewardTypeSchema = z.enum(['streak_repair', 'exam_access', 'offline_pack']);
export type RewardType = z.infer<typeof RewardTypeSchema>;

export const AdPlatformSchema = z.enum(['android', 'ios']);
export type AdPlatform = z.infer<typeof AdPlatformSchema>;

export const StartAdSessionRequestSchema = z.object({
  rewardType: RewardTypeSchema,
  platform: AdPlatformSchema.default('android'),
  targetUnitId: z.string().optional(),
});
export type StartAdSessionRequest = z.infer<typeof StartAdSessionRequestSchema>;

export const ClaimRewardRequestSchema = z.object({
  adSessionId: z.string().min(1, 'adSessionId is required'),
  rewardType: RewardTypeSchema,
});
export type ClaimRewardRequest = z.infer<typeof ClaimRewardRequestSchema>;

export interface AdPolicyConfig {
  enabled: boolean;
  cooldownHours?: number;
  ticketsPerAd?: number;
  starterTickets?: number;
  durationHours?: number;
}

export interface AdConfigData {
  enabled: boolean;
  unityAds: {
    androidGameId: string;
    iosGameId: string;
    androidPlacement: string;
    iosPlacement: string;
  };
  policies: {
    streakRepair: AdPolicyConfig;
    examAccess: AdPolicyConfig;
    offlinePack: AdPolicyConfig;
  };
}

export interface AdSessionResponse {
  adSessionId: string;
  rewardType: RewardType;
  gameId: string;
  placementId: string;
  startedAt: string;
  expiresAt: string;
}

export interface ClaimRewardResponseData {
  rewardType: RewardType;
  repairedStreak?: number;
  examTicketsAvailable?: number;
  unlockedUnitId?: string;
  unlockedUnitCode?: string;
  offlineAccessExpiresAt?: string;
}

export interface StudentAdStatusData {
  streak: {
    currentStreak: number;
    canRepair: boolean;
    brokenStreakCount?: number;
  };
  examAccess: {
    canTakeExam: boolean;
    ticketsAvailable: number;
    requiresAd: boolean;
  };
  offlineAccess: {
    unlockedUnits: Array<{
      unitId: string;
      unitCode: string;
      expiresAt: string;
    }>;
  };
}

export interface AdminAdAnalyticsData {
  summary: {
    totalAdsCompleted: number;
    totalSessionsStarted: number;
    completionFunnelRate: number;
    uniqueViewersToday: number;
  };
  byRewardType: {
    streakRepair: number;
    examAccess: number;
    offlinePack: number;
  };
  byPlatform: {
    android: number;
    ios: number;
  };
  timeSeries: {
    today: number;
    last7Days: number;
    last30Days: number;
  };
}

export interface OfflinePackBundle {
  unitId: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  title: string;
  unitNumber: number;
  questionCount: number;
  downloadedAt: string;
  expiresAt: string;
  questions: PublicQuestionItem[];
}

// ==========================================
// 8. Study Management & Unit Tracking Contracts
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

// ==========================================
// 8. Temporary Subject Question Collector & Exporter
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

export const SubmitUnitQuestionsRequestSchema = z.object({
  unitCode: z.string().optional(),
  contributorId: z.string().min(3, 'contributorId must be at least 3 characters'),
  questions: z.array(RawQuestionItemSchema).length(15, 'Must contain exactly 15 questions'),
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


