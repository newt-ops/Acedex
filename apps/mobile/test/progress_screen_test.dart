import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/storage/auth_storage.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/features/progress/models/progress_models.dart';
import 'package:acedex/features/progress/screens/progress_screen.dart';
import 'package:acedex/features/progress/services/progress_analytics_service.dart';

class _FakeProgressAnalyticsRepository implements ProgressAnalyticsRepository {
  final ProgressAnalyticsData data;

  _FakeProgressAnalyticsRepository(this.data);

  @override
  Future<ProgressAnalyticsData> fetchAnalytics() async => data;

  @override
  Future<ProgressAnalyticsData?> getCachedAnalytics() async => data;

  @override
  Future<void> saveCachedAnalytics(ProgressAnalyticsData data) async {}
}

ProgressAnalyticsData _buildSampleLiveAnalytics() {
  final baseline = ProgressAnalyticsData.emptyBaseline(
    stream: 'natural',
    dailyGoalMinutes: 90,
    completedUnitsCount: 14,
    totalUnitsFallback: 200,
    todayCompletedMinutes: 75,
  );

  TimeframeData makeTf({
    required int readinessPct,
    required int projectedScore,
    required String percentile,
    required String delta,
    required int accuracyPct,
    required int consistencyPct,
    required int assessmentsCount,
    required int activeDays,
    required int windowDays,
    required String footerHours,
    required String footerAcc,
    required String footerQs,
    required List<TimeframePoint> pts,
  }) {
    return TimeframeData(
      readinessPct: readinessPct,
      projectedScore: projectedScore,
      percentile: percentile,
      delta: delta,
      subcopy: 'Keep completing daily focus blocks & assessments to raise readiness.',
      coveragePct: 7,
      accuracyPct: accuracyPct,
      consistencyPct: consistencyPct,
      completedUnits: 14,
      totalUnits: 200,
      assessmentsCount: assessmentsCount,
      dailyGoalMinutes: 90,
      activeDays: activeDays,
      windowDays: windowDays,
      footerHours: footerHours,
      footerAcc: footerAcc,
      footerQs: footerQs,
      points: pts,
    );
  }

  return ProgressAnalyticsData(
    stream: 'natural',
    dailyGoalMinutes: 90,
    currentStreak: 4,
    longestStreak: 9,
    timeframes: {
      ProgressTimeframe.sevenDays: makeTf(
        readinessPct: 54,
        projectedScore: 422,
        percentile: 'Top 12%',
        delta: '+3.5%',
        accuracyPct: 82,
        consistencyPct: 57,
        assessmentsCount: 3,
        activeDays: 4,
        windowDays: 7,
        footerHours: '5.5 hrs',
        footerAcc: '82.0%',
        footerQs: '45 Qs',
        pts: baseline.timeframes[ProgressTimeframe.sevenDays]!.points,
      ),
      ProgressTimeframe.thirtyDays: makeTf(
        readinessPct: 62,
        projectedScore: 438,
        percentile: 'Top 12%',
        delta: '+5.0%',
        accuracyPct: 84,
        consistencyPct: 70,
        assessmentsCount: 8,
        activeDays: 21,
        windowDays: 30,
        footerHours: '24.0 hrs',
        footerAcc: '84.0%',
        footerQs: '120 Qs',
        pts: baseline.timeframes[ProgressTimeframe.thirtyDays]!.points,
      ),
      ProgressTimeframe.allTerm: makeTf(
        readinessPct: 58,
        projectedScore: 410,
        percentile: 'Top 12%',
        delta: '+8.2%',
        accuracyPct: 80,
        consistencyPct: 65,
        assessmentsCount: 15,
        activeDays: 32,
        windowDays: 50,
        footerHours: '52.0 hrs',
        footerAcc: '80.0%',
        footerQs: '240 Qs',
        pts: baseline.timeframes[ProgressTimeframe.allTerm]!.points,
      ),
    },
    heatmapDays: baseline.heatmapDays,
    simulatorSubjects: const [
      SimulatorSubjectScore(id: 'math', code: 'MAT', name: 'Mathematics', score: 74),
      SimulatorSubjectScore(id: 'physics', code: 'PHY', name: 'Physics', score: 70),
      SimulatorSubjectScore(id: 'biology', code: 'BIO', name: 'Biology', score: 68),
      SimulatorSubjectScore(id: 'chemistry', code: 'CHE', name: 'Chemistry', score: 66),
      SimulatorSubjectScore(id: 'english', code: 'ENG', name: 'English', score: 72),
      SimulatorSubjectScore(id: 'sat', code: 'SAT', name: 'SAT', score: 72),
    ],
  );
}

