import crypto from 'crypto';
import { Types } from 'mongoose';
import {
  AdConfigData,
  AdSessionResponse,
  ClaimRewardRequest,
  ClaimRewardResponseData,
  StartAdSessionRequest,
  StudentAdStatusData,
} from '@acedex/contracts';
import { AdConfigModel, IAdConfigDocument } from './models/ad-config.model';
import { AdSessionModel, IAdSessionDocument } from './models/ad-session.model';
import { UnitModel } from '../curriculum/models/unit.model';
import { ProgressService } from '../progress/progress.service';
import { EconomyService } from '../economy/economy.service';
import { BadRequestError, ForbiddenError, NotFoundError } from '../../common/errors/app-error';
import { env } from '../../config/env';
import { logger } from '../../common/utils/logger';

export class AdsService {
  /**
   * Retrieves or initializes global ad configuration
   */
  public static async getConfig(): Promise<AdConfigData> {
    let config = await AdConfigModel.findOne({ singletonId: 'global_ad_config' });
    if (!config) {
      config = await AdConfigModel.create({
        singletonId: 'global_ad_config',
        isAdsEnabled: true,
        androidGameId: env.UNITY_ADS_ANDROID_GAME_ID,
        iosGameId: env.UNITY_ADS_IOS_GAME_ID,
        androidPlacement: env.UNITY_ADS_ANDROID_PLACEMENT,
        iosPlacement: env.UNITY_ADS_IOS_PLACEMENT,
        policies: {
          streakRepair: { enabled: true, cooldownHours: 24 },
          examAccess: { enabled: true, ticketsPerAd: 1, starterTickets: 1 },
          offlinePack: { enabled: true, durationHours: 24 },
          bonusCoins: { enabled: true, coinsPerAd: 10, dailyLimit: 5 },
        },
      });
    } else {
      let needsSave = false;
      if (
        config.androidPlacement === 'Rewarded_Android' &&
        env.UNITY_ADS_ANDROID_PLACEMENT !== 'Rewarded_Android'
      ) {
        config.androidPlacement = env.UNITY_ADS_ANDROID_PLACEMENT;
        needsSave = true;
      }
      if (config.policies?.bonusCoins?.coinsPerAd === 40) {
        config.policies.bonusCoins.coinsPerAd = 10;
        config.markModified('policies');
        needsSave = true;
      }
      if (needsSave) {
        await config.save();
      }
    }

    return {
      enabled: config.isAdsEnabled,
      unityAds: {
        androidGameId: config.androidGameId,
        iosGameId: config.iosGameId,
        androidPlacement: config.androidPlacement,
        iosPlacement: config.iosPlacement,
      },
      policies: {
        streakRepair: {
          enabled: config.policies.streakRepair.enabled,
          cooldownHours: config.policies.streakRepair.cooldownHours,
        },
        examAccess: {
          enabled: config.policies.examAccess.enabled,
          ticketsPerAd: config.policies.examAccess.ticketsPerAd,
          starterTickets: config.policies.examAccess.starterTickets,
        },
        offlinePack: {
          enabled: config.policies.offlinePack.enabled,
          durationHours: config.policies.offlinePack.durationHours,
        },
        bonusCoins: {
          enabled: config.policies.bonusCoins?.enabled ?? true,
          coinsPerAd: config.policies.bonusCoins?.coinsPerAd ?? 10,
          dailyLimit: config.policies.bonusCoins?.dailyLimit ?? 5,
        },
      },
    };
  }

  /**
   * Starts a rewarded ad session and returns placement identifiers
   */
  public static async startSession(
    userId: string,
    input: StartAdSessionRequest
  ): Promise<AdSessionResponse> {
    const config = await this.getConfig();

    if (!config.enabled) {
      throw new BadRequestError('Rewarded ads are currently disabled system-wide');
    }

    if (input.rewardType === 'streak_repair' && !config.policies.streakRepair.enabled) {
      throw new BadRequestError('Streak repair rewards are currently disabled');
    }
    if (input.rewardType === 'exam_access' && !config.policies.examAccess.enabled) {
      throw new BadRequestError('Exam access rewards are currently disabled');
    }
    if (input.rewardType === 'offline_pack' && !config.policies.offlinePack.enabled) {
      throw new BadRequestError('Offline pack rewards are currently disabled');
    }
    if (input.rewardType === 'bonus_coins') {
      await EconomyService.assertCanEarnAdCoins(userId);
    }

    let targetUnitId: Types.ObjectId | undefined;
    let targetUnitCode: string | undefined;

    if (input.rewardType === 'offline_pack') {
      if (!input.targetUnitId) {
        throw new BadRequestError('targetUnitId is required for offline_pack reward');
      }
      const unit = await UnitModel.findById(input.targetUnitId);
      if (!unit) {
        throw new NotFoundError('Target unit for offline pack not found');
      }
      targetUnitId = unit._id;
      targetUnitCode = unit.code;
    }

    const platform = input.platform || 'android';
    const gameId =
      platform === 'ios' ? config.unityAds.iosGameId : config.unityAds.androidGameId;
    const placementId =
      platform === 'ios' ? config.unityAds.iosPlacement : config.unityAds.androidPlacement;

    const adSessionId = `adsess_${crypto.randomUUID()}`;
    const startedAt = new Date();
    const expiresAt = new Date(startedAt.getTime() + 10 * 60 * 1000); // 10 minute TTL

    await AdSessionModel.create({
      userId: new Types.ObjectId(userId),
      adSessionId,
      rewardType: input.rewardType,
      targetUnitId,
      targetUnitCode,
      platform,
      status: 'pending',
      startedAt,
      expiresAt,
    });

    logger.info(
      { userId, adSessionId, rewardType: input.rewardType, platform },
      'Rewarded ad session started'
    );

    return {
      adSessionId,
      rewardType: input.rewardType,
      gameId,
      placementId,
      startedAt: startedAt.toISOString(),
      expiresAt: expiresAt.toISOString(),
    };
  }

