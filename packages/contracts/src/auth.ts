import { z } from 'zod';

// ==========================================
// User & Authentication Contracts
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
      .regex(
        EthiopianPhoneRegex,
        'Must be a valid Ethiopian phone number (e.g. 0912345678 or +251912345678)'
      ),
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
