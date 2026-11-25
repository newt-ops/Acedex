import { Types } from 'mongoose';
import {
  EconomyStoreItem,
  EconomyStoreItemKey,
  SpendCoinsRequest,
  SpendCoinsResponse,
  WalletOverviewResponse,
} from '@acedex/contracts';
import {
  IStudentProgressDocument,
  StudentProgressModel,
} from '../progress/models/student-progress.model';
import { UnitModel } from '../curriculum/models/unit.model';
import { AdConfigModel } from '../ads/models/ad-config.model';
import { CoinTransactionModel } from './models/coin-transaction.model';
import {
  AppError,
  BadRequestError,
  ForbiddenError,
  NotFoundError,
  TooManyRequestsError,
} from '../../common/errors/app-error';
import { logger } from '../../common/utils/logger';

export const ACE_COINS_CONFIG = {
  WELCOME_BONUS: 25,
  UNIT_COMPLETE_REWARD: 15,
  ASSESSMENT_PASS_REWARD: 25,
  ASSESSMENT_PERFECT_BONUS: 10,
  MODULE_COMPLETE_REWARD: 30,
  DAILY_STREAK_REWARD: 10,
  SEVEN_DAY_STREAK_BONUS: 50,
  DEFAULT_COINS_PER_AD: 40,
  DEFAULT_DAILY_COIN_ADS_LIMIT: 5,
  UNIT_ASSESSMENT_COST: 10,
} as const;

const BASE_STORE_CATALOG: EconomyStoreItem[] = [
  {
    itemKey: 'unit_assessment',
    title: 'Unit 15-Q Assessment Entry',
    description: 'Unlock 1 unit exam attempt to test mastery and earn +25 AC back on pass.',
    cost: 10,
    category: 'access',
    canWatchAdInstead: true,
    adRewardType: 'bonus_coins',
  },
  {
    itemKey: 'exam_ticket',
    title: 'Extra Exam Access Ticket',
    description: 'Adds 1 exam access ticket immediately for gated assessments.',
    cost: 30,
    category: 'access',
    canWatchAdInstead: true,
    adRewardType: 'exam_access',
  },
  {
    itemKey: 'offline_pack',
    title: '24-Hour Offline Unit Pack',
    description: 'Download full unit questions & keys for offline study.',
    cost: 45,
    category: 'access',
    canWatchAdInstead: true,
    adRewardType: 'offline_pack',
  },
  {
    itemKey: 'streak_repair',
    title: 'Streak Repair Shield',
    description: 'Restore a broken daily study streak back to your momentum count.',
    cost: 60,
    category: 'boost',
    canWatchAdInstead: true,
    adRewardType: 'streak_repair',
  },
  {
    itemKey: 'ai_plan_pass',
    title: 'AI Study Program Pass',
    description: 'Generate or recalibrate your Gemini Topic Study Plan without waiting for an ad.',
    cost: 100,
    category: 'boost',
    canWatchAdInstead: true,
    adRewardType: 'ai_study_plan',
  },
  {
    itemKey: 'badge_euee_gold',
    title: 'EUEE Gold Scholar Badge',
    description: 'Displays a signature gold academic honor seal on your Student Profile.',
    cost: 120,
    category: 'badge',
    canWatchAdInstead: false,
  },
  {
    itemKey: 'badge_stem_master',
    title: 'Honors Stream Master Crest',
    description: 'Exclusive honors distinction for dedicated high-score EUEE candidates.',
    cost: 180,
    category: 'badge',
    canWatchAdInstead: false,
  },
  {
    itemKey: 'badge_midnight_scholar',
    title: 'Night Owl Merit Emblem',
    description: 'Rare badge earned by relentless late-night ACEDEX problem solvers.',
    cost: 250,
    category: 'badge',
    canWatchAdInstead: false,
  },
];

export class EconomyService {
  /**
   * Current Ethiopia (EAT, UTC+3) calendar day key (YYYY-MM-DD).
   */
  public static getEatTodayKey(now = new Date()): string {
    const eatOffsetMs = 3 * 60 * 60 * 1000;
    return new Date(now.getTime() + eatOffsetMs).toISOString().slice(0, 10);
  }

