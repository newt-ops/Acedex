import { Response } from 'express';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { AdminAdsService } from './admin-ads.service';
import { AdsService } from './ads.service';
import { sendSuccess } from '../../common/utils/response';

export class AdminAdsController {
  /**
   * GET /api/v1/admin/ads/analytics
   */
  public static async getAnalytics(
    _req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const analytics = await AdminAdsService.getAdAnalytics();
    return sendSuccess(res, analytics, 200);
  }

  /**
   * GET /api/v1/admin/ads/sessions
   */
  public static async getSessions(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const page = parseInt((req.query.page as string) || '1', 10);
    const limit = parseInt((req.query.limit as string) || '20', 10);
    const result = await AdminAdsService.getAdSessions(page, limit);
    return sendSuccess(res, result.sessions, 200, result.pagination);
  }

  /**
   * GET /api/v1/admin/ads/config
   */
  public static async getConfig(
    _req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const config = await AdsService.getConfig();
    return sendSuccess(res, config, 200);
  }

  /**
   * PUT /api/v1/admin/ads/config
   */
  public static async updateConfig(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const adminContext = {
      userId: req.user?.id,
      email: req.user?.email,
    };
    const updated = await AdminAdsService.updateConfig(req.body, adminContext);
    return sendSuccess(res, updated, 200);
  }
}
