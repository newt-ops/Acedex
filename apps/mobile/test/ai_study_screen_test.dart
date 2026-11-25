import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/ads/ads.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/core/ui/ui.dart';
import 'package:acedex/features/ai_study/models/ai_study_models.dart';
import 'package:acedex/features/ai_study/screens/ai_calibration_screen.dart';
import 'package:acedex/features/ai_study/screens/ai_study_screen.dart';
import 'package:acedex/features/ai_study/services/ai_study_service.dart';
import 'package:acedex/features/ai_study/widgets/ai_module_detail_sheet.dart';
import 'package:acedex/features/ai_study/widgets/ai_topic_workspace_view.dart';
import 'package:acedex/features/ai_study/widgets/ai_welcome_view.dart';

class _FakeAdsRepo implements AcedexAdsRepository {
  bool adStarted = false;
  bool adPlayed = false;
  bool adClaimed = false;

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
    adStarted = true;
    return AcedexAdSession(
      adSessionId: 'adsess_test_unlocked',
      rewardType: rewardType,
      gameId: '6220248',
      placementId: 'Rewarded_Android',
      startedAtLocal: DateTime.now(),
    );
  }

  @override
  Future<bool> showUnityRewardedAd(AcedexAdSession session) async {
    adPlayed = true;
    return true;
  }

  @override
  Future<AcedexClaimRewardResult> claimReward({
    required String adSessionId,
    required AcedexRewardType rewardType,
  }) async {
    adClaimed = adSessionId == 'adsess_test_unlocked';
    return AcedexClaimRewardResult(
      rewardType: rewardType,
      adSessionId: adSessionId,
      aiStudyPlanUnlocked: true,
      aiPlanAdSessionId: adSessionId,
    );
  }
}

class _FakeAiStudyRepository implements AiStudyRepository {
  int generateCalls = 0;

  AiTopicProgramOverview overview = const AiTopicProgramOverview(
    hasProgram: false,
    canGenerateToday: true,
    requiresAd: true,
    subjectSummaries: [
      AiTopicSubjectSummary(
        subjectCode: 'PHY',
        subjectName: 'Physics',
        totalModules: 10,
        completedModules: 0,
        masteryPercentage: 0,
        hasTopicBank: true,
      ),
      AiTopicSubjectSummary(
        subjectCode: 'MAT',
        subjectName: 'Mathematics',
        totalModules: 10,
        completedModules: 0,
        masteryPercentage: 0,
        hasTopicBank: true,
      ),
    ],
  );

  List<TopicModuleItem> phyModules = [
    const TopicModuleItem(
      moduleId: 'PHY-M01',
      subjectCode: 'PHY',
      subjectName: 'Physics',
      streamCategory: 'natural',
      moduleNumber: 1,
      phase: 'Phase I: Foundational Core',
      title: 'Measurement Standards, Precision & Vector Analysis',
      rationale:
          'Connects Grade 9 SI measurement foundations directly to Grade 11 3D vector decomposition.',
      references: [
        TopicReadingReference(
          grade: 9,
          unitNumber: 1,
          unitCode: 'PHY-G09-U01',
          unitTitle: 'Physics and Human Society',
          pages: 'pp. 1–10',
          hasQuickNotes: true,
        ),
        TopicReadingReference(
          grade: 11,
          unitNumber: 2,
          unitCode: 'PHY-G11-U02',
          unitTitle: 'Vectors',
          pages: 'pp. 17–46',
          hasQuickNotes: false,
        ),
      ],
      sequence: [
        TopicLearningStep(
          stepNumber: 1,
          text: 'Review SI base and derived units with dimensional checks.',
          grade: 9,
          unitNumber: 1,
          unitCode: 'PHY-G09-U01',
          pages: 'pp. 1–10',
        ),
        TopicLearningStep(
          stepNumber: 2,
          text: 'Resolve 2D vectors into rectangular Fx and Fy components.',
          grade: 11,
          unitNumber: 2,
          unitCode: 'PHY-G11-U02',
          pages: 'pp. 17–46',
        ),
      ],
      prerequisites: ['Basic trigonometry'],
      masteryCheckpoint: 'Compute vector resultant magnitude and angle.',
      completedSteps: [],
      isCompleted: false,
      progressPercentage: 0,
    ),
  ];

  @override
  Future<AiTopicProgramOverview?> getCachedOverview() async => null;

  @override
  Future<List<TopicModuleItem>?> getCachedSubjectModules(String subjectCode) async => null;

  @override
  Future<AiTopicProgramOverview> fetchProgramOverview() async => overview;

  @override
  Future<List<TopicModuleItem>> fetchSubjectModules(String subjectCode) async {
    if (subjectCode.toUpperCase() == 'PHY') return phyModules;
    return const [];
  }

