import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { AdsService } from './ads.service';
import { sendSuccess } from '../../common/utils/response';
import { StartAdSessionRequestSchema, ClaimRewardRequestSchema } from '@acedex/contracts';

export class AdsController {
  /**
   * GET /api/v1/ads/config
   * Fetches remote Unity Ads identifiers and reward utility policies
   */
  public static async getConfig(_req: AuthenticatedRequest, res: Response): Promise<Response> {
    const config = await AdsService.getConfig();
    return sendSuccess(res, config, 200);
  }

  /**
   * GET /api/v1/ads/status
   * Fetches current student ad monetization, broken streak repairability, and ticket balance
   */
  public static async getStudentStatus(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const userId = req.user!.id;
    const status = await AdsService.getStudentAdStatus(userId);
    return sendSuccess(res, status, 200);
  }

  /**
   * POST /api/v1/ads/session/start
   * Starts a rewarded ad session and returns placement identifiers
   */
  public static async startSession(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const userId = req.user!.id;
    const input = StartAdSessionRequestSchema.parse(req.body);
    const session = await AdsService.startSession(userId, input);
    return sendSuccess(res, session, 201);
  }

  /**
   * GET /api/v1/ads/unity/callback
   * Public webhook endpoint for Unity Ads S2S server verification
   */
  public static async handleUnityS2SCallback(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const sid = req.query.sid as string;
    const oid = req.query.oid as string | undefined;
    const hmac = req.query.hmac as string | undefined;

    const result = await AdsService.handleUnityS2SCallback({ sid, oid, hmac });
    return sendSuccess(res, result, 200);
  }

  /**
   * POST /api/v1/ads/reward/claim
   * Verifies ad completion and fulfills the requested reward
   */
  public static async claimReward(req: AuthenticatedRequest, res: Response): Promise<Response> {
    const userId = req.user!.id;
    const input = ClaimRewardRequestSchema.parse(req.body);
    const claimResult = await AdsService.claimReward(userId, input);
    return sendSuccess(res, claimResult, 200);
  }
}
