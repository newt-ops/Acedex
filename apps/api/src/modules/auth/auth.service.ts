import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { OAuth2Client } from 'google-auth-library';
import {
  AuthTokens,
  AuthUserProfile,
  UserRole,
} from '@acedex/contracts';
import { UserModel, IUser } from '../users/user.model';
import { RefreshTokenModel } from './refresh-token.model';
import { AuditService } from '../audit/audit.service';
import { env, adminEmails } from '../../config/env';
import {
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
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

      user = await UserModel.create({
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
        details: { role: user.role, provider: 'google' },
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

  private static async issueSessionTokens(
    user: IUser,
    existingFamilyId?: string
  ): Promise<AuthTokens> {
    const userId = user._id.toString();

    // 1. Generate 15m Access JWT
    const accessToken = jwt.sign(
      {
        sub: userId,
        email: user.email,
        role: user.role,
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
      email: user.email,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      role: user.role,
      status: user.status,
      lastLoginAt: user.lastLoginAt ? user.lastLoginAt.toISOString() : undefined,
      createdAt: user.createdAt.toISOString(),
      updatedAt: user.updatedAt.toISOString(),
    };
  }
}
