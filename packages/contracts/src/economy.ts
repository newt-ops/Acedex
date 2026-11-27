import { z } from 'zod';
import { RewardType } from './ads';

// ==========================================
// Ace Coins Economy & Store Contracts
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
  unlockedAssessmentUnits?: string[];
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
