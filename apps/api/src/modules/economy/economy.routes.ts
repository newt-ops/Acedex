import { Router } from 'express';
import { SpendCoinsRequestSchema } from '@acedex/contracts';
import { requireAuth } from '../../middleware/auth.middleware';
import { validate } from '../../middleware/validate';
import { asyncHandler } from '../../common/utils/async-handler';
import { EconomyController } from './economy.controller';

const router = Router();

router.use(requireAuth);

// GET /api/v1/economy/wallet - Student Ace Coins wallet, catalog & ledger
router.get('/wallet', asyncHandler(EconomyController.getWallet));

// POST /api/v1/economy/spend - Spend Ace Coins on passes, packs, or badges
router.post(
  '/spend',
  validate({ body: SpendCoinsRequestSchema }),
  asyncHandler(EconomyController.spendCoins)
);

export const economyRoutes = router;
export default router;
