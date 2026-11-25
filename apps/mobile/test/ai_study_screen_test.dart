import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/ads/ads.dart';
import 'package:acedex/core/models/user_profile.dart';
import 'package:acedex/core/network/api_client.dart';
import 'package:acedex/core/storage/auth_storage.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/core/ui/ui.dart';
import 'package:acedex/features/ai_study/models/ai_study_models.dart';
import 'package:acedex/features/ai_study/screens/ai_calibration_screen.dart';
import 'package:acedex/features/ai_study/screens/ai_study_screen.dart';
import 'package:acedex/features/ai_study/services/ai_study_service.dart';
import 'package:acedex/features/ai_study/widgets/ai_module_detail_sheet.dart';
import 'package:acedex/features/ai_study/widgets/ai_topic_workspace_view.dart';
import 'package:acedex/features/ai_study/widgets/ai_welcome_view.dart';
import 'package:acedex/features/study/models/study_models.dart';
import 'package:acedex/features/study/screens/study_screen.dart';

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
      placementId: 'Reward_Android_Acedex',
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
  bool failMatFetch = false;
  Duration unitMasteryDelay = Duration.zero;

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

  List<TopicModuleItem> matModules = [
    const TopicModuleItem(
      moduleId: 'MAT-M01',
      subjectCode: 'MAT',
      subjectName: 'Mathematics',
      streamCategory: 'common',
      moduleNumber: 1,
      phase: 'Phase I: Foundational Algebra',
      title: 'Number Systems, Sets & Logic Foundations',
      rationale:
          'Connects Grade 9 set operations directly to Grade 11 logical proofs.',
      references: [
        TopicReadingReference(
          grade: 9,
          unitNumber: 1,
          unitCode: 'MAT-G09-U01',
          unitTitle: 'Further on Sets',
          pages: 'pp. 1–26',
          hasQuickNotes: false,
        ),
      ],
      sequence: [
        TopicLearningStep(
          stepNumber: 1,
          text: 'Review Venn diagrams, De Morgan laws, and symmetric difference.',
          grade: 9,
          unitNumber: 1,
          unitCode: 'MAT-G09-U01',
          pages: 'pp. 1–26',
        ),
      ],
      prerequisites: ['Basic arithmetic'],
      masteryCheckpoint: 'Solve multi-set cardinality problems accurately.',
      completedSteps: [],
      isCompleted: false,
      progressPercentage: 0,
    ),
  ];

  @override
  Future<AiTopicProgramOverview?> getCachedOverview() async => null;

  @override
  Future<void> saveCachedOverview(AiTopicProgramOverview overview) async {
    this.overview = overview;
  }

  @override
  Future<List<TopicModuleItem>?> getCachedSubjectModules(String subjectCode) async => null;

  @override
  Future<void> saveCachedSubjectModules(
    String subjectCode,
    List<TopicModuleItem> modules,
  ) async {}

  @override
  Future<AiTopicProgramOverview> fetchProgramOverview() async => overview;

  @override
  Future<List<TopicModuleItem>> fetchSubjectModules(String subjectCode) async {
    final code = subjectCode.toUpperCase();
    if (code == 'PHY') return phyModules;
    if (code == 'MAT') {
      if (failMatFetch) {
        throw Exception('Network timeout');
      }
      return matModules;
    }
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
    TopicModuleItem? existingModule,
    int? stepNumber,
    bool? stepCompleted,
    bool? isCompleted,
  }) async {
    final target = existingModule ?? phyModules.first;
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

  @override
  Future<TopicUnitMasteryResult> toggleUnitMastery({
    required String unitCode,
    required bool completed,
    String? moduleId,
  }) async {
    if (unitMasteryDelay > Duration.zero) {
      await Future<void>.delayed(unitMasteryDelay);
    }
    final code = unitCode.toUpperCase().trim();
    final target = phyModules.first;
    final updatedRefs = target.references
        .map(
          (r) => r.unitCode.toUpperCase().trim() == code
              ? r.copyWith(isUnitCompleted: completed)
              : r,
        )
        .toList();

    final matchingSteps = target.sequence
        .where((s) => (s.unitCode ?? '').toUpperCase().trim() == code)
        .map((s) => s.stepNumber)
        .toList();
    final stepSet = Set<int>.from(target.completedSteps);
    for (final s in matchingSteps) {
      if (completed) {
        stepSet.add(s);
      } else {
        stepSet.remove(s);
      }
    }
    final nextSteps = stepSet.toList()..sort();
    final allDone =
        target.sequence.isNotEmpty && nextSteps.length >= target.sequence.length;
    final nextPct = target.sequence.isEmpty
        ? 0
        : ((nextSteps.length / target.sequence.length) * 100).round();

    phyModules = [
      target.copyWith(
        references: updatedRefs,
        completedSteps: nextSteps,
        isCompleted: allDone,
        progressPercentage: nextPct,
      ),
    ];

    return TopicUnitMasteryResult(
      unitCode: code,
      isStudyCompleted: completed,
      syncedStepNumbers: matchingSteps,
      updatedCompletedSteps: nextSteps,
      updatedModuleCompleted: allDone,
      updatedProgressPercentage: nextPct,
    );
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
    tester.view.physicalSize = const Size(480, 915);
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
    expect(find.text('ACEDEX AI BLUEPRINT'), findsOneWidget);
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
    tester.view.physicalSize = const Size(480, 915);
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
    tester.view.physicalSize = const Size(480, 915);
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

  testWidgets(
      'Switching subject rail serves subject topics cleanly and supports Retry on error',
      (tester) async {
    tester.view.physicalSize = const Size(480, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final fakeRepo = _FakeAiStudyRepository()..failMatFetch = true;
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

    // Recommended Physics module displays AI Focus badge
    expect(find.text('AI Focus'), findsOneWidget);

    // Switch to Mathematics while fetch fails -> shows Retry CTA
    await tester.tap(find.text('Mathematics'));
    await tester.pumpAndSettle();

    expect(find.text('Mathematics Cross-Grade Map'), findsOneWidget);
    expect(find.text('Retry Loading Topics'), findsOneWidget);

    // Recover and retry -> serves Mathematics modules
    fakeRepo.failMatFetch = false;
    await tester.tap(find.text('Retry Loading Topics'));
    await tester.pumpAndSettle();

    expect(find.text('Number Systems, Sets & Logic Foundations'), findsOneWidget);
    expect(find.text('G9 U1 • pp. 1–26'), findsOneWidget);
  });

  test(
      'AiStudyService unwraps list data from backend and preserves module metadata on progress update',
      () async {
    SharedPreferences.setMockInitialValues({});

    final mockHttp = MockClient((request) async {
      if (request.url.path == '/api/v1/topics/subjects/MAT/modules') {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'moduleId': 'MAT-M01',
                  'subjectCode': 'MAT',
                  'subjectName': 'Mathematics',
                  'streamCategory': 'common',
                  'moduleNumber': 1,
                  'phase': 'Phase I: Foundational Algebra',
                  'title': 'Number Systems, Sets & Logic Foundations',
                  'rationale': 'Cross-grade set theory bridge.',
                  'references': [
                    {
                      'grade': 9,
                      'unitNumber': 1,
                      'unitCode': 'MAT-G09-U01',
                      'unitTitle': 'Further on Sets',
                      'pages': 'pp. 1–26',
                      'hasQuickNotes': true,
                    },
                  ],
                  'sequence': [
                    {
                      'stepNumber': 1,
                      'text': 'Study Venn diagrams.',
                      'grade': 9,
                      'unitNumber': 1,
                      'unitCode': 'MAT-G09-U01',
                      'pages': 'pp. 1–26',
                    },
                  ],
                  'prerequisites': ['Basic arithmetic'],
                  'masteryCheckpoint': 'Complete 10 set cardinality drills.',
                  'completedSteps': [],
                  'isCompleted': false,
                  'progressPercentage': 0,
                },
              ],
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      if (request.url.path == '/api/v1/topics/modules/MAT-M01/progress') {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'success': true,
              'data': {
                'moduleId': 'MAT-M01',
                'subjectCode': 'MAT',
                'completedSteps': [1],
                'isCompleted': true,
                'progressPercentage': 100,
                'subjectMasteryPercentage': 10,
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      return http.Response(jsonEncode({'success': false}), 404);
    });

    final service = AiStudyService(
      apiClient: ApiClient(client: mockHttp, baseUrl: 'https://api.test'),
    );

    final modules = await service.fetchSubjectModules('MAT');
    expect(modules, hasLength(1));
    expect(modules.first.moduleId, 'MAT-M01');
    expect(modules.first.title, 'Number Systems, Sets & Logic Foundations');
    expect(modules.first.references.first.hasQuickNotes, isTrue);

    final updated = await service.updateModuleProgress(
      moduleId: 'MAT-M01',
      existingModule: modules.first,
      stepNumber: 1,
      stepCompleted: true,
    );
    expect(updated.title, 'Number Systems, Sets & Logic Foundations');
    expect(updated.references, hasLength(1));
    expect(updated.sequence, hasLength(1));
    expect(updated.completedSteps, [1]);
    expect(updated.isCompleted, isTrue);
    expect(updated.progressPercentage, 100);
  });

  testWidgets(
      'Marking a unit mastered in AiModuleDetailSheet checkmarks StudyScreen unit and syncs progress',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AuthStorage.instance.setUnitCompletions(['PHY-G09-U01', 'PHY-G11-U02'], false);

    tester.view.physicalSize = const Size(480, 915);
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

    final studyCurriculum = {
      'physics': const SubjectCurriculum(
        id: 'physics',
        name: 'Physics',
        mastery: 0,
        lastTopicId: 'PHY-G09-U01',
        iconData: HugeIcons.strokeRoundedAtom01,
        color: Color(0xFF7B3FE4),
        units: [
          StudyUnit(
            id: 'PHY-G09-U01',
            code: 'U1',
            unitCode: 'PHY-G09-U01',
            title: 'Physics and Human Society',
            examWeight: '15 Questions',
            expanded: false,
            topics: [],
            isCompleted: false,
          ),
        ],
      ),
    };

    int activeTab = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: StatefulBuilder(
          builder: (context, setTabState) {
            return Scaffold(
              bottomNavigationBar: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => setTabState(() => activeTab = 0),
                      child: const Text('Switch To AI'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => setTabState(() => activeTab = 1),
                      child: const Text('Switch To Study'),
                    ),
                  ),
                ],
              ),
              body: IndexedStack(
                index: activeTab,
                children: [
                  AiStudyScreen(
                    user: naturalUser,
                    repository: fakeRepo,
                    initialOverview: seededOverview,
                    initialModulesBySubject: {'PHY': fakeRepo.phyModules},
                  ),
                  StudyScreen(
                    user: const UserProfile(
                      id: 'usr_nat_01',
                      acedexId: 'ACEDEX-NAT-01',
                      displayName: 'Abebe Kebede',
                      grade: 9,
                      stream: 'natural',
                      role: 'student',
                      status: 'active',
                    ),
                    initialCurriculum: studyCurriculum,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify StudyScreen initially has 0/1 completed
    await tester.tap(find.text('Switch To Study'));
    await tester.pumpAndSettle();
    expect(find.text('• Completed'), findsNothing);

    // Switch back to AI Study tab, open PHY-M01, and mark referenced unit PHY-G09-U01 mastered
    await tester.tap(find.text('Switch To AI'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('Measurement Standards, Precision & Vector Analysis'),
    );
    await tester.pumpAndSettle();

    expect(find.text('0/2 units mastered'), findsOneWidget);

    fakeRepo.unitMasteryDelay = const Duration(milliseconds: 50);
    await tester.tap(find.bySemanticsLabel('Mark PHY-G09-U01 mastered'));
    // Pump intermediate frame while _savingUnitCode is active to verify AcedexDotsLoader fits cleanly without overflow
    await tester.pump();
    expect(find.byType(AcedexDotsLoader), findsOneWidget);
    await tester.pumpAndSettle();

    // Detail sheet reflects unit mastery + synced step
    expect(find.text('1/2 units mastered'), findsOneWidget);
    expect(find.text('PHY-G09-U01 • pp. 1–10 • Mastered'), findsOneWidget);
    expect(find.text('50% Mastered'), findsOneWidget);

    // Dismiss sheet & switch to StudyScreen in IndexedStack -> unit already checkmarked!
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Switch To Study'));
    await tester.pumpAndSettle();

    expect(
      AuthStorage.instance.completedUnitsNotifier.value.contains('PHY-G09-U01'),
      isTrue,
    );
    expect(find.text('• Completed'), findsOneWidget);
  });
}
