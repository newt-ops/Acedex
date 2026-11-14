import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:acedex/core/theme/app_theme.dart';
import 'package:acedex/core/theme/theme_provider.dart';
import 'package:acedex/core/database/database.dart';
import 'package:acedex/core/database/database_provider.dart';
import 'package:acedex/features/assessment/models/assessment_models.dart';
import 'package:acedex/features/assessment/providers/assessment_providers.dart';
import 'package:acedex/features/assessment/repositories/assessment_repository.dart';
import 'package:acedex/features/assessment/screens/assessment_intro_screen.dart';
import 'package:acedex/features/assessment/screens/assessment_player_screen.dart';
import 'package:acedex/features/assessment/screens/assessment_result_screen.dart';
import 'package:acedex/features/assessment/services/offline_assessment_evaluator.dart';

class MockAssessmentRepository implements AssessmentRepository {
  final Assessment assessment;

  MockAssessmentRepository(this.assessment);

  @override
  Future<List<Assessment>> getAssessmentsForChapter(String chapterId) async {
    return [assessment];
  }

  @override
  Future<Assessment?> getCurrentAssessmentForChapter(String chapterId) async {
    return assessment;
  }

  @override
  Future<AssessmentAttemptCreationResult> startAttempt({
    required String assessmentId,
    required String idempotencyKey,
  }) async {
    return AssessmentAttemptCreationResult(
      attemptId: 'att_mock_001',
      assessmentVersionId: assessment.currentVersion!.id,
      serverStartedAt: DateTime.now(),
      status: 'in_progress',
      totalQuestions: 2,
    );
  }

  @override
  Future<AssessmentSubmissionResult> submitAttempt({
    required String attemptId,
    required String idempotencyKey,
    required List<SelectedAnswerSubmission> answers,
  }) async {
    return AssessmentSubmissionResult(
      status: 'success',
      attemptId: attemptId,
      totalQuestions: 2,
      answeredQuestions: 2,
      correctAnswers: 2,
      scoreObtained: 2.0,
      maxScore: 2.0,
      percentage: 100.0,
      passed: true,
      isOverdue: false,
      timingVerified: true,
      durationSeconds: 90,
      corrections: const [
        QuestionCorrection(
          questionId: 'q001',
          selectedOptionId: 'o001',
          correctOptionId: 'o001',
          isCorrect: true,
          pointsAwarded: 1.0,
          explanation: 'Thermodynamics is the study of heat and energy transfer.',
        ),
        QuestionCorrection(
          questionId: 'q002',
          selectedOptionId: 'o003',
          correctOptionId: 'o003',
          isCorrect: true,
          pointsAwarded: 1.0,
          explanation: 'Ampere is the SI base unit of electric current.',
        ),
      ],
    );
  }

  @override
  Future<AssessmentSubmissionResult> reconcileOfflineAttempt({
    required String assessmentVersionId,
    required String attemptId,
    required String idempotencyKey,
    required DateTime clientStartedAt,
    required DateTime clientSubmittedAt,
    required List<SelectedAnswerSubmission> answers,
  }) async {
    return submitAttempt(
      attemptId: attemptId,
      idempotencyKey: idempotencyKey,
      answers: answers,
    );
  }

