import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { OAuth2Client } from 'google-auth-library';
import {
  AuthTokens,
  AuthUserProfile,
  UserRole,
  PhoneRegisterRequest,
  PhoneLoginRequest,
  UpdateProfileRequest,
  normalizeEthiopianPhone,
} from '@acedex/contracts';
import { UserModel, IUser, generateUniqueAcedexId } from '../users/user.model';
import { RefreshTokenModel } from './refresh-token.model';
import { AuditService } from '../audit/audit.service';
import { env, adminEmails } from '../../config/env';
import {
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ConflictError,
  BadRequestError,
} from '../../common/errors/app-error';
import { logger } from '../../common/utils/logger';

const googleClient = new OAuth2Client();

export class AuthService {
  private static hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }

  public static async verifyGoogleIdToken(idToken: string): Promise<{
    sub: string;
    email: string;
    displayName: string;
    picture?: string;
  }> {
    const audience = [
      env.GOOGLE_CLIENT_ID,
      env.GOOGLE_ANDROID_CLIENT_ID,
    ].filter((id): id is string => Boolean(id && id.length > 0));

    try {
      const ticket = await googleClient.verifyIdToken({
        idToken,
        audience,
      });

      const payload = ticket.getPayload();
      if (!payload || !payload.sub || !payload.email) {
        throw new UnauthorizedError('Google token verification failed: Missing identity attributes');
      }

      return {
        sub: payload.sub,
        email: payload.email.toLowerCase().trim(),
        displayName: payload.name || payload.email.split('@')[0],
        picture: payload.picture,
      };
    } catch (err) {
      logger.warn({ err }, 'Google ID Token verification rejected');
      throw new UnauthorizedError('Invalid or expired Google ID token');
    }
  }

  /**
   * Checks if an Ethiopian phone number is already registered in the system.
   */
  public static async isPhoneRegistered(phone: string): Promise<boolean> {
    const normalizedPhone = normalizeEthiopianPhone(phone);
    const existing = await UserModel.exists({ phone: normalizedPhone });
    return !!existing;
  }

  /**
   * Registers a new student using phone number, PIN, name, gender, grade, and stream.
   * Instant onboarding without SMS OTP cost.
   */
  public static async registerWithPhone(
    payload: PhoneRegisterRequest,
    ipAddress?: string,
    userAgent?: string
  ): Promise<{ user: AuthUserProfile; tokens: AuthTokens }> {
    const normalizedPhone = normalizeEthiopianPhone(payload.phone);

    // 1. Check for duplicate phone
    const existingUser = await UserModel.findOne({ phone: normalizedPhone });
    if (existingUser) {
      throw new ConflictError('Phone number is already registered. Please log in.');
    }

    // 2. Hash PIN securely (10 rounds)
    const pinHash = await bcrypt.hash(payload.pin, 10);

    // 3. Generate unique branded ACEDEX Student Candidate ID (e.g. ACX-26-5480)
    const acedexId = await generateUniqueAcedexId(payload.candidateId);

    // 4. Save user document
    const user = await UserModel.create({
      acedexId,
      phone: normalizedPhone,
      pinHash,
      displayName: payload.fullName.trim(),
      gender: payload.gender,
      grade: payload.grade,
      stream: (payload.grade === 11 || payload.grade === 12) ? payload.stream : null,
      role: 'student',
      status: 'active',
      authProvider: 'phone',
      lastLoginAt: new Date(),
    });

    // 5. Audit registration
    await AuditService.record({
      userId: user._id.toString(),
      action: 'USER_REGISTERED_PHONE',
      resource: 'users',
      resourceId: user._id.toString(),
      details: {
        acedexId,
        phone: normalizedPhone,
        grade: payload.grade,
        stream: user.stream,
        gender: payload.gender,
      },
      ipAddress,
      userAgent,
    });

    // 6. Issue access and refresh tokens
    const tokens = await this.issueSessionTokens(user);

    return {
      user: this.mapUserToProfile(user),
      tokens,
    };
  }

  /**
   * Logs in a student using normalized phone number and PIN.
   */
  public static async loginWithPhone(
    payload: PhoneLoginRequest,
    ipAddress?: string,
    userAgent?: string
  ): Promise<{ user: AuthUserProfile; tokens: AuthTokens }> {
    const normalizedPhone = normalizeEthiopianPhone(payload.phone);

    // 1. Find user by phone, including pinHash
    const user = await UserModel.findOne({ phone: normalizedPhone }).select('+pinHash');
    if (!user || !user.pinHash) {
      throw new UnauthorizedError('Invalid phone number or PIN');
    }

    // 2. Check suspension
    if (user.status === 'suspended') {
      throw new ForbiddenError('Account is suspended. Please contact support.');
    }

    // 3. Verify PIN
    const isPinValid = await bcrypt.compare(payload.pin, user.pinHash);
    if (!isPinValid) {
      throw new UnauthorizedError('Invalid phone number or PIN');
    }

    // 4. Update last login
    user.lastLoginAt = new Date();
    await user.save();

    // 5. Issue session tokens
    const tokens = await this.issueSessionTokens(user);

    // 6. Audit login
    await AuditService.record({
      userId: user._id.toString(),
      action: 'USER_LOGIN_PHONE',
      resource: 'auth',
      details: { acedexId: user.acedexId, role: user.role },
      ipAddress,
      userAgent,
    });

    return {
      user: this.mapUserToProfile(user),
      tokens,
    };
  }

  /**
   * Allows authenticated student to change their PIN.
   */
  public static async changePin(
    userId: string,
    currentPin: string,
    newPin: string,
    ipAddress?: string,
    userAgent?: string
  ): Promise<{ user: AuthUserProfile; tokens: AuthTokens }> {
    const user = await UserModel.findById(userId).select('+pinHash');
    if (!user) {
      throw new NotFoundError('User not found');
    }

    if (!user.pinHash) {
      throw new BadRequestError('This account does not use PIN authentication');
    }

    const isMatch = await bcrypt.compare(currentPin, user.pinHash);
    if (!isMatch) {
      throw new UnauthorizedError('Current PIN is incorrect');
    }

    // Update PIN
    user.pinHash = await bcrypt.hash(newPin, 10);
    await user.save();

    // Revoke old refresh tokens for security
    await RefreshTokenModel.updateMany({ userId: user._id }, { isRevoked: true });

    // Issue fresh tokens
    const tokens = await this.issueSessionTokens(user);

    await AuditService.record({
      userId: user._id.toString(),
      action: 'USER_PIN_CHANGED',
      resource: 'auth',
      ipAddress,
      userAgent,
    });

    return {
      user: this.mapUserToProfile(user),
      tokens,
    };
  }

  public static async loginWithGoogle(
    idToken: string,
    ipAddress?: string,
    userAgent?: string
  ): Promise<{ user: AuthUserProfile; tokens: AuthTokens }> {
    const googleProfile = await this.verifyGoogleIdToken(idToken);

    // 1. Find or create user
    let user = await UserModel.findOne({
      $or: [{ googleId: googleProfile.sub }, { email: googleProfile.email }],
    });

    const isWhitelistedAdmin = adminEmails.includes(googleProfile.email);
    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      const initialRole: UserRole = isWhitelistedAdmin ? 'super_admin' : 'student';
      const acedexId = await generateUniqueAcedexId();

      user = await UserModel.create({
        acedexId,
        googleId: googleProfile.sub,
        email: googleProfile.email,
        displayName: googleProfile.displayName,
        avatarUrl: googleProfile.picture,
        role: initialRole,
        status: 'active',
        authProvider: 'google',
        lastLoginAt: new Date(),
      });

      await AuditService.record({
        userId: user._id.toString(),
        userEmail: user.email,
        action: 'USER_REGISTERED',
        resource: 'users',
        resourceId: user._id.toString(),
        details: { role: user.role, provider: 'google', acedexId },
        ipAddress,
        userAgent,
      });
    } else {
      // Existing user: check suspension
      if (user.status === 'suspended') {
        throw new ForbiddenError('Account is suspended. Please contact support.');
      }

      // Link googleId if missing or update profile
      user.googleId = googleProfile.sub;
      user.displayName = googleProfile.displayName;
      if (googleProfile.picture) {
        user.avatarUrl = googleProfile.picture;
      }
      user.lastLoginAt = new Date();

      // Upgrade to super_admin if whitelisted and currently standard student
      if (isWhitelistedAdmin && user.role === 'student') {
        user.role = 'super_admin';
        logger.info({ email: user.email }, 'Upgraded whitelisted email to super_admin');
      }

      await user.save();
    }

    // 2. Issue sessions
    const tokens = await this.issueSessionTokens(user);

    await AuditService.record({
      userId: user._id.toString(),
      userEmail: user.email,
      action: 'USER_LOGIN',
      resource: 'auth',
      details: { isNewUser, role: user.role },
      ipAddress,
      userAgent,
    });

    return {
      user: this.mapUserToProfile(user),
      tokens,
    };
  }

  public static async rotateRefreshToken(
    rawRefreshToken: string,
    ipAddress?: string,
    userAgent?: string
  ): Promise<{ user: AuthUserProfile; tokens: AuthTokens }> {
    if (!rawRefreshToken) {
      throw new UnauthorizedError('Refresh token is required');
    }

    const tokenHash = this.hashToken(rawRefreshToken);
    const existingToken = await RefreshTokenModel.findOne({ tokenHash });

    if (!existingToken) {
      throw new UnauthorizedError('Invalid refresh token');
    }

    // REUSE DETECTION: If token has already been revoked, family is compromised
    if (existingToken.isRevoked) {
      logger.warn(
        { userId: existingToken.userId, familyId: existingToken.familyId },
        '[SECURITY] Refresh token reuse detected! Invalidating session family.'
      );

      await RefreshTokenModel.updateMany(
        { familyId: existingToken.familyId },
        { isRevoked: true }
      );

      await AuditService.record({
        userId: existingToken.userId.toString(),
        action: 'SECURITY_ALERT_REFRESH_TOKEN_REUSE',
        resource: 'auth',
        details: { familyId: existingToken.familyId },
        ipAddress,
        userAgent,
      });

      throw new UnauthorizedError('Session revoked due to token reuse detection. Please log in again.');
    }

    // Check expiration
    if (existingToken.expiresAt < new Date()) {
      throw new UnauthorizedError('Refresh token expired. Please log in again.');
    }

    // Invalidate the consumed refresh token
    existingToken.isRevoked = true;
    await existingToken.save();

    // Fetch user
    const user = await UserModel.findById(existingToken.userId);
    if (!user || user.status === 'suspended') {
      throw new UnauthorizedError('User account not found or suspended');
    }

    // Issue new access token and rotated refresh token under same familyId
    const tokens = await this.issueSessionTokens(user, existingToken.familyId);

    return {
      user: this.mapUserToProfile(user),
      tokens,
    };
  }

  public static async logout(
    rawRefreshToken?: string,
    userId?: string,
    ipAddress?: string,
    userAgent?: string
  ): Promise<void> {
    if (rawRefreshToken) {
      const tokenHash = this.hashToken(rawRefreshToken);
      await RefreshTokenModel.updateOne({ tokenHash }, { isRevoked: true });
    }

    if (userId) {
      await AuditService.record({
        userId,
        action: 'USER_LOGOUT',
        resource: 'auth',
        ipAddress,
        userAgent,
      });
    }
  }

  public static async getProfile(userId: string): Promise<AuthUserProfile> {
    const user = await UserModel.findById(userId);
    if (!user) {
      throw new NotFoundError('User profile not found');
    }
    return this.mapUserToProfile(user);
  }

  public static async updateProfile(
    userId: string,
    payload: UpdateProfileRequest,
    ipAddress?: string,
    userAgent?: string
  ): Promise<AuthUserProfile> {
    const user = await UserModel.findById(userId);
    if (!user) {
      throw new NotFoundError('User profile not found');
    }

    if (payload.displayName !== undefined) {
      user.displayName = payload.displayName.trim();
    }
    if (payload.avatarUrl !== undefined) {
      user.avatarUrl = payload.avatarUrl.trim();
    }
    if (payload.gender !== undefined) {
      user.gender = payload.gender;
    }
    if (payload.grade !== undefined) {
      user.grade = payload.grade;
      if ((payload.grade === 9 || payload.grade === 10) && payload.stream === undefined) {
        user.stream = null;
      }
    }
    if (payload.stream !== undefined) {
      user.stream = payload.stream;
    }

    await user.save();

    await AuditService.record({
      userId: user._id.toString(),
      action: 'USER_PROFILE_UPDATE',
      resource: 'users',
      resourceId: user._id.toString(),
      details: { displayName: user.displayName, grade: user.grade, stream: user.stream },
      ipAddress,
      userAgent,
    });

    return this.mapUserToProfile(user);
  }

  private static async issueSessionTokens(
    user: IUser,
    existingFamilyId?: string
  ): Promise<AuthTokens> {
    const userId = user._id.toString();

    // 1. Generate 15m Access JWT with acedexId, grade & stream
    const accessToken = jwt.sign(
      {
        sub: userId,
        acedexId: user.acedexId,
        email: user.email,
        phone: user.phone,
        role: user.role,
        grade: user.grade,
        stream: user.stream,
        displayName: user.displayName,
      },
      env.JWT_ACCESS_SECRET,
      { expiresIn: '15m' }
    );

    // 2. Generate 7d Refresh Token
    const plainRefreshToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = this.hashToken(plainRefreshToken);
    const familyId = existingFamilyId || crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

    await RefreshTokenModel.create({
      userId: user._id,
      tokenHash,
      familyId,
      isRevoked: false,
      expiresAt,
    });

    return {
      accessToken,
      refreshToken: plainRefreshToken,
      expiresIn: 15 * 60, // 900 seconds
    };
  }

  public static mapUserToProfile(user: IUser): AuthUserProfile {
    return {
      id: user._id.toString(),
      acedexId: user.acedexId,
      email: user.email,
      phone: user.phone,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      gender: user.gender,
      grade: user.grade,
      stream: user.stream,
      role: user.role,
      status: user.status,
      authProvider: user.authProvider,
      lastLoginAt: user.lastLoginAt ? user.lastLoginAt.toISOString() : undefined,
      createdAt: user.createdAt.toISOString(),
      updatedAt: user.updatedAt.toISOString(),
    };
  }
}