  /**
   * Ensures a StudentProgress document and its Ace Coins wallet exist cleanly,
   * granting the one-time 25 AC Welcome Bonus to both new and legacy student records.
   */
  public static async ensureWalletInitialized(
    userId: string | Types.ObjectId
  ): Promise<IStudentProgressDocument> {
    const userObjectId = new Types.ObjectId(userId);
    let progress = await StudentProgressModel.findOne({ userId: userObjectId });

    if (!progress) {
      progress = await StudentProgressModel.create({
        userId: userObjectId,
        overallStats: {
          totalAssessmentsTaken: 0,
          totalAssessmentsPassed: 0,
          averageScore: 0,
          totalTimeSpentSeconds: 0,
        },
        streak: {
          currentStreak: 0,
          longestStreak: 0,
          lastActivityDate: '',
          previousBrokenStreak: 0,
        },
        examAccess: { ticketsAvailable: 2, totalAdsWatched: 0 },
        offlineAccess: { unlockedUnits: [] },
        units: [],
        subjectMastery: [],
        topicModules: [],
        wallet: {
          balance: ACE_COINS_CONFIG.WELCOME_BONUS,
          lifetimeEarned: ACE_COINS_CONFIG.WELCOME_BONUS,
          lifetimeSpent: 0,
          rewardedMilestoneKeys: ['WELCOME_BONUS'],
          dailyCoinAdsDate: '',
          dailyCoinAdsCount: 0,
          aiPlanPasses: 0,
          assessmentPasses: 0,
          unlockedBadges: [],
        },
      });

      await this.recordTransactionSafe({
        userId: userObjectId,
        type: 'earn_welcome',
        amount: ACE_COINS_CONFIG.WELCOME_BONUS,
        balanceAfter: progress.wallet.balance,
        reason: 'Welcome Bonus — First Study Steps',
        milestoneKey: 'WELCOME_BONUS',
      });

      return progress;
    }

    const hasWelcome =
      progress.wallet?.rewardedMilestoneKeys?.includes('WELCOME_BONUS') ?? false;
    if (!hasWelcome) {
      const upgraded = await StudentProgressModel.findOneAndUpdate(
        {
          userId: userObjectId,
          'wallet.rewardedMilestoneKeys': { $ne: 'WELCOME_BONUS' },
        },
        {
          $addToSet: { 'wallet.rewardedMilestoneKeys': 'WELCOME_BONUS' },
          $inc: {
            'wallet.balance': ACE_COINS_CONFIG.WELCOME_BONUS,
            'wallet.lifetimeEarned': ACE_COINS_CONFIG.WELCOME_BONUS,
          },
        },
        { new: true }
      );
      if (upgraded) {
        progress = upgraded;
        await this.recordTransactionSafe({
          userId: userObjectId,
          type: 'earn_welcome',
          amount: ACE_COINS_CONFIG.WELCOME_BONUS,
          balanceAfter: progress.wallet.balance,
          reason: 'Welcome Bonus — First Study Steps',
          milestoneKey: 'WELCOME_BONUS',
        });
      }
    }

    return progress;
  }

  private static async recordTransactionSafe(params: {
    userId: Types.ObjectId;
    type: 'earn_welcome' | 'earn_milestone' | 'earn_ad' | 'spend';
    amount: number;
    balanceAfter: number;
    reason: string;
    milestoneKey?: string;
    itemKey?: EconomyStoreItem['itemKey'];
    metadata?: Record<string, unknown>;
  }): Promise<void> {
    try {
      await CoinTransactionModel.create(params);
    } catch (err: any) {
      // Ignore duplicate unique milestoneKey race errors (idempotent)
      if (err?.code !== 11000) {
        logger.warn({ err: err?.message }, 'Failed to write coin transaction audit record');
      }
    }
  }

  /**
   * Resolves live bonus_coins ad policy with safe defaults.
   */
  public static async getBonusCoinsAdPolicy(): Promise<{
    enabled: boolean;
    coinsPerAd: number;
    dailyLimit: number;
  }> {
    const config = await AdConfigModel.findOne({ singletonId: 'global_ad_config' }).lean();
    const policy = config?.policies?.bonusCoins;
    return {
      enabled: policy?.enabled ?? true,
      coinsPerAd: policy?.coinsPerAd ?? ACE_COINS_CONFIG.DEFAULT_COINS_PER_AD,
      dailyLimit: policy?.dailyLimit ?? ACE_COINS_CONFIG.DEFAULT_DAILY_COIN_ADS_LIMIT,
    };
  }

