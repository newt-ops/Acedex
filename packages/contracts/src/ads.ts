import { z } from 'zod';
import { PublicQuestionItem } from './curriculum';

// ==========================================
// Rewarded Ads & Monetization Contracts
// ==========================================

export const RewardTypeSchema = z.enum([
  'streak_repair',
  'exam_access',
  'offline_pack',
  'ai_study_plan',
  'bonus_coins',
]);
export type RewardType = z.infer<typeof RewardTypeSchema>;

export const AdPlatformSchema = z.enum(['android', 'ios']);
export type AdPlatform = z.infer<typeof AdPlatformSchema>;

export const StartAdSessionRequestSchema = z.object({
  rewardType: RewardTypeSchema,
  platform: AdPlatformSchema.default('android'),
  targetUnitId: z.string().optional(),
});
export type StartAdSessionRequest = z.infer<typeof StartAdSessionRequestSchema>;

export const ClaimRewardRequestSchema = z.object({
  adSessionId: z.string().min(1, 'adSessionId is required'),
  rewardType: RewardTypeSchema,
});
export type ClaimRewardRequest = z.infer<typeof ClaimRewardRequestSchema>;

export interface AdPolicyConfig {
  enabled: boolean;
  cooldownHours?: number;
  ticketsPerAd?: number;
  starterTickets?: number;
  durationHours?: number;
  coinsPerAd?: number;
  dailyLimit?: number;
}

export interface AdConfigData {
  enabled: boolean;
  unityAds: {
    androidGameId: string;
    iosGameId: string;
    androidPlacement: string;
    iosPlacement: string;
  };
  policies: {
    streakRepair: AdPolicyConfig;
    examAccess: AdPolicyConfig;
    offlinePack: AdPolicyConfig;
    bonusCoins?: AdPolicyConfig;
  };
}

export interface AdSessionResponse {
  adSessionId: string;
  rewardType: RewardType;
  gameId: string;
  placementId: string;
  startedAt: string;
  expiresAt: string;
}

export interface ClaimRewardResponseData {
  rewardType: RewardType;
  repairedStreak?: number;
  examTicketsAvailable?: number;
  unlockedUnitId?: string;
  unlockedUnitCode?: string;
  offlineAccessExpiresAt?: string;
  aiStudyPlanUnlocked?: boolean;
  aiPlanAdSessionId?: string;
  coinsAwarded?: number;
  newCoinBalance?: number;
  dailyCoinAdsRemaining?: number;
}

export interface StudentAdStatusData {
  streak: {
    currentStreak: number;
    canRepair: boolean;
    brokenStreakCount?: number;
  };
  examAccess: {
    canTakeExam: boolean;
    ticketsAvailable: number;
    requiresAd: boolean;
  };
  offlineAccess: {
    unlockedUnits: Array<{
      unitId: string;
      unitCode: string;
      expiresAt: string;
    }>;
  };
}

export interface AdminAdAnalyticsData {
  summary: {
    totalAdsCompleted: number;
    totalSessionsStarted: number;
    completionFunnelRate: number;
    uniqueViewersToday: number;
  };
  byRewardType: {
    streakRepair: number;
    examAccess: number;
    offlinePack: number;
  };
  byPlatform: {
    android: number;
    ios: number;
  };
  timeSeries: {
    today: number;
    last7Days: number;
    last30Days: number;
  };
}

export interface OfflineAnswerKeyItem {
  questionId: string;
  externalId: string;
  correctOptionId: 'A' | 'B' | 'C' | 'D';
  explanation: string;
}

export interface OfflinePackBundle {
  unitId: string;
  unitCode: string;
  subjectCode: string;
  grade: number;
  title: string;
  unitNumber: number;
  questionCount: number;
  downloadedAt: string;
  expiresAt: string;
  questions: PublicQuestionItem[];
  offlineAnswerKeys?: OfflineAnswerKeyItem[];
}
