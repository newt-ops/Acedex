import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/features/assessment/models/assessment_models.dart';
import 'package:acedex/features/assessment/repositories/assessment_repository.dart';
import 'package:acedex/features/assessment/providers/assessment_providers.dart';

class MockAssessmentRepository implements AssessmentRepository {
  bool shouldFailSubmission = false;
  AssessmentSubmissionResult? mockResult;

  @override
  Future<List<Assessment>> getAssessmentsForChapter(String chapterId) async => [];

  @override
  Future<Assessment?> getCurrentAssessmentForChapter(String chapterId) async => null;

  @override
  Future<AssessmentAttemptCreationResult> startAttempt({
    required String assessmentId,
    required String idempotencyKey,
  }) async {
    return AssessmentAttemptCreationResult(
      status: 'created',
      attemptId: 'server_attempt_999',
      assessmentVersionId: 'ver_999',
      serverStartedAt: DateTime.now(),
      totalQuestions: 2,
    );
  }

  @override
  Future<AssessmentSubmissionResult> submitAttempt({
    required String attemptId,
    required String idempotencyKey,
    required List<SelectedAnswerSubmission> answers,
  }) async {
    if (shouldFailSubmission) {
      throw Exception('Simulated network error');
    }
    return mockResult ??
        AssessmentSubmissionResult(
          status: 'success',
          attemptId: attemptId,
          totalQuestions: answers.length,
          answeredQuestions: answers.where((a) => a.selectedOptionId != null).length,
          correctAnswers: 2,
          scoreObtained: 4.0,
          maxScore: 4.0,
          percentage: 100.0,
          passed: true,
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
  Future<AssessmentSubmissionResult?> getResultForAttempt(String attemptId) async => null;
}

void main() {
  group('AssessmentPlayController State Management Tests', () {
    late MockAssessmentRepository mockRepo;
    late AssessmentPlayController controller;

    final testAssessment = Assessment(
      id: 'assess_test',
      code: 'TEST_ASSESSMENT',
      title: 'Test Exam',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentVersion: AssessmentVersion(
        id: 'ver_test',
        assessmentId: 'assess_test',
        versionNumber: 1,
        status: 'published',
        totalQuestions: 2,
        totalPoints: 4.0,
        questions: [
          Question(
            id: 'q1',
            assessmentVersionId: 'ver_test',
            chapterId: 'U1',
            questionText: 'Question 1',
            sortOrder: 1,
            options: [
              QuestionOption(id: 'opt1_A', questionId: 'q1', optionLetter: 'A', optionText: 'Choice A', sortOrder: 1),
              QuestionOption(id: 'opt1_B', questionId: 'q1', optionLetter: 'B', optionText: 'Choice B', sortOrder: 2),
            ],
          ),
          Question(
            id: 'q2',
            assessmentVersionId: 'ver_test',
            chapterId: 'U1',
            questionText: 'Question 2',
            sortOrder: 2,
            options: [
              QuestionOption(id: 'opt2_A', questionId: 'q2', optionLetter: 'A', optionText: 'Choice A', sortOrder: 1),
              QuestionOption(id: 'opt2_B', questionId: 'q2', optionLetter: 'B', optionText: 'Choice B', sortOrder: 2),
            ],
          ),
        ],
      ),
    );

    setUp(() {
      mockRepo = MockAssessmentRepository();
      controller = AssessmentPlayController(mockRepo);
    });

    test('Initial state is idle', () {
      expect(controller.state.status, AssessmentPlayStatus.idle);
      expect(controller.state.selectedAnswers, isEmpty);
      expect(controller.state.currentQuestionIndex, 0);
    });

    test('startAssessment initializes attempt and resets answers', () async {
      final success = await controller.startAssessment(testAssessment);
      expect(success, true);
      expect(controller.state.status, AssessmentPlayStatus.inProgress);
      expect(controller.state.attemptId, 'server_attempt_999');
      expect(controller.state.totalQuestions, 2);
      expect(controller.state.selectedAnswers, isEmpty);
    });

    test('selectOption updates local state with 0ms latency and supports toggle', () async {
      await controller.startAssessment(testAssessment);

      // Select Option B for Question 1
      controller.selectOption('q1', 'opt1_B');
      expect(controller.state.selectedAnswers['q1'], 'opt1_B');
      expect(controller.state.answeredCount, 1);
      expect(controller.state.progressPercentage, 0.5);

      // Change selection to Option A
      controller.selectOption('q1', 'opt1_A');
      expect(controller.state.selectedAnswers['q1'], 'opt1_A');

      // Tapping same selection toggles / unselects it
      controller.selectOption('q1', 'opt1_A');
      expect(controller.state.selectedAnswers.containsKey('q1'), false);
      expect(controller.state.answeredCount, 0);
    });

    test('Question navigation updates currentQuestionIndex', () async {
      await controller.startAssessment(testAssessment);
      expect(controller.state.currentQuestionIndex, 0);

      controller.nextQuestion();
      expect(controller.state.currentQuestionIndex, 1);

      // Bounded by totalQuestions
      controller.nextQuestion();
      expect(controller.state.currentQuestionIndex, 1);

      controller.previousQuestion();
      expect(controller.state.currentQuestionIndex, 0);

      controller.jumpToQuestion(1);
      expect(controller.state.currentQuestionIndex, 1);
    });

    test('submit successfully calls repository and updates state to submitted', () async {
      await controller.startAssessment(testAssessment);
      controller.selectOption('q1', 'opt1_B');
      controller.selectOption('q2', 'opt2_A');

      final success = await controller.submit();
      expect(success, true);
      expect(controller.state.status, AssessmentPlayStatus.submitted);
      expect(controller.state.result, isNotNull);
      expect(controller.state.result!.percentage, 100.0);
    });

    test('submit handles errors gracefully without crashing', () async {
      mockRepo.shouldFailSubmission = true;
      await controller.startAssessment(testAssessment);
      controller.selectOption('q1', 'opt1_B');

      final success = await controller.submit();
      expect(success, false);
      expect(controller.state.status, AssessmentPlayStatus.error);
      expect(controller.state.errorMessage, contains('Simulated network error'));
    });

    test('startAssessment with immediate feedbackMode locks selection once selected', () async {
      await controller.startAssessment(
        testAssessment,
        feedbackMode: AssessmentFeedbackMode.immediate,
      );
      expect(controller.state.feedbackMode, AssessmentFeedbackMode.immediate);

      // First selection succeeds
      controller.selectOption('q1', 'opt1_A');
      expect(controller.state.selectedAnswers['q1'], 'opt1_A');

      // Second selection on same question is locked in immediate mode to prevent cheating
      controller.selectOption('q1', 'opt1_B');
      expect(controller.state.selectedAnswers['q1'], 'opt1_A');
    });
  });
}