  /**
   * Idempotent server-side milestone award — each unique `milestoneKey` (e.g.
   * `UNIT:PHY-G09-U01`, `MODULE:MAT-M01`, `ASSESS:MAT-G10-U02`) pays out ONCE per student.
   */
  public static async awardMilestone(params: {
    userId: string | Types.ObjectId;
    milestoneKey: string;
    amount: number;
    reason: string;
    metadata?: Record<string, unknown>;
  }): Promise<{ awarded: boolean; coinsAwarded: number; newCoinBalance: number }> {
    const progress = await this.ensureWalletInitialized(params.userId);
    const userObjectId = new Types.ObjectId(params.userId);

    const updated = await StudentProgressModel.findOneAndUpdate(
      {
        userId: userObjectId,
        'wallet.rewardedMilestoneKeys': { $ne: params.milestoneKey },
      },
      {
        $addToSet: { 'wallet.rewardedMilestoneKeys': params.milestoneKey },
        $inc: {
          'wallet.balance': params.amount,
          'wallet.lifetimeEarned': params.amount,
        },
      },
      { new: true }
    );

    if (!updated) {
      return {
        awarded: false,
        coinsAwarded: 0,
        newCoinBalance: progress.wallet?.balance ?? 0,
      };
    }

    await this.recordTransactionSafe({
      userId: userObjectId,
      type: 'earn_milestone',
      amount: params.amount,
      balanceAfter: updated.wallet.balance,
      reason: params.reason,
      milestoneKey: params.milestoneKey,
      metadata: params.metadata,
    });

    logger.info(
      {
        userId: userObjectId.toString(),
        milestoneKey: params.milestoneKey,
        coinsAwarded: params.amount,
        balance: updated.wallet.balance,
      },
      'Ace Coins milestone awarded'
    );

    return {
      awarded: true,
      coinsAwarded: params.amount,
      newCoinBalance: updated.wallet.balance,
    };
  }

  /**
   * Validates daily rewarded-ad coin cap before starting an ad session.
   */
  public static async assertCanEarnAdCoins(
    userId: string | Types.ObjectId
  ): Promise<{ coinsPerAd: number; dailyLimit: number; remaining: number }> {
    const policy = await this.getBonusCoinsAdPolicy();
    if (!policy.enabled) {
      throw new BadRequestError('Bonus coin ads are currently disabled');
    }

    const progress = await this.ensureWalletInitialized(userId);
    const todayKey = this.getEatTodayKey();
    const countToday =
      progress.wallet?.dailyCoinAdsDate === todayKey
        ? progress.wallet.dailyCoinAdsCount || 0
        : 0;
    const remaining = Math.max(0, policy.dailyLimit - countToday);

    if (remaining <= 0) {
      throw new TooManyRequestsError(
        `Daily bonus coin ad limit reached (${policy.dailyLimit}/${policy.dailyLimit}). Earn more coins by completing units & exams!`,
        'DAILY_COIN_ADS_LIMIT_REACHED'
      );
    }

    return {
      coinsPerAd: policy.coinsPerAd,
      dailyLimit: policy.dailyLimit,
      remaining,
    };
  }

