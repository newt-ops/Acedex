import { Response } from 'express';
import { SpendCoinsRequest } from '@acedex/contracts';
import { AuthenticatedRequest } from '../../middleware/auth.middleware';
import { EconomyService } from './economy.service';
import { sendSuccess } from '../../common/utils/response';

export class EconomyController {
  /**
   * GET /api/v1/economy/wallet
   * Returns current Ace Coins balance, transaction ledger, and store catalog
   */
  public static async getWallet(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const data = await EconomyService.getWalletOverview(req.user!.id);
    return sendSuccess(res, data, 200);
  }

  /**
   * POST /api/v1/economy/spend
   * Atomically spends Ace Coins on study perks, unit assessments, or scholar badges
   */
  public static async spendCoins(
    req: AuthenticatedRequest,
    res: Response
  ): Promise<Response> {
    const payload = req.body as SpendCoinsRequest;
    const data = await EconomyService.spendCoins(req.user!.id, payload);
    return sendSuccess(res, data, 200);
  }
}
