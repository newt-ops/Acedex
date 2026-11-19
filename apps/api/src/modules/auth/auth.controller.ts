import { Response } from 'express';
import {
  GoogleAuthRequest,
  RefreshTokenRequest,
  PhoneRegisterRequest,
  PhoneLoginRequest,
  ChangePinRequest,
  UpdateProfileRequest,
} from '@acedex/contracts';
import { AuthService } from './auth.service';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { sendSuccess } from '../../common/utils/response';
import { env } from '../../config/env';

const COOKIE_NAME = 'acedex_rt';
const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;

export class AuthController {
  private static setRefreshTokenCookie(res: Response, refreshToken: string) {
    const isProd = env.NODE_ENV === 'production';
    res.cookie(COOKIE_NAME, refreshToken, {
      httpOnly: true,
      secure: isProd,
      // 'none' is necessary for cross-domain cookies between Vercel and Render HTTPS
      sameSite: isProd ? 'none' : 'lax',
      maxAge: SEVEN_DAYS_MS,
      path: '/',
    });
  }

  /**
   * Student registration with phone, PIN, name, gender, grade, and stream.
   */
  public static async registerPhone(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const body = req.body as PhoneRegisterRequest;

    const result = await AuthService.registerWithPhone(
      body,
      req.ip,
      req.headers['user-agent']
    );

    return sendSuccess(res, result, 201);
  }

  /**
   * Student login with phone and PIN.
   */
  public static async loginPhone(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const body = req.body as PhoneLoginRequest;

    const result = await AuthService.loginWithPhone(
      body,
      req.ip,
      req.headers['user-agent']
    );

    return sendSuccess(res, result, 200);
  }

  /**
   * Authenticated PIN change.
   */
  public static async changePin(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const { currentPin, newPin } = req.body as ChangePinRequest;

    const result = await AuthService.changePin(
      req.user!.id,
      currentPin,
      newPin,
      req.ip,
      req.headers['user-agent']
    );

    return sendSuccess(res, result, 200);
  }

  public static async google(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const { idToken, platform } = req.body as GoogleAuthRequest;

    const result = await AuthService.loginWithGoogle(
      idToken,
      req.ip,
      req.headers['user-agent']
    );

    // Set cookie for web applications
    if (result.tokens.refreshToken && (platform === 'web' || !platform)) {
      AuthController.setRefreshTokenCookie(res, result.tokens.refreshToken);
    }

    return sendSuccess(res, result, 200);
  }

  public static async refresh(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const body = req.body as RefreshTokenRequest;
    const rawRefreshToken = req.cookies[COOKIE_NAME] || body.refreshToken;

    const result = await AuthService.rotateRefreshToken(
      rawRefreshToken,
      req.ip,
      req.headers['user-agent']
    );

    // Update cookie if cookie was used
    if (result.tokens.refreshToken && req.cookies[COOKIE_NAME]) {
      AuthController.setRefreshTokenCookie(res, result.tokens.refreshToken);
    }

    return sendSuccess(res, result, 200);
  }

  public static async logout(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const body = req.body as RefreshTokenRequest;
    const rawRefreshToken = req.cookies[COOKIE_NAME] || body?.refreshToken;

    await AuthService.logout(
      rawRefreshToken,
      req.user?.id,
      req.ip,
      req.headers['user-agent']
    );

    res.clearCookie(COOKIE_NAME, {
      httpOnly: true,
      secure: env.NODE_ENV === 'production',
      sameSite: env.NODE_ENV === 'production' ? 'none' : 'lax',
      path: '/',
    });

    return sendSuccess(res, { message: 'Logged out successfully' }, 200);
  }

  public static async me(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const profile = await AuthService.getProfile(req.user!.id);
    return sendSuccess(res, profile, 200);
  }

  public static async updateProfile(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const body = req.body as UpdateProfileRequest;
    const profile = await AuthService.updateProfile(
      req.user!.id,
      body,
      req.ip,
      req.headers['user-agent']
    );
    return sendSuccess(res, profile, 200);
  }
}