  /**
   * Credits bonus Ace Coins after a verified Rewarded Ad (`rewardType: 'bonus_coins'`).
   */
  public static async awardAdCoins(userId: string | Types.ObjectId): Promise<{
    coinsAwarded: number;
    newCoinBalance: number;
    dailyCoinAdsRemaining: number;
  }> {
    const policy = await this.getBonusCoinsAdPolicy();
    await this.assertCanEarnAdCoins(userId);

    const userObjectId = new Types.ObjectId(userId);
    const todayKey = this.getEatTodayKey();

    // Reset daily counter cleanly if calendar day rolled over in EAT
    await StudentProgressModel.updateOne(
      {
        userId: userObjectId,
        'wallet.dailyCoinAdsDate': { $ne: todayKey },
      },
      {
        $set: {
          'wallet.dailyCoinAdsDate': todayKey,
          'wallet.dailyCoinAdsCount': 0,
        },
      }
    );

    const updated = await StudentProgressModel.findOneAndUpdate(
      {
        userId: userObjectId,
        'wallet.dailyCoinAdsCount': { $lt: policy.dailyLimit },
      },
      {
        $set: { 'wallet.dailyCoinAdsDate': todayKey },
        $inc: {
          'wallet.dailyCoinAdsCount': 1,
          'wallet.balance': policy.coinsPerAd,
          'wallet.lifetimeEarned': policy.coinsPerAd,
        },
      },
      { new: true }
    );

    if (!updated) {
      throw new TooManyRequestsError(
        `Daily bonus coin ad limit reached (${policy.dailyLimit}/${policy.dailyLimit}).`,
        'DAILY_COIN_ADS_LIMIT_REACHED'
      );
    }

    await this.recordTransactionSafe({
      userId: userObjectId,
      type: 'earn_ad',
      amount: policy.coinsPerAd,
      balanceAfter: updated.wallet.balance,
      reason: 'Watched Rewarded Ad (+40 AC)',
    });

    const remaining = Math.max(0, policy.dailyLimit - updated.wallet.dailyCoinAdsCount);
    return {
      coinsAwarded: policy.coinsPerAd,
      newCoinBalance: updated.wallet.balance,
      dailyCoinAdsRemaining: remaining,
    };
  }

  /**
   * Consumes either a pre-purchased 10 AC Assessment Pass OR 10 AC directly from the student's
   * Ace Coins balance when submitting/entering a 15-Q Unit Assessment.
   */
  public static async consumeUnitAssessmentEntry(
    userId: string | Types.ObjectId,
    unitCode: string
  ): Promise<{ coinsSpent: number; newCoinBalance: number }> {
    const userObjectId = new Types.ObjectId(userId);
    const progress = await this.ensureWalletInitialized(userObjectId);

    // 1. If the student unlocked the assessment via POST /economy/spend upfront, consume that pass
    const passUsed = await StudentProgressModel.findOneAndUpdate(
      { userId: userObjectId, 'wallet.assessmentPasses': { $gt: 0 } },
      { $inc: { 'wallet.assessmentPasses': -1 } },
      { new: true }
    );
    if (passUsed) {
      return {
        coinsSpent: 0,
        newCoinBalance: passUsed.wallet.balance,
      };
    }

    // 2. Otherwise atomically charge 10 Ace Coins
    const cost = ACE_COINS_CONFIG.UNIT_ASSESSMENT_COST;
    const charged = await StudentProgressModel.findOneAndUpdate(
      { userId: userObjectId, 'wallet.balance': { $gte: cost } },
      {
        $inc: {
          'wallet.balance': -cost,
          'wallet.lifetimeSpent': cost,
        },
      },
      { new: true }
    );

    if (!charged) {
      const currentBal = progress.wallet?.balance ?? 0;
      throw new ForbiddenError(
        `Unit assessment costs ${cost} Ace Coins (current balance: ${currentBal} AC). Watch 1 rewarded ad (+40 AC) or master units (+15 AC) to continue.`,
        'INSUFFICIENT_COINS',
        { requiredCoins: cost, currentBalance: currentBal }
      );
    }

    await this.recordTransactionSafe({
      userId: userObjectId,
      type: 'spend',
      amount: -cost,
      balanceAfter: charged.wallet.balance,
      reason: `Unit Assessment Entry (${unitCode})`,
      itemKey: 'unit_assessment',
      metadata: { unitCode },
    });

    return {
      coinsSpent: cost,
      newCoinBalance: charged.wallet.balance,
    };
  }

  /**
   * Consumes 1 purchased AI Plan Pass when recalibrating/generating via Ace Coins.
   */
  public static async consumeAiPlanPass(
    userId: string | Types.ObjectId
  ): Promise<boolean> {
    const userObjectId = new Types.ObjectId(userId);
    const updated = await StudentProgressModel.findOneAndUpdate(
      { userId: userObjectId, 'wallet.aiPlanPasses': { $gt: 0 } },
      { $inc: { 'wallet.aiPlanPasses': -1 } },
      { new: true }
    );
    return Boolean(updated);
  }

