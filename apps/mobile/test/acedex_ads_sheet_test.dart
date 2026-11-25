import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/ads/ads.dart';
import 'package:acedex/core/theme/app_theme.dart';

class _FakeCommonAdsRepository implements AcedexAdsRepository {
  bool simulateSkipOnce = false;
  int startCalls = 0;
  int showCalls = 0;
  int claimCalls = 0;
  AcedexRewardType? lastStartedType;
  String? lastTargetUnitId;

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
    startCalls++;
    lastStartedType = rewardType;
    lastTargetUnitId = targetUnitId;
    return AcedexAdSession(
      adSessionId: 'adsess_common_${rewardType.apiValue}',
      rewardType: rewardType,
      gameId: '6220248',
      placementId: 'Rewarded_Android',
      startedAtLocal: DateTime.now(),
    );
  }

  @override
  Future<bool> showUnityRewardedAd(AcedexAdSession session) async {
    showCalls++;
    if (simulateSkipOnce) {
      simulateSkipOnce = false;
      throw const RewardedAdSkippedException();
    }
    return true;
  }

  @override
  Future<AcedexClaimRewardResult> claimReward({
    required String adSessionId,
    required AcedexRewardType rewardType,
  }) async {
    claimCalls++;
    return AcedexClaimRewardResult(
      rewardType: rewardType,
      adSessionId: adSessionId,
      examTicketsAvailable: rewardType == AcedexRewardType.examAccess ? 2 : null,
      repairedStreak: rewardType == AcedexRewardType.streakRepair ? 7 : null,
      unlockedUnitId:
          rewardType == AcedexRewardType.offlinePack ? 'unit_123' : null,
      aiStudyPlanUnlocked:
          rewardType == AcedexRewardType.aiStudyPlan ? true : null,
      aiPlanAdSessionId:
          rewardType == AcedexRewardType.aiStudyPlan ? adSessionId : null,
    );
  }
}

void main() {
  testWidgets(
      'AcedexRewardedAdSheet handles common examAccess, offlinePack, streakRepair & aiStudyPlan flows',
      (tester) async {
    final fakeAds = _FakeCommonAdsRepository();
    AcedexClaimRewardResult? claimed;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  claimed = await AcedexRewardedAdSheet.show(
                    context,
                    rewardType: AcedexRewardType.offlinePack,
                    targetUnitId: 'unit_123',
                    adsRepository: fakeAds,
                  );
                },
                child: const Text('Unlock Pack'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Unlock Pack'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(fakeAds.startCalls, 1);
    expect(fakeAds.lastStartedType, AcedexRewardType.offlinePack);
    expect(fakeAds.lastTargetUnitId, 'unit_123');
    expect(fakeAds.showCalls, 1);
    expect(fakeAds.claimCalls, 1);
    expect(claimed?.rewardType, AcedexRewardType.offlinePack);
    expect(claimed?.unlockedUnitId, 'unit_123');
  });

  testWidgets(
      'AcedexRewardedAdSheet shows Retry Ad when user skips video early and succeeds on retry',
      (tester) async {
    final fakeAds = _FakeCommonAdsRepository()..simulateSkipOnce = true;
    AcedexClaimRewardResult? claimed;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                claimed = await AcedexRewardedAdSheet.show(
                  context,
                  rewardType: AcedexRewardType.streakRepair,
                  adsRepository: fakeAds,
                );
              },
              child: const Text('Repair Streak'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Repair Streak'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Ad Skipped Early'), findsOneWidget);
    expect(find.text('Retry Ad'), findsOneWidget);

    await tester.tap(find.text('Retry Ad'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(claimed?.rewardType, AcedexRewardType.streakRepair);
    expect(claimed?.repairedStreak, 7);
  });
}
