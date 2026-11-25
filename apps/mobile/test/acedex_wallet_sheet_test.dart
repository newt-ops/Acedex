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
    balance: 15,
    lifetimeEarned: 25,
    lifetimeSpent: 10,
    dailyCoinAdsRemaining: 1,
    dailyCoinAdsLimit: 5,
    coinsPerAd: 10,
    assessmentCost: 10,
    recentTransactions: [
      CoinTransactionItem(
        id: 'tx2',
        type: 'spend',
        amount: -10,
        balanceAfter: 15,
        reason: 'Unit Assessment Entry (PHY-G09-U01)',
        itemKey: 'unit_assessment',
        createdAt: '2026-11-25T05:10:00.000Z',
      ),
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
      coinsPerAd: overview.coinsPerAd,
      recentTransactions: [
        CoinTransactionItem(
          id: 'tx_spend_${DateTime.now().millisecondsSinceEpoch}',
          type: 'spend',
          amount: -10,
          balanceAfter: nextBal,
          reason: 'Unit Assessment Entry (${targetUnitId ?? 'UNIT'})',
          itemKey: itemKey,
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
        ...overview.recentTransactions,
      ],
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
      placementId: 'Reward_Android_Acedex',
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
    final newBal = economyRepo.overview.balance + 10;
    final remaining = (economyRepo.overview.dailyCoinAdsRemaining - 1).clamp(0, 5);
    economyRepo.overview = WalletOverview(
      balance: newBal,
      lifetimeEarned: economyRepo.overview.lifetimeEarned + 10,
      lifetimeSpent: economyRepo.overview.lifetimeSpent,
      dailyCoinAdsRemaining: remaining,
      coinsPerAd: 10,
      recentTransactions: [
        CoinTransactionItem(
          id: 'tx_ad_1',
          type: 'earn_ad',
          amount: 10,
          balanceAfter: newBal,
          reason: 'Watched Rewarded Ad (+10 AC)',
          createdAt: DateTime.now().toUtc().toIso8601String(),
        ),
        ...economyRepo.overview.recentTransactions,
      ],
    );
    return AcedexClaimRewardResult(
      rewardType: rewardType,
      adSessionId: adSessionId,
      coinsAwarded: 10,
      newCoinBalance: newBal,
      dailyCoinAdsRemaining: remaining,
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

  testWidgets(
      'AcedexWalletSheet shows bank-style earn & spend ledger, awards +10 AC per ad, and disables at daily limit',
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

    // Balance & clean statement structure (removed sections & labels stay absent)
    expect(find.text('15 AC'), findsOneWidget);
    expect(find.text('HOW TO EARN ACE COINS'), findsNothing);
    expect(find.text('SPEND ACE COINS'), findsNothing);
    expect(find.textContaining('Unit Assessment:'), findsNothing);
    expect(find.textContaining('left'), findsNothing);

    // Bank-style statement shows BOTH earn & spend rows with running balances
    expect(find.text('TRANSACTION LOGS'), findsOneWidget);
    expect(find.text('Unit Assessment Entry (PHY-G09-U01)'), findsOneWidget);
    expect(find.text('-10 AC'), findsOneWidget);
    expect(find.text('Bal: 15 AC'), findsOneWidget);
    expect(find.text('Welcome Bonus — First Study Steps'), findsOneWidget);
    expect(find.text('+25 AC'), findsOneWidget);
    expect(find.text('Bal: 25 AC'), findsOneWidget);

    // Filter tabs toggle between Spend, Earn, and All cleanly
    await tester.tap(find.text('Spend'));
    await tester.pumpAndSettle();
    expect(find.text('Unit Assessment Entry (PHY-G09-U01)'), findsOneWidget);
    expect(find.text('Welcome Bonus — First Study Steps'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Watch final daily Rewarded Ad -> +10 AC (15 -> 25 AC), button becomes disabled
    expect(find.text('Watch 1 Ad (+10 AC)'), findsOneWidget);
    await tester.tap(find.text('Watch 1 Ad (+10 AC)'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('25 AC'), findsOneWidget);
    expect(EconomyService.instance.coinBalanceNotifier.value, 25);
    expect(find.text('Watched Rewarded Ad (+10 AC)'), findsOneWidget);
    expect(find.text('+10 AC'), findsOneWidget);

    // Daily limit reached (remaining = 0): button still has no "left" text and is disabled
    expect(find.text('Watch 1 Ad (+10 AC)'), findsOneWidget);
    final adButton = tester.widget<AcedexButton>(find.byType(AcedexButton));
    expect(adButton.onPressed, isNull);

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

    fakeEconomy.overview = WalletOverview(
      balance: 25,
      lifetimeEarned: 25,
      lifetimeSpent: 0,
      coinsPerAd: 10,
      assessmentCost: 10,
      recentTransactions: fakeEconomy.overview.recentTransactions,
    );

    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Your Balance: 25 AC'), findsOneWidget);
    await tester.tap(find.text('Unlock with 10 AC'));
    await tester.pumpAndSettle();

    expect(unlocked, isTrue);
    expect(EconomyService.instance.coinBalanceNotifier.value, 15);
    expect(find.textContaining('-10 AC'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