  /**
   * Returns complete Ace Coins wallet overview, catalog, and recent ledger entries.
   */
  public static async getWalletOverview(
    userId: string
  ): Promise<WalletOverviewResponse> {
    const progress = await this.ensureWalletInitialized(userId);
    const policy = await this.getBonusCoinsAdPolicy();
    const todayKey = this.getEatTodayKey();

    const adsUsedToday =
      progress.wallet?.dailyCoinAdsDate === todayKey
        ? progress.wallet.dailyCoinAdsCount || 0
        : 0;
    const dailyCoinAdsRemaining = Math.max(0, policy.dailyLimit - adsUsedToday);

    const unlockedBadges = progress.wallet?.unlockedBadges || [];
    const catalog: EconomyStoreItem[] = BASE_STORE_CATALOG.map((item) => ({
      ...item,
      owned: item.category === 'badge' ? unlockedBadges.includes(item.itemKey) : undefined,
    }));

    const txs = await CoinTransactionModel.find({
      userId: new Types.ObjectId(userId),
    })
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();

    return {
      currencyName: 'Ace Coins',
      currencyCode: 'AC',
      balance: progress.wallet?.balance ?? ACE_COINS_CONFIG.WELCOME_BONUS,
      lifetimeEarned: progress.wallet?.lifetimeEarned ?? ACE_COINS_CONFIG.WELCOME_BONUS,
      lifetimeSpent: progress.wallet?.lifetimeSpent ?? 0,
      dailyCoinAdsRemaining,
      dailyCoinAdsLimit: policy.dailyLimit,
      coinsPerAd: policy.coinsPerAd,
      assessmentCost: ACE_COINS_CONFIG.UNIT_ASSESSMENT_COST,
      aiPlanPasses: progress.wallet?.aiPlanPasses ?? 0,
      assessmentPasses: progress.wallet?.assessmentPasses ?? 0,
      unlockedBadges,
      storeCatalog: catalog,
      recentTransactions: txs.map((t) => ({
        id: t._id.toString(),
        type: t.type,
        amount: t.amount,
        balanceAfter: t.balanceAfter,
        reason: t.reason,
        itemKey: t.itemKey,
        milestoneKey: t.milestoneKey,
        createdAt: new Date(t.createdAt).toISOString(),
      })),
    };
  }

