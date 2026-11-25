import 'package:flutter/foundation.dart';

/// All supported ACEDEX rewarded ad utilities synchronized with backend `RewardTypeSchema`.
enum AcedexRewardType {
  examAccess,
  offlinePack,
  streakRepair,
  aiStudyPlan,
  bonusCoins,
}

extension AcedexRewardTypeX on AcedexRewardType {
  String get apiValue {
    switch (this) {
      case AcedexRewardType.examAccess:
        return 'exam_access';
      case AcedexRewardType.offlinePack:
        return 'offline_pack';
      case AcedexRewardType.streakRepair:
        return 'streak_repair';
      case AcedexRewardType.aiStudyPlan:
        return 'ai_study_plan';
      case AcedexRewardType.bonusCoins:
        return 'bonus_coins';
    }
  }

  String get defaultHeadline {
    switch (this) {
      case AcedexRewardType.examAccess:
        return 'Unlock EUEE Exam Pass';
      case AcedexRewardType.offlinePack:
        return 'Unlock 24h Offline Pack';
      case AcedexRewardType.streakRepair:
        return 'Restore Study Streak';
      case AcedexRewardType.aiStudyPlan:
        return 'Unlock Acedex AI Plan';
      case AcedexRewardType.bonusCoins:
        return 'Earn +10 Ace Coins';
    }
  }

  String get defaultSubtitle {
    switch (this) {
      case AcedexRewardType.examAccess:
        return 'Watch 1 short rewarded ad to earn free EUEE exam ticket access.';
      case AcedexRewardType.offlinePack:
        return 'Watch 1 short rewarded ad to download this unit for 24-hour offline study.';
      case AcedexRewardType.streakRepair:
        return 'Watch 1 short rewarded ad to repair your broken study streak (+1 day).';
      case AcedexRewardType.aiStudyPlan:
        return 'Watch 1 short rewarded ad to generate your personalized Acedex AI topic roadmap.';
      case AcedexRewardType.bonusCoins:
        return 'Watch 1 short rewarded ad to add +10 Ace Coins to your study wallet.';
    }
  }

  static AcedexRewardType fromApi(String? raw) {
    switch (raw) {
      case 'exam_access':
        return AcedexRewardType.examAccess;
      case 'offline_pack':
        return AcedexRewardType.offlinePack;
      case 'streak_repair':
        return AcedexRewardType.streakRepair;
      case 'bonus_coins':
        return AcedexRewardType.bonusCoins;
      case 'ai_study_plan':
      default:
        return AcedexRewardType.aiStudyPlan;
    }
  }
}

/// Global Unity Ads IDs and reward policy config returned by `GET /api/v1/ads/config`.
@immutable
class AcedexAdConfig {
  final bool enabled;
  final String androidGameId;
  final String iosGameId;
  final String androidPlacement;
  final String iosPlacement;
  final bool streakRepairEnabled;
  final int streakCooldownHours;
  final bool examAccessEnabled;
  final int ticketsPerAd;
  final bool offlinePackEnabled;
  final int offlineDurationHours;

  const AcedexAdConfig({
    this.enabled = true,
    this.androidGameId = '6220248',
    this.iosGameId = '6220249',
    this.androidPlacement = 'Reward_Android_Acedex',
    this.iosPlacement = 'Rewarded_iOS',
    this.streakRepairEnabled = true,
    this.streakCooldownHours = 24,
    this.examAccessEnabled = true,
    this.ticketsPerAd = 1,
    this.offlinePackEnabled = true,
    this.offlineDurationHours = 24,
  });

  factory AcedexAdConfig.fromJson(Map<String, dynamic> json) {
    final unity = json['unityAds'] as Map<String, dynamic>? ?? {};
    final policies = json['policies'] as Map<String, dynamic>? ?? {};
    final streak = policies['streakRepair'] as Map<String, dynamic>? ?? {};
    final exam = policies['examAccess'] as Map<String, dynamic>? ?? {};
    final offline = policies['offlinePack'] as Map<String, dynamic>? ?? {};

    return AcedexAdConfig(
      enabled: json['enabled'] as bool? ?? true,
      androidGameId: unity['androidGameId'] as String? ?? '6220248',
      iosGameId: unity['iosGameId'] as String? ?? '6220249',
      androidPlacement:
          unity['androidPlacement'] as String? ?? 'Reward_Android_Acedex',
      iosPlacement: unity['iosPlacement'] as String? ?? 'Rewarded_iOS',
      streakRepairEnabled: streak['enabled'] as bool? ?? true,
      streakCooldownHours: (streak['cooldownHours'] as num?)?.toInt() ?? 24,
      examAccessEnabled: exam['enabled'] as bool? ?? true,
      ticketsPerAd: (exam['ticketsPerAd'] as num?)?.toInt() ?? 1,
      offlinePackEnabled: offline['enabled'] as bool? ?? true,
      offlineDurationHours: (offline['durationHours'] as num?)?.toInt() ?? 24,
    );
  }
}