  @override
  Future<AssessmentSubmissionResult?> getResultForAttempt(String attemptId) async {
    return null;
  }
}

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  final testAssessment = Assessment(
    id: 'a001',
    code: 'PHYS_G9_U01_TEST',
    title: 'Physics and Human Society Test',
    description: 'Unit 1 comprehensive diagnostic assessment',
    assessmentType: AssessmentType.unit,
    currentVersionId: 'v001',
    subjectId: 'PHYS_G9',
    grade: 9,
    stream: 'natural',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    currentVersion: AssessmentVersion(
      id: 'v001',
      assessmentId: 'a001',
      versionNumber: 1,
      status: 'published',
      totalQuestions: 2,
      totalPoints: 2.0,
      timeLimitMinutes: 30,
      passingPercentage: 60.0,
      publishedAt: DateTime.now(),
      coveredChapterIds: const ['PHYS_G9_U1'],
      questions: const [
        Question(
          id: 'q001',
          assessmentVersionId: 'v001',
          chapterId: 'PHYS_G9_U1',
          questionText: 'Which branch of physics studies heat and temperature?',
          points: 1,
          sortOrder: 1,
          options: [
            QuestionOption(
              id: 'o001',
              questionId: 'q001',
              optionLetter: 'A',
              optionText: 'Thermodynamics',
              sortOrder: 1,
            ),
            QuestionOption(
              id: 'o002',
              questionId: 'q001',
              optionLetter: 'B',
              optionText: 'Optics',
              sortOrder: 2,
            ),
          ],
        ),
        Question(
          id: 'q002',
          assessmentVersionId: 'v001',
          chapterId: 'PHYS_G9_U1',
          questionText: 'What is the SI unit of electric current?',
          points: 1,
          sortOrder: 2,
          options: [
            QuestionOption(
              id: 'o003',
              questionId: 'q002',
              optionLetter: 'A',
              optionText: 'Ampere',
              sortOrder: 1,
            ),
            QuestionOption(
              id: 'o004',
              questionId: 'q002',
              optionLetter: 'B',
              optionText: 'Volt',
              sortOrder: 2,
            ),
          ],
        ),
      ],
    ),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget createTestApp(Widget child) {
    final mockRepo = MockAssessmentRepository(testAssessment);
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        assessmentRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  testWidgets('AssessmentIntroScreen displays test details and guidelines',
      (tester) async {
    await tester.pumpWidget(createTestApp(
      const AssessmentIntroScreen(
        chapterId: 'PHYS_G9_U1',
        unitTitle: 'Physics and Human Society',
        subjectName: 'Physics',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Unit Assessment'), findsOneWidget);
    expect(find.text('Physics and Human Society Test'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Start Assessment'), findsOneWidget);
  });

  testWidgets('AssessmentPlayerScreen handles tactile answer selection and question navigation',
      (tester) async {
    final mockRepo = MockAssessmentRepository(testAssessment);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        assessmentRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );

    // Initialize controller with test assessment
    await container
        .read(assessmentPlayControllerProvider.notifier)
        .startAssessment(testAssessment);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AssessmentPlayerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Question 1 is displayed
    expect(find.text('Question 1 of 2'), findsOneWidget);
    expect(find.text('Which branch of physics studies heat and temperature?'), findsOneWidget);
    expect(find.text('Thermodynamics'), findsOneWidget);
    expect(find.text('Optics'), findsOneWidget);

    // Select Option A (Thermodynamics)
    await tester.tap(find.text('Thermodynamics'));
    await tester.pumpAndSettle();

    expect(
      container.read(assessmentPlayControllerProvider).selectedAnswers['q001'],
      'o001',
    );

    // Navigate to Next Question
    await tester.tap(find.text('Next Question'));
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 2'), findsOneWidget);
    expect(find.text('What is the SI unit of electric current?'), findsOneWidget);
    expect(find.text('Review & Submit'), findsOneWidget);
  });

  testWidgets('AssessmentResultScreen renders scores, metrics, and explanations',
      (tester) async {
    const mockResult = AssessmentSubmissionResult(
      status: 'success',
      attemptId: 'att_001',
      totalQuestions: 2,
      answeredQuestions: 2,
      correctAnswers: 2,
      scoreObtained: 2.0,
      maxScore: 2.0,
      percentage: 100.0,
      passed: true,
      isOverdue: false,
      timingVerified: true,
      durationSeconds: 110,
      corrections: [
        QuestionCorrection(
          questionId: 'q001',
          selectedOptionId: 'o001',
          correctOptionId: 'o001',
          isCorrect: true,
          pointsAwarded: 1.0,
          explanation: 'Thermodynamics is the study of heat and energy transfer.',
        ),
      ],
    );

    await tester.pumpWidget(createTestApp(
      AssessmentResultScreen(
        result: mockResult,
        assessment: testAssessment,
        version: testAssessment.currentVersion,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Assessment Results'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Assessment Passed'), findsOneWidget);
    expect(find.text('Earned 2.0 out of 2.0 points'), findsOneWidget);
    expect(find.text('Pedagogical Review & Explanations'), findsOneWidget);
    expect(find.text('Thermodynamics is the study of heat and energy transfer.'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('AssessmentIntroScreen allows selecting answer reveal mode before start',
      (tester) async {
    await tester.pumpWidget(createTestApp(
      const AssessmentIntroScreen(
        chapterId: 'PHYS_G9_U1',
        unitTitle: 'Physics and Human Society',
        subjectName: 'Physics',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Answer Reveal Mode'), findsOneWidget);
    expect(find.text('See Answers After Submit'), findsOneWidget);
    expect(find.text('See Answers Immediately'), findsOneWidget);

    // Tap to switch to Immediate Feedback mode
    await tester.ensureVisible(find.text('See Answers Immediately'));
    await tester.tap(find.text('See Answers Immediately'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.textContaining('Instant learning:'));
    expect(find.textContaining('Instant learning:'), findsOneWidget);
  });

  testWidgets('AssessmentPlayerScreen in immediate mode displays instant answer reveal and explanation',
      (tester) async {
    final mockRepo = MockAssessmentRepository(testAssessment);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        assessmentRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );

    // Start in immediate feedback mode with preloaded instant solutions
    await container
        .read(assessmentPlayControllerProvider.notifier)
        .startAssessment(
          testAssessment,
          feedbackMode: AssessmentFeedbackMode.immediate,
        );

    // Inject mock instant solution for test question
    container.read(assessmentPlayControllerProvider.notifier).state =
        container.read(assessmentPlayControllerProvider).copyWith(
      instantSolutions: {
        'q001': const QuestionSolutionInfo(
          questionId: 'q001',
          correctOptionLetter: 'A',
          explanation: 'Thermodynamics is the study of heat and energy transfer.',
        ),
      },
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AssessmentPlayerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app bar subtitle shows Practice Mode
    expect(find.text('Practice Mode • Instant Feedback'), findsOneWidget);

    // Select Option A (Correct answer)
    await tester.tap(find.text('Thermodynamics'));
    await tester.pumpAndSettle();

    // Verify instant feedback appears
    expect(find.text('Correct Answer!'), findsOneWidget);
    expect(find.text('Thermodynamics is the study of heat and energy transfer.'), findsOneWidget);
  });
}