  /**
   * Atomically deducts Ace Coins and fulfills the selected study perk or honor badge.
   */
  public static async spendCoins(
    userId: string,
    payload: SpendCoinsRequest
  ): Promise<SpendCoinsResponse> {
    const item = BASE_STORE_CATALOG.find((i) => i.itemKey === payload.itemKey);
    if (!item) {
      throw new BadRequestError(`Unknown store item '${payload.itemKey}'`);
    }

    const userObjectId = new Types.ObjectId(userId);
    const progress = await this.ensureWalletInitialized(userObjectId);

    // Pre-validate item preconditions BEFORE deducting coins
    let targetUnitDoc: { _id: Types.ObjectId; code: string } | null = null;
    if (item.itemKey === 'offline_pack') {
      if (!payload.targetUnitId) {
        throw new BadRequestError('targetUnitId is required to unlock an offline pack');
      }
      let unit = null;
      if (Types.ObjectId.isValid(payload.targetUnitId)) {
        unit = await UnitModel.findById(payload.targetUnitId).lean();
      }
      if (!unit) {
        unit = await UnitModel.findOne({
          code: payload.targetUnitId.toUpperCase().trim(),
        }).lean();
      }
      if (!unit) {
        throw new NotFoundError(`Unit '${payload.targetUnitId}' not found`);
      }
      targetUnitDoc = { _id: unit._id as Types.ObjectId, code: unit.code };
    }

    if (item.itemKey === 'streak_repair') {
      if (
        !progress.streak?.previousBrokenStreak ||
        progress.streak.previousBrokenStreak <= 0
      ) {
        throw new BadRequestError('No broken streak available to repair');
      }
    }

    if (
      item.category === 'badge' &&
      (progress.wallet?.unlockedBadges || []).includes(item.itemKey)
    ) {
      throw new BadRequestError(`You already own '${item.title}'`);
    }

    // Atomic deduction preventing negative balance & race conditions
    const deducted = await StudentProgressModel.findOneAndUpdate(
      { userId: userObjectId, 'wallet.balance': { $gte: item.cost } },
      {
        $inc: {
          'wallet.balance': -item.cost,
          'wallet.lifetimeSpent': item.cost,
        },
      },
      { new: true }
    );

    if (!deducted) {
      throw new AppError(
        `Not enough Ace Coins. Need ${item.cost} AC (balance: ${progress.wallet?.balance ?? 0} AC).`,
        400,
        'INSUFFICIENT_COINS'
      );
    }

    const result: SpendCoinsResponse = {
      itemKey: item.itemKey,
      coinsSpent: item.cost,
      newBalance: deducted.wallet.balance,
      message: `${item.title} unlocked!`,
    };

    if (item.itemKey === 'unit_assessment') {
      const updated = await StudentProgressModel.findOneAndUpdate(
        { userId: userObjectId },
        { $inc: { 'wallet.assessmentPasses': 1 } },
        { new: true }
      );
      result.assessmentPasses = updated?.wallet.assessmentPasses ?? 1;
      result.message = 'Unit assessment entry unlocked (-10 AC).';
    } else if (item.itemKey === 'exam_ticket') {
      const updated = await StudentProgressModel.findOneAndUpdate(
        { userId: userObjectId },
        { $inc: { 'examAccess.ticketsAvailable': 1 } },
        { new: true }
      );
      result.examTicketsAvailable = updated?.examAccess.ticketsAvailable ?? 1;
      result.message = '+1 Exam Access Ticket added.';
    } else if (item.itemKey === 'ai_plan_pass') {
      const updated = await StudentProgressModel.findOneAndUpdate(
        { userId: userObjectId },
        { $inc: { 'wallet.aiPlanPasses': 1 } },
        { new: true }
      );
      result.aiPlanPasses = updated?.wallet.aiPlanPasses ?? 1;
      result.message = '+1 AI Study Program Pass added.';
    } else if (item.itemKey === 'streak_repair') {
      const restoredStreak = (deducted.streak.previousBrokenStreak || 0) + 1;
      deducted.streak.currentStreak = restoredStreak;
      if (restoredStreak > deducted.streak.longestStreak) {
        deducted.streak.longestStreak = restoredStreak;
      }
      deducted.streak.previousBrokenStreak = 0;
      deducted.streak.lastRepairedAt = new Date();
      deducted.streak.lastActivityDate = new Date().toISOString().split('T')[0];
      await deducted.save();
      result.repairedStreak = restoredStreak;
      result.message = `Streak restored to ${restoredStreak} days!`;
    } else if (item.itemKey === 'offline_pack' && targetUnitDoc) {
      const expiresAt = new Date(Date.now() + 24 * 3600 * 1000);
      const existingIdx = deducted.offlineAccess.unlockedUnits.findIndex(
        (u) => u.unitId.toString() === targetUnitDoc!._id.toString()
      );
      if (existingIdx >= 0) {
        deducted.offlineAccess.unlockedUnits[existingIdx].expiresAt = expiresAt;
        deducted.offlineAccess.unlockedUnits[existingIdx].unitCode = targetUnitDoc.code;
      } else {
        deducted.offlineAccess.unlockedUnits.push({
          unitId: targetUnitDoc._id,
          unitCode: targetUnitDoc.code,
          expiresAt,
        });
      }
      await deducted.save();
      result.unlockedUnitCode = targetUnitDoc.code;
      result.offlineAccessExpiresAt = expiresAt.toISOString();
      result.message = `24h Offline Pack unlocked for ${targetUnitDoc.code}.`;
    } else if (item.category === 'badge') {
      await StudentProgressModel.updateOne(
        { userId: userObjectId },
        { $addToSet: { 'wallet.unlockedBadges': item.itemKey } }
      );
      result.unlockedBadge = item.itemKey;
      result.message = `Equipped ${item.title}!`;
    }

    await this.recordTransactionSafe({
      userId: userObjectId,
      type: 'spend',
      amount: -item.cost,
      balanceAfter: deducted.wallet.balance,
      reason: targetUnitDoc ? `${item.title} (${targetUnitDoc.code})` : item.title,
      itemKey: item.itemKey,
    });

    return result;
  }
}