/// Server-created rewarded ad session returned by `POST /api/v1/ads/session/start`.
@immutable
class AcedexAdSession {
  final String adSessionId;
  final AcedexRewardType rewardType;
  final String gameId;
  final String placementId;
  final DateTime startedAtLocal;
  final String expiresAt;

  const AcedexAdSession({
    required this.adSessionId,
    required this.rewardType,
    required this.gameId,
    required this.placementId,
    required this.startedAtLocal,
    this.expiresAt = '',
  });

  factory AcedexAdSession.fromJson(Map<String, dynamic> json) {
    return AcedexAdSession(
      adSessionId: json['adSessionId'] as String? ?? '',
      rewardType: AcedexRewardTypeX.fromApi(json['rewardType'] as String?),
      gameId: json['gameId'] as String? ?? '6220248',
      placementId: json['placementId'] as String? ?? 'Reward_Android_Acedex',
      startedAtLocal: DateTime.now(),
      expiresAt: json['expiresAt'] as String? ?? '',
    );
  }
}

/// Verified reward payload returned by `POST /api/v1/ads/reward/claim`.
@immutable
class AcedexClaimRewardResult {
  final AcedexRewardType rewardType;
  final String adSessionId;
  final int? repairedStreak;
  final int? examTicketsAvailable;
  final String? unlockedUnitId;
  final String? unlockedUnitCode;
  final String? offlineAccessExpiresAt;
  final bool? aiStudyPlanUnlocked;
  final String? aiPlanAdSessionId;
  final int? coinsAwarded;
  final int? newCoinBalance;
  final int? dailyCoinAdsRemaining;

  const AcedexClaimRewardResult({
    required this.rewardType,
    required this.adSessionId,
    this.repairedStreak,
    this.examTicketsAvailable,
    this.unlockedUnitId,
    this.unlockedUnitCode,
    this.offlineAccessExpiresAt,
    this.aiStudyPlanUnlocked,
    this.aiPlanAdSessionId,
    this.coinsAwarded,
    this.newCoinBalance,
    this.dailyCoinAdsRemaining,
  });

  factory AcedexClaimRewardResult.fromJson(
    Map<String, dynamic> json, {
    required String adSessionId,
  }) {
    return AcedexClaimRewardResult(
      rewardType: AcedexRewardTypeX.fromApi(json['rewardType'] as String?),
      adSessionId: adSessionId,
      repairedStreak: (json['repairedStreak'] as num?)?.toInt(),
      examTicketsAvailable: (json['examTicketsAvailable'] as num?)?.toInt(),
      unlockedUnitId: json['unlockedUnitId'] as String?,
      unlockedUnitCode: json['unlockedUnitCode'] as String?,
      offlineAccessExpiresAt: json['offlineAccessExpiresAt'] as String?,
      aiStudyPlanUnlocked: json['aiStudyPlanUnlocked'] as bool?,
      aiPlanAdSessionId: json['aiPlanAdSessionId'] as String? ?? adSessionId,
      coinsAwarded: (json['coinsAwarded'] as num?)?.toInt(),
      newCoinBalance: (json['newCoinBalance'] as num?)?.toInt(),
      dailyCoinAdsRemaining: (json['dailyCoinAdsRemaining'] as num?)?.toInt(),
    );
  }
}

/// Current student ad entitlements returned by `GET /api/v1/ads/status`.
@immutable
class AcedexStudentAdStatus {
  final int currentStreak;
  final bool canRepairStreak;
  final int? brokenStreakCount;
  final bool canTakeExam;
  final int ticketsAvailable;
  final bool requiresExamAd;
  final List<String> unlockedUnitCodes;

  const AcedexStudentAdStatus({
    this.currentStreak = 0,
    this.canRepairStreak = false,
    this.brokenStreakCount,
    this.canTakeExam = true,
    this.ticketsAvailable = 0,
    this.requiresExamAd = false,
    this.unlockedUnitCodes = const [],
  });

  factory AcedexStudentAdStatus.fromJson(Map<String, dynamic> json) {
    final streak = json['streak'] as Map<String, dynamic>? ?? {};
    final exam = json['examAccess'] as Map<String, dynamic>? ?? {};
    final offline = json['offlineAccess'] as Map<String, dynamic>? ?? {};
    final unlocked = (offline['unlockedUnits'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((u) => u['unitCode'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toList();

    return AcedexStudentAdStatus(
      currentStreak: (streak['currentStreak'] as num?)?.toInt() ?? 0,
      canRepairStreak: streak['canRepair'] as bool? ?? false,
      brokenStreakCount: (streak['brokenStreakCount'] as num?)?.toInt(),
      canTakeExam: exam['canTakeExam'] as bool? ?? true,
      ticketsAvailable: (exam['ticketsAvailable'] as num?)?.toInt() ?? 0,
      requiresExamAd: exam['requiresAd'] as bool? ?? false,
      unlockedUnitCodes: unlocked,
    );
  }
}
