import 'package:flutter/foundation.dart';
import '../../ads/models/acedex_ad_models.dart';

@immutable
class CoinTransactionItem {
  final String id;
  final String type; // 'earn_welcome' | 'earn_milestone' | 'earn_ad' | 'spend'
  final int amount;
  final int balanceAfter;
  final String reason;
  final String? itemKey;
  final String? milestoneKey;
  final String createdAt;

  const CoinTransactionItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.reason,
    this.itemKey,
    this.milestoneKey,
    required this.createdAt,
  });

  bool get isEarn => amount >= 0;

  factory CoinTransactionItem.fromJson(Map<String, dynamic> json) {
    return CoinTransactionItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'earn_milestone',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      itemKey: json['itemKey'] as String?,
      milestoneKey: json['milestoneKey'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

@immutable
class EconomyStoreItem {
  final String itemKey;
  final String title;
  final String description;
  final int cost;
  final String category; // 'access' | 'boost' | 'badge'
  final bool canWatchAdInstead;
  final AcedexRewardType? adRewardType;
  final bool owned;

  const EconomyStoreItem({
    required this.itemKey,
    required this.title,
    required this.description,
    required this.cost,
    required this.category,
    this.canWatchAdInstead = false,
    this.adRewardType,
    this.owned = false,
  });

  factory EconomyStoreItem.fromJson(Map<String, dynamic> json) {
    final rawReward = json['adRewardType'] as String?;
    return EconomyStoreItem(
      itemKey: json['itemKey'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? 'access',
      canWatchAdInstead: json['canWatchAdInstead'] as bool? ?? false,
      adRewardType:
          rawReward != null ? AcedexRewardTypeX.fromApi(rawReward) : null,
      owned: json['owned'] as bool? ?? false,
    );
  }
}

@immutable
class WalletOverview {
  final String currencyName;
  final String currencyCode;
  final int balance;
  final int lifetimeEarned;
  final int lifetimeSpent;
  final int dailyCoinAdsRemaining;
  final int dailyCoinAdsLimit;
  final int coinsPerAd;
  final int assessmentCost;
  final int aiPlanPasses;
  final int assessmentPasses;
  final List<String> unlockedAssessmentUnits;
  final List<String> unlockedBadges;
  final List<EconomyStoreItem> storeCatalog;
  final List<CoinTransactionItem> recentTransactions;

  const WalletOverview({
    this.currencyName = 'Ace Coins',
    this.currencyCode = 'AC',
    this.balance = 25,
    this.lifetimeEarned = 25,
    this.lifetimeSpent = 0,
    this.dailyCoinAdsRemaining = 999999,
    this.dailyCoinAdsLimit = 0,
    this.coinsPerAd = 10,
    this.assessmentCost = 15,
    this.aiPlanPasses = 0,
    this.assessmentPasses = 0,
    this.unlockedAssessmentUnits = const [],
    this.unlockedBadges = const [],
    this.storeCatalog = const [],
    this.recentTransactions = const [],
  });

  factory WalletOverview.fromJson(Map<String, dynamic> json) {
    return WalletOverview(
      currencyName: json['currencyName'] as String? ?? 'Ace Coins',
      currencyCode: json['currencyCode'] as String? ?? 'AC',
      balance: (json['balance'] as num?)?.toInt() ?? 25,
      lifetimeEarned: (json['lifetimeEarned'] as num?)?.toInt() ?? 25,
      lifetimeSpent: (json['lifetimeSpent'] as num?)?.toInt() ?? 0,
      dailyCoinAdsRemaining:
          (json['dailyCoinAdsRemaining'] as num?)?.toInt() ?? 999999,
      dailyCoinAdsLimit: (json['dailyCoinAdsLimit'] as num?)?.toInt() ?? 0,
      coinsPerAd: (json['coinsPerAd'] as num?)?.toInt() ?? 10,
      assessmentCost: (json['assessmentCost'] as num?)?.toInt() ?? 15,
      aiPlanPasses: (json['aiPlanPasses'] as num?)?.toInt() ?? 0,
      assessmentPasses: (json['assessmentPasses'] as num?)?.toInt() ?? 0,
      unlockedAssessmentUnits:
          (json['unlockedAssessmentUnits'] as List<dynamic>? ?? [])
              .map((e) => e.toString().toUpperCase())
              .toList(),
      unlockedBadges: (json['unlockedBadges'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      storeCatalog: (json['storeCatalog'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(EconomyStoreItem.fromJson)
          .toList(),
      recentTransactions: (json['recentTransactions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CoinTransactionItem.fromJson)
          .toList(),
    );
  }
}

@immutable
class SpendCoinsResult {
  final String itemKey;
  final int coinsSpent;
  final int newBalance;
  final String message;
  final int? assessmentPasses;
  final int? examTicketsAvailable;
  final int? aiPlanPasses;
  final int? repairedStreak;
  final String? unlockedUnitCode;
  final String? unlockedBadge;

  const SpendCoinsResult({
    required this.itemKey,
    required this.coinsSpent,
    required this.newBalance,
    required this.message,
    this.assessmentPasses,
    this.examTicketsAvailable,
    this.aiPlanPasses,
    this.repairedStreak,
    this.unlockedUnitCode,
    this.unlockedBadge,
  });

  factory SpendCoinsResult.fromJson(Map<String, dynamic> json) {
    return SpendCoinsResult(
      itemKey: json['itemKey'] as String? ?? '',
      coinsSpent: (json['coinsSpent'] as num?)?.toInt() ?? 0,
      newBalance: (json['newBalance'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? 'Unlocked!',
      assessmentPasses: (json['assessmentPasses'] as num?)?.toInt(),
      examTicketsAvailable: (json['examTicketsAvailable'] as num?)?.toInt(),
      aiPlanPasses: (json['aiPlanPasses'] as num?)?.toInt(),
      repairedStreak: (json['repairedStreak'] as num?)?.toInt(),
      unlockedUnitCode: json['unlockedUnitCode'] as String?,
      unlockedBadge: json['unlockedBadge'] as String?,
    );
  }
}