void main() {
  const dummyUser = UserProfile(
    id: 'usr_test_1',
    acedexId: 'ACX-2026-88912',
    displayName: 'Abebe Bikila',
    phone: '+251912345678',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AuthStorage.instance.completedUnitsNotifier.value = {};
    AuthStorage.instance.dailyFocusGoalMinutesNotifier.value = 0;
    AuthStorage.instance.dailyFocusCompletedMinutesNotifier.value = 0;
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    ProgressAnalyticsRepository? repo,
  }) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: ProgressScreen(
            user: dummyUser,
            analyticsRepository: repo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('fresh user starts at zero baseline without gradeBadgeText, reload button, or Subject Mastery', (tester) async {
    await pumpScreen(tester);

    // 1. Header has no grade badge and no reload button
    expect(find.text('PERFORMANCE & ANALYTICS'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('G12 • Natural Science'), findsNothing);

    // 2. Zero baseline values (no hardcoded mock metrics)
    expect(find.text('Est. 0 / 600 • Baseline'), findsOneWidget);
    expect(find.text('0.0 hrs'), findsOneWidget);
    expect(find.text('0.0%'), findsOneWidget);
    expect(find.text('0 Qs'), findsNWidgets(2));
    expect(find.text('0d Streak'), findsOneWidget);
    expect(find.text('Best 0d'), findsOneWidget);

    // 3. Subject Mastery section completely removed
    expect(find.text('Subject Mastery'), findsNothing);
    expect(find.text('Tap card to boost'), findsNothing);
  });

  testWidgets('renders live analytics data and switches timeframes cleanly', (tester) async {
    final repo = _FakeProgressAnalyticsRepository(_buildSampleLiveAnalytics());
    await pumpScreen(tester, repo: repo);

    // 7 Days live values
    expect(find.text('Est. 422 / 600 • Top 12%'), findsOneWidget);
    expect(find.text('+3.5%'), findsOneWidget);
    expect(find.text('5.5 hrs'), findsOneWidget);
    expect(find.text('82.0%'), findsOneWidget);
    expect(find.text('45 Qs'), findsOneWidget);
    expect(find.text('4d Streak'), findsOneWidget);
    expect(find.text('Best 9d'), findsOneWidget);

    // Tap 30 Days
    await tester.tap(find.text('30 Days'));
    await tester.pumpAndSettle();

    expect(find.text('24.0 hrs'), findsOneWidget);
    expect(find.text('Est. 438 / 600 • Top 12%'), findsOneWidget);
    expect(find.text('+5.0%'), findsOneWidget);

    // Tap All Term
    await tester.tap(find.text('All Term'));
    await tester.pumpAndSettle();

    expect(find.text('52.0 hrs'), findsOneWidget);
    expect(find.text('Est. 410 / 600 • Top 12%'), findsOneWidget);
    expect(find.text('+8.2%'), findsOneWidget);
  });

  testWidgets('tapping pillars displays real user counts & goal explanations', (tester) async {
    final repo = _FakeProgressAnalyticsRepository(_buildSampleLiveAnalytics());
    await pumpScreen(tester, repo: repo);

    expect(
      find.textContaining('14 of 200 stream units completed'),
      findsOneWidget,
    );

    await tester.tap(find.text('Mock Accuracy'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('3 completed assessments in this window'),
      findsOneWidget,
    );

    await tester.tap(find.text('Consistency'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Active 4 of 7 days tracking toward your 90m daily study goal'),
      findsOneWidget,
    );
  });

  testWidgets('chart metric toggle displays dynamic daily goal label', (tester) async {
    final repo = _FakeProgressAnalyticsRepository(_buildSampleLiveAnalytics());
    await pumpScreen(tester, repo: repo);

    expect(find.text('Dashed line: 1.5h daily target'), findsOneWidget);

    await tester.tap(find.text('Quiz Accuracy'));
    await tester.pumpAndSettle();

    expect(find.text('Dashed line: 80% EUEE accuracy goal'), findsOneWidget);
  });

  testWidgets('What-If score simulator includes all 6 subjects including English and SAT', (tester) async {
    final repo = _FakeProgressAnalyticsRepository(_buildSampleLiveAnalytics());
    await pumpScreen(tester, repo: repo);

    await tester.tap(find.text('Simulate EUEE Score'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('What-If Score Simulator'), findsOneWidget);
    expect(find.text('PROJECTED TOTAL SCORE'), findsOneWidget);
    expect(find.text('English + Aptitude Baseline'), findsNothing);

    // All 6 sliders present including English & SAT
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Biology'), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('SAT'), findsOneWidget);
    expect(find.text('422'), findsOneWidget);

    await tester.tap(find.text('Apply Target'));
    await tester.pumpAndSettle();

    expect(find.text('What-If Score Simulator'), findsNothing);
    expect(find.text('Est. 422 / 600 • Top 12%'), findsOneWidget);
  });
}
