import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../network/api_client.dart';
import '../../network/api_endpoints.dart';
import '../models/economy_models.dart';

/// Repository boundary for Ace Coins economy APIs (`/api/v1/economy/*`).
abstract class EconomyRepository {
  Future<WalletOverview> fetchWallet();
  Future<SpendCoinsResult> spendCoins({
    required String itemKey,
    String? targetUnitId,
  });
}

class EconomyService implements EconomyRepository {
  static final EconomyService instance = EconomyService();

  final ApiClient _apiClient;

  EconomyService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  /// Live student Ace Coins balance synchronized across Header Bar, Wallet, and study flows.
  final ValueNotifier<int> coinBalanceNotifier = ValueNotifier<int>(25);

  /// Cached latest full wallet snapshot.
  final ValueNotifier<WalletOverview?> walletNotifier =
      ValueNotifier<WalletOverview?>(null);

  void reset() {
    coinBalanceNotifier.value = 25;
    walletNotifier.value = null;
  }

  void applyServerBalanceUpdate({
    int? coinsAwarded,
    int? newCoinBalance,
  }) {
    if (newCoinBalance != null && newCoinBalance >= 0) {
      coinBalanceNotifier.value = newCoinBalance;
    } else if (coinsAwarded != null && coinsAwarded != 0) {
      coinBalanceNotifier.value =
          (coinBalanceNotifier.value + coinsAwarded).clamp(0, 999999);
    }
    unawaited(syncWalletSilent());
  }

  Future<void> syncWalletSilent() async {
    try {
      await fetchWallet();
    } catch (_) {
      // Offline or unauthenticated calls leave cached state intact.
    }
  }

  @override
  Future<WalletOverview> fetchWallet() async {
    final res = await _apiClient.get(
      ApiEndpoints.economyWallet,
      requiresAuth: true,
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final overview = WalletOverview.fromJson(data);
    coinBalanceNotifier.value = overview.balance;
    walletNotifier.value = overview;
    return overview;
  }

  @override
  Future<SpendCoinsResult> spendCoins({
    required String itemKey,
    String? targetUnitId,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.economySpend,
      requiresAuth: true,
      body: {
        'itemKey': itemKey,
        if (targetUnitId != null && targetUnitId.isNotEmpty)
          'targetUnitId': targetUnitId,
      },
    );
    final data = (res['data'] as Map<String, dynamic>?) ?? res;
    final result = SpendCoinsResult.fromJson(data);
    coinBalanceNotifier.value = result.newBalance;
    unawaited(syncWalletSilent());
    return result;
  }
}
