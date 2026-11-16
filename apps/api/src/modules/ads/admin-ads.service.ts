import { AdminAdAnalyticsData, AdConfigData } from '@acedex/contracts';
import { AdSessionModel } from './models/ad-session.model';
import { AdConfigModel } from './models/ad-config.model';
import { AdsService } from './ads.service';
import { AuditService } from '../audit/audit.service';
import { logger } from '../../common/utils/logger';

export class AdminAdsService {
  /**
   * Aggregates ad viewing metrics, completion funnel rates, and revenue proxies
   */
  public static async getAdAnalytics(): Promise<AdminAdAnalyticsData> {
    const now = new Date();
    const startOfToday = new Date(now);
    startOfToday.setUTCHours(0, 0, 0, 0);

    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 3600 * 1000);
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 3600 * 1000);

    const [
      totalSessionsStarted,
      totalAdsCompleted,
      uniqueViewersTodayList,
      streakRepairCount,
      examAccessCount,
      offlinePackCount,
      androidCount,
      iosCount,
      todayCompletedCount,
      last7DaysCompletedCount,
      last30DaysCompletedCount,
    ] = await Promise.all([
      AdSessionModel.countDocuments({}),
      AdSessionModel.countDocuments({ status: 'claimed' }),
      AdSessionModel.distinct('userId', {
        status: 'claimed',
        claimedAt: { $gte: startOfToday },
      }),
      AdSessionModel.countDocuments({ status: 'claimed', rewardType: 'streak_repair' }),
      AdSessionModel.countDocuments({ status: 'claimed', rewardType: 'exam_access' }),
      AdSessionModel.countDocuments({ status: 'claimed', rewardType: 'offline_pack' }),
      AdSessionModel.countDocuments({ status: 'claimed', platform: 'android' }),
      AdSessionModel.countDocuments({ status: 'claimed', platform: 'ios' }),
      AdSessionModel.countDocuments({ status: 'claimed', claimedAt: { $gte: startOfToday } }),
      AdSessionModel.countDocuments({ status: 'claimed', claimedAt: { $gte: sevenDaysAgo } }),
      AdSessionModel.countDocuments({ status: 'claimed', claimedAt: { $gte: thirtyDaysAgo } }),
    ]);

    const completionFunnelRate =
      totalSessionsStarted > 0
        ? Math.round((totalAdsCompleted / totalSessionsStarted) * 1000) / 10
        : 0;

    return {
      summary: {
        totalAdsCompleted,
        totalSessionsStarted,
        completionFunnelRate,
        uniqueViewersToday: uniqueViewersTodayList.length,
      },
      byRewardType: {
        streakRepair: streakRepairCount,
        examAccess: examAccessCount,
        offlinePack: offlinePackCount,
      },
      byPlatform: {
        android: androidCount,
        ios: iosCount,
      },
      timeSeries: {
        today: todayCompletedCount,
        last7Days: last7DaysCompletedCount,
        last30Days: last30DaysCompletedCount,
      },
    };
  }

  /**
   * Retrieves paginated ad sessions for auditing
   */
  public static async getAdSessions(page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [total, sessions] = await Promise.all([
      AdSessionModel.countDocuments({}),
      AdSessionModel.find({})
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('userId', 'fullName email phone studentId role')
        .lean(),
    ]);

    return {
      sessions,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Updates remote Unity Ad configurations and policies with audit logging
   */
  public static async updateConfig(
    updates: Partial<{
      isAdsEnabled: boolean;
      androidGameId: string;
      iosGameId: string;
      androidPlacement: string;
      iosPlacement: string;
      policies: {
        streakRepair?: { enabled?: boolean; cooldownHours?: number };
        examAccess?: { enabled?: boolean; ticketsPerAd?: number; starterTickets?: number };
        offlinePack?: { enabled?: boolean; durationHours?: number };
      };
    }>,
    adminContext?: { userId?: string; email?: string }
  ): Promise<AdConfigData> {
    let config = await AdConfigModel.findOne({ singletonId: 'global_ad_config' });

    if (!config) {
      config = new AdConfigModel({ singletonId: 'global_ad_config' });
    }

    if (typeof updates.isAdsEnabled === 'boolean') {
      config.isAdsEnabled = updates.isAdsEnabled;
    }
    if (updates.androidGameId) config.androidGameId = updates.androidGameId;
    if (updates.iosGameId) config.iosGameId = updates.iosGameId;
    if (updates.androidPlacement) config.androidPlacement = updates.androidPlacement;
    if (updates.iosPlacement) config.iosPlacement = updates.iosPlacement;

    if (updates.policies) {
      if (updates.policies.streakRepair) {
        if (typeof updates.policies.streakRepair.enabled === 'boolean') {
          config.policies.streakRepair.enabled = updates.policies.streakRepair.enabled;
        }
        if (typeof updates.policies.streakRepair.cooldownHours === 'number') {
          config.policies.streakRepair.cooldownHours = updates.policies.streakRepair.cooldownHours;
        }
      }
      if (updates.policies.examAccess) {
        if (typeof updates.policies.examAccess.enabled === 'boolean') {
          config.policies.examAccess.enabled = updates.policies.examAccess.enabled;
        }
        if (typeof updates.policies.examAccess.ticketsPerAd === 'number') {
          config.policies.examAccess.ticketsPerAd = updates.policies.examAccess.ticketsPerAd;
        }
        if (typeof updates.policies.examAccess.starterTickets === 'number') {
          config.policies.examAccess.starterTickets = updates.policies.examAccess.starterTickets;
        }
      }
      if (updates.policies.offlinePack) {
        if (typeof updates.policies.offlinePack.enabled === 'boolean') {
          config.policies.offlinePack.enabled = updates.policies.offlinePack.enabled;
        }
        if (typeof updates.policies.offlinePack.durationHours === 'number') {
          config.policies.offlinePack.durationHours = updates.policies.offlinePack.durationHours;
        }
      }
    }

    await config.save();

    await AuditService.record({
      userId: adminContext?.userId,
      userEmail: adminContext?.email,
      action: 'UPDATE_AD_CONFIG',
      resource: 'ad_config',
      resourceId: config._id.toString(),
      details: updates,
    });

    logger.info({ adminContext, updates }, 'Ad configuration updated by admin');
    return AdsService.getConfig();
  }
}