  @override
  Future<AiTopicProgramOverview> generateProgram(
    AiCalibrationInput input, {
    String? adSessionId,
  }) async {
    generateCalls++;
    overview = AiTopicProgramOverview(
      hasProgram: true,
      canGenerateToday: false,
      requiresAd: true,
      program: AiStudyProgram(
        calibration: input,
        stream: 'natural',
        projectedScore: (input.targetScore + 10).clamp(400, 600),
        diagnosticSummary:
            'Prioritizing Physics and Mathematics with 90m Morning cross-grade blocks.',
        subjectAllocations: const [
          AiSubjectAllocation(
            subjectCode: 'PHY',
            subjectName: 'Physics',
            priorityRank: 1,
            weeklyMinutes: 240,
            sharePercentage: 40,
          ),
          AiSubjectAllocation(
            subjectCode: 'MAT',
            subjectName: 'Mathematics',
            priorityRank: 2,
            weeklyMinutes: 180,
            sharePercentage: 30,
          ),
        ],
        dailyFocusTasks: const [
          AiDailyTaskItem(
            id: 'task-1',
            moduleId: 'PHY-M01',
            subjectCode: 'PHY',
            subjectName: 'Physics',
            title: 'Measurement Standards, Precision & Vector Analysis',
            durationMinutes: 30,
            priorityTag: 'Priority #1',
            whereToRead: 'G9 U1 (pp. 1–10) • G11 U2 (pp. 17–46)',
          ),
        ],
        modulePriorityBySubject: const {
          'PHY': ['PHY-M01'],
        },
        generatedBy: 'gemini',
        generatedAt: '2026-11-24T20:30:00.000Z',
      ),
      subjectSummaries: const [
        AiTopicSubjectSummary(
          subjectCode: 'PHY',
          subjectName: 'Physics',
          totalModules: 10,
          completedModules: 0,
          masteryPercentage: 0,
          priorityRank: 1,
          hasTopicBank: true,
        ),
        AiTopicSubjectSummary(
          subjectCode: 'MAT',
          subjectName: 'Mathematics',
          totalModules: 10,
          completedModules: 0,
          masteryPercentage: 0,
          priorityRank: 2,
          hasTopicBank: true,
        ),
      ],
    );
    return overview;
  }

  @override
  Future<TopicModuleItem> updateModuleProgress({
    required String moduleId,
    int? stepNumber,
    bool? stepCompleted,
    bool? isCompleted,
  }) async {
    final target = phyModules.first;
    final steps = List<int>.from(target.completedSteps);
    if (stepNumber != null) {
      if (stepCompleted == true && !steps.contains(stepNumber)) {
        steps.add(stepNumber);
      } else if (stepCompleted == false) {
        steps.remove(stepNumber);
      }
    }
    final completed = isCompleted ?? (steps.length == target.sequence.length);
    final pct = completed
        ? 100
        : ((steps.length / target.sequence.length) * 100).round();

    final updated = target.copyWith(
      completedSteps: completed ? [1, 2] : steps,
      isCompleted: completed,
      progressPercentage: pct,
    );
    phyModules = [updated];
    return updated;
  }
}

