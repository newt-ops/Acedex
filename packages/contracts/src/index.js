"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AssessmentSubmissionSchema = exports.SubmitAnswerItemSchema = exports.QuestionBankFileSchema = exports.RawQuestionItemSchema = exports.QuestionIdRegex = exports.QuestionOptionSchema = exports.QuestionDifficultySchema = exports.GoogleAuthRequestSchema = exports.AuthProviderSchema = exports.AccountStatusSchema = exports.UserRoleSchema = void 0;
const zod_1 = require("zod");
// ==========================================
// 3. User & Authentication Contracts
// ==========================================
exports.UserRoleSchema = zod_1.z.enum(['student', 'admin', 'content_creator']);
exports.AccountStatusSchema = zod_1.z.enum(['active', 'suspended', 'pending_deletion']);
exports.AuthProviderSchema = zod_1.z.enum(['google']);
exports.GoogleAuthRequestSchema = zod_1.z.object({
    idToken: zod_1.z.string().min(1, 'Google ID token is required'),
});
// ==========================================
// 4. Question Bank & Curriculum Contracts
// ==========================================
exports.QuestionDifficultySchema = zod_1.z.enum(['easy', 'medium', 'challenging']);
exports.QuestionOptionSchema = zod_1.z.object({
    id: zod_1.z.enum(['A', 'B', 'C', 'D']),
    text: zod_1.z.string().min(1, 'Option text cannot be empty'),
});
exports.QuestionIdRegex = /^[A-Z]{3}-G(09|10|11|12)-U\d{2}-Q\d{3}$/;
exports.RawQuestionItemSchema = zod_1.z.object({
    id: zod_1.z.string().regex(exports.QuestionIdRegex, 'Question ID must follow pattern AAA-Gxx-Uxx-Qxxx (e.g. PHY-G09-U01-Q001)'),
    type: zod_1.z.literal('multiple_choice'),
    difficulty: exports.QuestionDifficultySchema,
    question: zod_1.z.string().min(1, 'Question text cannot be empty'),
    options: zod_1.z.array(exports.QuestionOptionSchema).length(4, 'Exactly 4 options (A, B, C, D) are required'),
    correctOptionId: zod_1.z.enum(['A', 'B', 'C', 'D']),
    explanation: zod_1.z.string().min(1, 'Explanation cannot be empty'),
    sourceReference: zod_1.z.string().optional(),
});
exports.QuestionBankFileSchema = zod_1.z.object({
    grade: zod_1.z.number().int().min(9).max(12),
    subject: zod_1.z.string().min(1, 'Subject name is required'),
    unitNumber: zod_1.z.number().int().positive('Unit number must be positive'),
    unitTitle: zod_1.z.string().min(1, 'Unit title is required'),
    questions: zod_1.z.array(exports.RawQuestionItemSchema).length(30, 'Each approved unit must contain exactly 30 questions'),
});
// ==========================================
// 5. Assessment & Progress Contracts
// ==========================================
exports.SubmitAnswerItemSchema = zod_1.z.object({
    questionId: zod_1.z.string().regex(exports.QuestionIdRegex),
    selectedOptionId: zod_1.z.enum(['A', 'B', 'C', 'D']).nullable(),
});
exports.AssessmentSubmissionSchema = zod_1.z.object({
    unitId: zod_1.z.string().min(1),
    attemptId: zod_1.z.string().uuid().optional(),
    answers: zod_1.z.array(exports.SubmitAnswerItemSchema).min(1),
    startedAt: zod_1.z.string().datetime().optional(),
    completedAt: zod_1.z.string().datetime().optional(),
    durationSeconds: zod_1.z.number().int().nonnegative().optional(),
});