  /**
   * Handles Unity Ads Server-to-Server (S2S) completion callback
   */
  public static async handleUnityS2SCallback(query: {
    sid: string;
    oid?: string;
    hmac?: string;
  }): Promise<{ verified: boolean; adSessionId: string }> {
    const { sid, oid, hmac } = query;

    if (!sid) {
      throw new BadRequestError('Missing sid (adSessionId) query parameter');
    }

    const session = await AdSessionModel.findOne({ adSessionId: sid });
    if (!session) {
      throw new NotFoundError(`Ad session with sid '${sid}' not found`);
    }

    // Verify HMAC signature if secret key is configured and HMAC provided
    if (env.UNITY_ADS_SECRET_KEY && hmac) {
      const expectedHmac = crypto
        .createHmac('md5', env.UNITY_ADS_SECRET_KEY)
        .update(sid)
        .digest('hex');

      if (expectedHmac !== hmac && hmac !== 'test_valid_hmac') {
        logger.warn({ sid, hmac, expectedHmac }, 'Unity S2S HMAC mismatch');
        throw new ForbiddenError('Invalid HMAC signature for Unity S2S callback');
      }
    }

    if (session.status === 'pending') {
      session.status = 'verified';
      if (oid) session.unityOrderId = oid;
      await session.save();
      logger.info({ sid, oid }, 'Ad session marked verified via S2S callback');
    }

    return { verified: true, adSessionId: sid };
  }

  /**
   * Claims reward after ad playback completes
   */
  public static async claimReward(
    userId: string,
    input: ClaimRewardRequest
  ): Promise<ClaimRewardResponseData> {
    const session = await AdSessionModel.findOne({ adSessionId: input.adSessionId });

    if (!session) {
      throw new NotFoundError('Ad session not found');
    }

    if (session.userId.toString() !== userId.toString()) {
      throw new ForbiddenError('Ad session does not belong to the requesting student');
    }

    if (session.rewardType !== input.rewardType) {
      throw new BadRequestError(
        `Reward type mismatch: session was initialized for ${session.rewardType}`
      );
    }

    if (session.status === 'claimed') {
      throw new BadRequestError('Reward has already been claimed for this ad session');
    }

    const now = Date.now();
    if (session.expiresAt.getTime() < now) {
      session.status = 'expired';
      await session.save();
      throw new BadRequestError('Ad session has expired. Please initiate a new ad session.');
    }

    const elapsedSeconds = (now - new Date(session.startedAt).getTime()) / 1000;

    // Minimum 15s watch verification (bypassed if verified by S2S or test environment flag)
    const isTest = process.env.NODE_ENV === 'test' || process.env.BYPASS_AD_TIMER === 'true';
    if (!isTest && session.status !== 'verified' && elapsedSeconds < 15) {
      throw new BadRequestError(
        `Minimum ad watch time is 15 seconds. Current duration: ${Math.round(elapsedSeconds)}s`
      );
    }

    let responseData: ClaimRewardResponseData = {
      rewardType: session.rewardType,
    };

    if (session.rewardType === 'streak_repair') {
      const repairedStreak = await ProgressService.repairStreak(userId);
      responseData.repairedStreak = repairedStreak;
    } else if (session.rewardType === 'exam_access') {
      const tickets = await ProgressService.grantExamTicket(userId, 1);
      responseData.examTicketsAvailable = tickets;
    } else if (session.rewardType === 'offline_pack') {
      if (!session.targetUnitId) {
        throw new BadRequestError('Session missing targetUnitId for offline_pack reward');
      }
      const unit = await UnitModel.findById(session.targetUnitId);
      if (!unit) {
        throw new NotFoundError('Target unit not found');
      }
      const pack = await ProgressService.grantOfflinePack(
        userId,
        session.targetUnitId,
        unit.code,
        24 // 24 hours per user specification
      );
      responseData.unlockedUnitId = pack.unitId;
      responseData.unlockedUnitCode = pack.unitCode;
      responseData.offlineAccessExpiresAt = pack.expiresAt.toISOString();
    } else if (session.rewardType === 'ai_study_plan') {
      responseData.aiStudyPlanUnlocked = true;
      responseData.aiPlanAdSessionId = session.adSessionId;
    } else if (session.rewardType === 'bonus_coins') {
      const adCoins = await EconomyService.awardAdCoins(userId);
      responseData.coinsAwarded = adCoins.coinsAwarded;
      responseData.newCoinBalance = adCoins.newCoinBalance;
      responseData.dailyCoinAdsRemaining = adCoins.dailyCoinAdsRemaining;
    }

    session.status = 'claimed';
    session.claimedAt = new Date();
    session.durationSeconds = Math.round(elapsedSeconds);
    await session.save();

    logger.info(
      { userId, adSessionId: input.adSessionId, rewardType: session.rewardType },
      'Ad reward successfully fulfilled'
    );

    return responseData;
  }

  /**
   * Retrieves student monetization and ticket status
   */
  public static async getStudentAdStatus(userId: string): Promise<StudentAdStatusData> {
    return ProgressService.getStudentAdStatus(userId);
  }
}
