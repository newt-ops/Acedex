import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/ads/ads.dart';
import 'package:acedex/core/economy/economy.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/core/ui/ui.dart';

class _FakeEconomyRepo implements EconomyRepository {
  WalletOverview overview = const WalletOverview(
    balance: 25,
    lifetimeEarned: 25,
    lifetimeSpent: 0,
    dailyCoinAdsRemaining: 5,
    dailyCoinAdsLimit: 5,
    coinsPerAd: 40,
    assessmentCost: 10,
    storeCatalog: [
      EconomyStoreItem(
        itemKey: 'unit_assessment',
        title: 'Unit 15-Q Assessment Entry',
        description: 'Unlock 1 unit exam attempt.',
        cost: 10,
        category: 'access',
      ),
      EconomyStoreItem(
        itemKey: 'ai_plan_pass',
        title: 'AI Study Program Pass',
        description: 'Recalibrate without waiting for an ad.',
        cost: 100,
        category: 'boost',
      ),
    ],
    recentTransactions: [
      CoinTransactionItem(
        id: 'tx1',
        type: 'earn_welcome',
        amount: 25,
        balanceAfter: 25,
        reason: 'Welcome Bonus — First Study Steps',
        createdAt: '2026-11-25T04:00:00.000Z',
      ),
    ],
  );

  @override
  Future<WalletOverview> fetchWallet() async => overview;

  @override
  Future<SpendCoinsResult> spendCoins({
    required String itemKey,
    String? targetUnitId,
  }) async {
    final nextBal = (overview.balance - 10).clamp(0, 9999);
    overview = WalletOverview(
      balance: nextBal,
      lifetimeEarned: overview.lifetimeEarned,
      lifetimeSpent: overview.lifetimeSpent + 10,
      dailyCoinAdsRemaining: overview.dailyCoinAdsRemaining,
      storeCatalog: overview.storeCatalog,
      recentTransactions: overview.recentTransactions,
    );
    return SpendCoinsResult(
      itemKey: itemKey,
      coinsSpent: 10,
      newBalance: nextBal,
      message: 'Unit assessment entry unlocked (-10 AC).',
      assessmentPasses: 1,
    );
  }
}

class _FakeBonusCoinsAdsRepo implements AcedexAdsRepository {
  final _FakeEconomyRepo economyRepo;

  _FakeBonusCoinsAdsRepo(this.economyRepo);

  @override
  int get minimumWatchSeconds => 1;

  @override
  Future<AcedexAdConfig> fetchConfig() async => const AcedexAdConfig();

  @override
  Future<AcedexStudentAdStatus> fetchStudentStatus() async =>
      const AcedexStudentAdStatus();

  @override
  Future<AcedexAdSession> startRewardedSession({
    required AcedexRewardType rewardType,
    String? targetUnitId,
  }) async {
    return AcedexAdSession(
      adSessionId: 'adsess_coins_01',
      rewardType: rewardType,
      gameId: '6220248',
      placementId: 'Rewarded_Android',
      startedAtLocal: DateTime.now(),
    );
  }

  @override
  Future<bool> showUnityRewardedAd(AcedexAdSession session) async => true;

  @override
  Future<AcedexClaimRewardResult> claimReward({
    required String adSessionId,
    required AcedexRewardType rewardType,
  }) async {
    final newBal = economyRepo.overview.balance + 40;
    economyRepo.overview = WalletOverview(
      balance: newBal,
      lifetimeEarned: economyRepo.overview.lifetimeEarned + 40,
      lifetimeSpent: economyRepo.overview.lifetimeSpent,
      dailyCoinAdsRemaining: economyRepo.overview.dailyCoinAdsRemaining - 1,
      storeCatalog: economyRepo.overview.storeCatalog,
      recentTransactions: economyRepo.overview.recentTransactions,
    );
    return AcedexClaimRewardResult(
      rewardType: rewardType,
      adSessionId: adSessionId,
      coinsAwarded: 40,
      newCoinBalance: newBal,
      dailyCoinAdsRemaining: economyRepo.overview.dailyCoinAdsRemaining,
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    EconomyService.instance.reset();
  });

  testWidgets('AcedexHeaderBar renders live Ace Coin Pill and updates reactively',
      (tester) async {
    const user = UserProfile(
      id: 'usr_coin',
      acedexId: 'ETH-COIN-1',
      displayName: 'Dawit Tesfaye',
      grade: 12,
      stream: 'natural',
      role: 'student',
      status: 'active',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          appBar: AcedexHeaderBar(user: user),
          body: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('header_coin_wallet_button')), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    EconomyService.instance.coinBalanceNotifier.value = 65;
    await tester.pumpAndSettle();
    expect(find.text('65'), findsOneWidget);
  });

  testWidgets('AcedexWalletSheet watches Rewarded Ad (+40 AC) and spends 10 AC cleanly',
      (tester) async {
    final fakeEconomy = _FakeEconomyRepo();
    final fakeAds = _FakeBonusCoinsAdsRepo(fakeEconomy);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  unawaited(
                    AcedexWalletSheet.show(
                      context,
                      economyRepository: fakeEconomy,
                      adsRepository: fakeAds,
                    ),
                  );
                },
                child: const Text('Open Wallet'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('25 AC'), findsOneWidget);
    expect(find.text('Watch 1 Ad (+40 AC • 5/5 left)'), findsOneWidget);

    // Watch Rewarded Ad -> +40 AC (25 -> 65 AC)
    await tester.tap(find.text('Watch 1 Ad (+40 AC • 5/5 left)'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('65 AC'), findsOneWidget);
    expect(EconomyService.instance.coinBalanceNotifier.value, 65);

    // Spend 10 AC on Unit 15-Q Assessment Entry (65 -> 55 AC)
    await tester.tap(find.text('10 AC'));
    await tester.pumpAndSettle();

    expect(find.text('55 AC'), findsOneWidget);
    expect(EconomyService.instance.coinBalanceNotifier.value, 55);

    // Let AcedexToast auto-dismiss timer complete cleanly before test teardown
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('AcedexUnlockChoiceSheet allows unlocking assessment for 10 AC',
      (tester) async {
    final fakeEconomy = _FakeEconomyRepo();
    bool? unlocked;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                unlocked = await AcedexUnlockChoiceSheet.show(
                  context,
                  title: 'Start U1 Assessment',
                  subtitle: 'Spend 10 AC or watch 1 ad.',
                  itemKey: 'unit_assessment',
                  coinCost: 10,
                  economyRepository: fakeEconomy,
                );
              },
              child: const Text('Unlock'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Your Balance: 25 AC'), findsOneWidget);
    await tester.tap(find.text('Unlock with 10 AC'));
    await tester.pumpAndSettle();

    expect(unlocked, isTrue);
    expect(EconomyService.instance.coinBalanceNotifier.value, 15);
  });
}