void main() {
  const naturalUser = UserProfile(
    id: 'usr_nat_01',
    acedexId: 'ACEDEX-NAT-01',
    displayName: 'Abebe Kebede',
    grade: 12,
    stream: 'natural',
    role: 'student',
    status: 'active',
  );

  const socialUser = UserProfile(
    id: 'usr_soc_01',
    acedexId: 'ACEDEX-SOC-01',
    displayName: 'Sara Tesfaye',
    grade: 11,
    stream: 'social',
    role: 'student',
    status: 'active',
  );

  testWidgets(
      'AiStudyScreen renders Phase 0 Welcome and runs locked-stream 4-step calibration + rewarded ad',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final fakeRepo = _FakeAiStudyRepository();
    final fakeAds = _FakeAdsRepo();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AcedexHeaderBar(user: naturalUser),
          bottomNavigationBar: AcedexBottomNavBar(
            currentIndex: 2,
            onTap: (_) {},
          ),
          body: AiStudyScreen(
            user: naturalUser,
            repository: fakeRepo,
            adsRepository: fakeAds,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Phase 0: Welcome screen inside shell shows header & bottom nav
    expect(find.byType(AcedexHeaderBar), findsOneWidget);
    expect(find.byType(AcedexBottomNavBar), findsOneWidget);
    expect(find.byType(AiWelcomeView), findsOneWidget);
    expect(
      find.text('Master Ethiopian Subjects by Connected Topics'),
      findsOneWidget,
    );
    expect(find.text('Grade 12 • Natural Science'), findsOneWidget);
    expect(
      find.text('Generates once per day • Unlocks with 1 rewarded ad'),
      findsOneWidget,
    );

    // Enter full-screen Calibration route -> header & footer MUST disappear
    await tester.ensureVisible(find.text('Generate Study Program'));
    await tester.tap(find.text('Generate Study Program'));
    await tester.pumpAndSettle();

    expect(find.byType(AiCalibrationScreen), findsOneWidget);
    expect(find.byType(AcedexHeaderBar), findsNothing);
    expect(find.byType(AcedexBottomNavBar), findsNothing);

    expect(find.text('STEP 1 OF 4 • GOAL CALIBRATION'), findsOneWidget);
    expect(find.text('Registered Academic Track'), findsOneWidget);
    expect(find.text('Grade 12 • Natural Science'), findsOneWidget);
    // Stream toggle must NOT exist
    expect(find.text('Social Science'), findsNothing);

    // Continue -> Step 2 (Priority Subjects)
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 2 OF 4 • DIAGNOSTIC FOCUS'), findsOneWidget);
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('History'), findsNothing);

    // Continue -> Step 3 (Daily Commitment)
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 3 OF 4 • TIME ARCHITECTURE'), findsOneWidget);
    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Afternoon'), findsOneWidget);
    expect(find.text('Night'), findsOneWidget);

    // Continue -> Step 4 (Prep Stage & Rewarded Ad button)
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 4 OF 4 • BASELINE CHECK'), findsOneWidget);
    expect(find.text('Watch 1 Ad & Generate Plan'), findsOneWidget);

    // Tap CTA -> Rewarded Ad Sheet countdown -> start/play/claim -> Gemini synthesis -> Blueprint
    await tester.ensureVisible(find.text('Watch 1 Ad & Generate Plan'));
    await tester.tap(find.text('Watch 1 Ad & Generate Plan'));
    await tester.pump();

    // Advance past 1s minimum test timer + synthesis timer
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(fakeAds.adStarted, isTrue);
    expect(fakeAds.adPlayed, isTrue);
    expect(fakeAds.adClaimed, isTrue);
    expect(fakeRepo.generateCalls, 1);
    expect(find.text('GEMINI AI BLUEPRINT'), findsOneWidget);
    expect(find.text('Start Topic Study Program'), findsOneWidget);

    // Finish onboarding -> returns from full-screen route to Workspace with nav bar
    await tester.ensureVisible(find.text('Start Topic Study Program'));
    await tester.tap(find.text('Start Topic Study Program'));
    await tester.pumpAndSettle();

    expect(find.byType(AiTopicWorkspaceView), findsOneWidget);
    expect(find.byType(AcedexBottomNavBar), findsOneWidget);
    expect(find.text('Physics Cross-Grade Map'), findsOneWidget);
    expect(find.text('0/10 modules mastered (0%)'), findsOneWidget);
    expect(
      find.text('Measurement Standards, Precision & Vector Analysis'),
      findsOneWidget,
    );
    expect(find.text('G9 U1 • pp. 1–10'), findsOneWidget);
  });

  testWidgets(
      'Social Science student sees Social Science subjects strictly locked in calibration',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final fakeRepo = _FakeAiStudyRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AiStudyScreen(
            user: socialUser,
            repository: fakeRepo,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Generate Study Program'));
    await tester.tap(find.text('Generate Study Program'));
    await tester.pumpAndSettle();

    expect(find.text('Grade 11 • Social Science'), findsOneWidget);
    expect(find.text('Natural Science'), findsNothing);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Geography'), findsOneWidget);
    expect(find.text('Economics'), findsOneWidget);
    expect(find.text('Physics'), findsNothing);
  });

  testWidgets(
      'AiTopicWorkspaceView opens AiModuleDetailSheet and persists 0% -> 50% -> 100% progress',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final fakeRepo = _FakeAiStudyRepository();
    final seededOverview = await fakeRepo.generateProgram(
      const AiCalibrationInput(
        tierId: 'competitive',
        targetScore: 495,
        weakSubjectCodes: ['PHY', 'MAT'],
        dailyMinutes: 90,
        peakWindow: 'Morning',
        prepStageId: 'reviewing',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AiStudyScreen(
            user: naturalUser,
            repository: fakeRepo,
            initialOverview: seededOverview,
            initialModulesBySubject: {'PHY': fakeRepo.phyModules},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Module 1 card to open Detail Sheet
    await tester.tap(
      find.text('Measurement Standards, Precision & Vector Analysis'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AiModuleDetailSheet), findsOneWidget);
    expect(find.text('0% Mastered'), findsOneWidget);
    expect(find.text('Quick Notes'), findsOneWidget);
    expect(find.text('Unit 1: Physics and Human Society'), findsOneWidget);

    // Check first learning step -> 50%
    await tester.tap(
      find.text('Review SI base and derived units with dimensional checks.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('50% Mastered'), findsOneWidget);
    expect(find.text('1/2 done'), findsOneWidget);

    // Mark Module Mastered -> 100%
    await tester.ensureVisible(find.text('Mark Module Mastered'));
    await tester.tap(find.text('Mark Module Mastered'));
    await tester.pumpAndSettle();
    expect(find.text('100% Mastered'), findsOneWidget);
    expect(find.text('Module Mastered • Tap to Reopen'), findsOneWidget);
  });
}
