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

export const AuthProviderSchema = z.enum(['phone']);
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
    candidateId: z.string().max(30).optional(),
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

export const UpdateProfileRequestSchema = z
  .object({
    displayName: z.string().min(2, 'Name must be at least 2 characters').max(100).optional(),
    avatarUrl: z.string().optional(),
    gender: StudentGenderSchema.optional(),
    grade: z.union([z.literal(9), z.literal(10), z.literal(11), z.literal(12)]).optional(),
    stream: StudentStreamSchema.nullable().optional(),
  })
  .refine(
    (data) => {
      if ((data.grade === 11 || data.grade === 12) && data.stream === null) {
        return false;
      }
      return true;
    },
    {
      message: 'Stream (natural or social) is required for Grades 11 and 12',
      path: ['stream'],
    }
  );
export type UpdateProfileRequest = z.infer<typeof UpdateProfileRequestSchema>;


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

export const RewardTypeSchema = z.enum([
  'streak_repair',
  'exam_access',
  'offline_pack',
  'ai_study_plan',
  'bonus_coins',
]);
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
  coinsPerAd?: number;
  dailyLimit?: number;
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
    bonusCoins?: AdPolicyConfig;
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
  aiStudyPlanUnlocked?: boolean;
  aiPlanAdSessionId?: string;
  coinsAwarded?: number;
  newCoinBalance?: number;
  dailyCoinAdsRemaining?: number;
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

export interface OfflineAnswerKeyItem {
  questionId: string;
  externalId: string;
  correctOptionId: 'A' | 'B' | 'C' | 'D';
  explanation: string;
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
  offlineAnswerKeys?: OfflineAnswerKeyItem[];
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

export const CollectorQuestionSubmissionItemSchema = z.object({
  id: z.string().optional(),
  type: z.string().default('multiple_choice'),
  difficulty: z.string().default('medium'),
  question: z.string().min(1, 'Question text cannot be empty'),
  options: z.array(
    z.object({
      id: z.string().min(1),
      text: z.string().min(1, 'Option text cannot be empty'),
    })
  ).length(4, 'Exactly 4 options (A, B, C, D) are required'),
  correctOptionId: z.string().min(1),
  explanation: z.string().min(1, 'Explanation cannot be empty'),
  sourceReference: z.string().optional(),
});
export type CollectorQuestionSubmissionItem = z.infer<typeof CollectorQuestionSubmissionItemSchema>;

export const SubmitUnitQuestionsRequestSchema = z.object({
  unitCode: z.string().optional(),
  contributorId: z.string().min(3, 'contributorId must be at least 3 characters'),
  questions: z.array(CollectorQuestionSubmissionItemSchema).length(15, 'Must contain exactly 15 questions').optional(),
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

// ==========================================
// 9. Quick Note Collector & Ingestion Contracts
// ==========================================

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

// ==========================================
// 11. AI Cross-Grade Topic Study & Calibration Contracts
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

// ==========================================
// 12. Ace Coins Economy & Store Contracts
// ==========================================

export const EconomyStoreItemKeySchema = z.enum([
  'unit_assessment',
  'exam_ticket',
  'offline_pack',
  'streak_repair',
  'ai_plan_pass',
  'badge_euee_gold',
  'badge_stem_master',
  'badge_midnight_scholar',
]);
export type EconomyStoreItemKey = z.infer<typeof EconomyStoreItemKeySchema>;

export const SpendCoinsRequestSchema = z.object({
  itemKey: EconomyStoreItemKeySchema,
  targetUnitId: z.string().min(1).optional(),
});
export type SpendCoinsRequest = z.infer<typeof SpendCoinsRequestSchema>;

export type CoinTransactionType =
  | 'earn_welcome'
  | 'earn_milestone'
  | 'earn_ad'
  | 'spend';

export interface CoinTransactionItem {
  id: string;
  type: CoinTransactionType;
  amount: number; // positive for earn, negative for spend
  balanceAfter: number;
  reason: string;
  itemKey?: EconomyStoreItemKey;
  milestoneKey?: string;
  createdAt: string;
}

export interface EconomyStoreItem {
  itemKey: EconomyStoreItemKey;
  title: string;
  description: string;
  cost: number;
  category: 'access' | 'boost' | 'badge';
  canWatchAdInstead: boolean;
  adRewardType?: RewardType;
  owned?: boolean;
}

export interface WalletOverviewResponse {
  currencyName: 'Ace Coins';
  currencyCode: 'AC';
  balance: number;
  lifetimeEarned: number;
  lifetimeSpent: number;
  dailyCoinAdsRemaining: number;
  dailyCoinAdsLimit: number;
  coinsPerAd: number;
  assessmentCost: number;
  aiPlanPasses: number;
  assessmentPasses: number;
  unlockedBadges: string[];
  storeCatalog: EconomyStoreItem[];
  recentTransactions: CoinTransactionItem[];
}

export interface SpendCoinsResponse {
  itemKey: EconomyStoreItemKey;
  coinsSpent: number;
  newBalance: number;
  message: string;
  assessmentPasses?: number;
  examTicketsAvailable?: number;
  aiPlanPasses?: number;
  repairedStreak?: number;
  unlockedUnitCode?: string;
  offlineAccessExpiresAt?: string;
  unlockedBadge?: string;
}




