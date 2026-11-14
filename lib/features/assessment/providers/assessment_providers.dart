import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/curriculum_seeder.dart';
import '../models/assessment_models.dart';
import '../repositories/assessment_repository.dart';
import '../services/local_assessment_service.dart';
import '../services/offline_assessment_evaluator.dart';

/// Provider for the AssessmentRepository
final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return SupabaseAssessmentRepository();
});

/// Provider for the LocalAssessmentService backed by Drift SQLite
final localAssessmentServiceProvider = Provider<LocalAssessmentService>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalAssessmentService(db);
});

/// Fetches all published assessments available for a given chapter/unit
final chapterAssessmentsProvider =
    FutureProvider.family<List<Assessment>, String>((ref, chapterId) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  final localService = ref.watch(localAssessmentServiceProvider);

  try {
    final remoteAssessments = await repo.getAssessmentsForChapter(chapterId);
    if (remoteAssessments.isNotEmpty) {
      for (final a in remoteAssessments) {
        await localService.cacheAssessment(a);
      }
      return remoteAssessments;
    }
  } catch (_) {
    // Fall back to offline local storage
  }

  final cached = await localService.getCachedAssessmentForChapter(chapterId);
  return cached != null ? [cached] : [];
});

/// Fetches the primary current assessment for a given chapter/unit
final currentChapterAssessmentProvider =
    FutureProvider.family<Assessment?, String>((ref, chapterId) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  final localService = ref.watch(localAssessmentServiceProvider);
  final db = ref.watch(databaseProvider);

  try {
    final remote = await repo.getCurrentAssessmentForChapter(chapterId);
    if (remote != null) {
      await localService.cacheAssessment(remote);
      return remote;
    }
  } catch (_) {
    // Network failure / offline: fall back to Drift cache
  }

  var cached = await localService.getCachedAssessmentForChapter(chapterId);
  if (cached != null) return cached;

  // Self-healing: if cached is null, eagerly seed sample assessments
  try {
    await CurriculumSeeder.seedSampleAssessmentIfEmpty(db);
    cached = await localService.getCachedAssessmentForChapter(chapterId);
  } catch (_) {
    // Ignore seeding errors in restricted environments
  }

  return cached;
});

/// State of an active assessment attempt being taken
enum AssessmentPlayStatus {
  idle,
  loading,
  inProgress,
  submitting,
  submitted,
  error,
}

class AssessmentPlayState {
  final AssessmentPlayStatus status;
  final AssessmentFeedbackMode feedbackMode;
  final Assessment? assessment;
  final AssessmentVersion? version;
  final String? attemptId;
  final String? idempotencyKey;
  final DateTime? startedAt;
  final Map<String, String> selectedAnswers; // questionId -> optionId
  final Map<String, QuestionSolutionInfo> instantSolutions; // questionId -> solution info
  final int currentQuestionIndex;
  final AssessmentSubmissionResult? result;
  final String? errorMessage;

  const AssessmentPlayState({
    this.status = AssessmentPlayStatus.idle,
    this.feedbackMode = AssessmentFeedbackMode.afterSubmit,
    this.assessment,
    this.version,
    this.attemptId,
    this.idempotencyKey,
    this.startedAt,
    this.selectedAnswers = const {},
    this.instantSolutions = const {},
    this.currentQuestionIndex = 0,
    this.result,
    this.errorMessage,
  });

  AssessmentPlayState copyWith({
    AssessmentPlayStatus? status,
    AssessmentFeedbackMode? feedbackMode,
    Assessment? assessment,
    AssessmentVersion? version,
    String? attemptId,
    String? idempotencyKey,
    DateTime? startedAt,
    Map<String, String>? selectedAnswers,
    Map<String, QuestionSolutionInfo>? instantSolutions,
    int? currentQuestionIndex,
    AssessmentSubmissionResult? result,
    String? errorMessage,
  }) {
    return AssessmentPlayState(
      status: status ?? this.status,
      feedbackMode: feedbackMode ?? this.feedbackMode,
      assessment: assessment ?? this.assessment,
      version: version ?? this.version,
      attemptId: attemptId ?? this.attemptId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      startedAt: startedAt ?? this.startedAt,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      instantSolutions: instantSolutions ?? this.instantSolutions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  int get totalQuestions => version?.questions.length ?? 0;
  int get answeredCount => selectedAnswers.length;
  double get progressPercentage =>
      totalQuestions > 0 ? (answeredCount / totalQuestions) : 0.0;
}

/// Controller managing active assessment playback, tactile selection, and submission
class AssessmentPlayController extends StateNotifier<AssessmentPlayState> {
  final AssessmentRepository _repository;
  final LocalAssessmentService? _localService;

  AssessmentPlayController(this._repository, [this._localService])
      : super(const AssessmentPlayState());

  /// Initializes an assessment session for a given assessment
  Future<bool> startAssessment(
    Assessment assessment, {
    AssessmentFeedbackMode feedbackMode = AssessmentFeedbackMode.afterSubmit,
  }) async {
    final version = assessment.currentVersion;
    if (version == null || version.questions.isEmpty) {
      state = state.copyWith(
        status: AssessmentPlayStatus.error,
        errorMessage: 'Assessment has no published questions available.',
      );
      return false;
    }

    Map<String, QuestionSolutionInfo> solutions = {};
    if (feedbackMode == AssessmentFeedbackMode.immediate) {
      solutions = await OfflineAssessmentEvaluator.getSolutionsMap(version);
    }

    state = state.copyWith(
      status: AssessmentPlayStatus.loading,
      assessment: assessment,
      version: version,
      feedbackMode: feedbackMode,
      instantSolutions: solutions,
      errorMessage: null,
    );

    try {
      final key = 'attempt_${DateTime.now().millisecondsSinceEpoch}_${assessment.id.substring(0, 8)}';
      final creationResult = await _repository.startAttempt(
        assessmentId: assessment.id,
        idempotencyKey: key,
      );

      state = state.copyWith(
        status: AssessmentPlayStatus.inProgress,
        feedbackMode: feedbackMode,
        instantSolutions: solutions,
        attemptId: creationResult.attemptId,
        idempotencyKey: key,
        startedAt: creationResult.serverStartedAt,
        selectedAnswers: {},
        currentQuestionIndex: 0,
      );

      // Cache attempt start locally in Drift
      await _localService?.saveLocalAttemptAnswers(
        attemptId: creationResult.attemptId,
        studentId: 'current_student',
        assessmentVersionId: version.id,
        idempotencyKey: key,
        startedAt: creationResult.serverStartedAt,
        answers: {},
      );

      return true;
    } catch (e) {
      // In offline / guest fallback: allow local test-taking with local UUID
      final localAttemptId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final localKey = 'local_key_${DateTime.now().millisecondsSinceEpoch}';
      final localStartedAt = DateTime.now();

      state = state.copyWith(
        status: AssessmentPlayStatus.inProgress,
        feedbackMode: feedbackMode,
        instantSolutions: solutions,
        attemptId: localAttemptId,
        idempotencyKey: localKey,
        startedAt: localStartedAt,
        selectedAnswers: {},
        currentQuestionIndex: 0,
      );

      await _localService?.saveLocalAttemptAnswers(
        attemptId: localAttemptId,
        studentId: 'offline_guest',
        assessmentVersionId: version.id,
        idempotencyKey: localKey,
        startedAt: localStartedAt,
        answers: {},
      );

      return true;
    }
  }

  /// Instant local answer selection (0ms UI latency)
  void selectOption(String questionId, String optionId) {
    // In immediate feedback mode, once an option has been chosen for this question,
    // lock the selection to avoid gaming after seeing the answer
    if (state.feedbackMode == AssessmentFeedbackMode.immediate &&
        state.selectedAnswers.containsKey(questionId)) {
      return;
    }

    final updated = Map<String, String>.from(state.selectedAnswers);
    if (updated[questionId] == optionId) {
      // Tapping selected option deselects it
      updated.remove(questionId);
    } else {
      updated[questionId] = optionId;
    }
    state = state.copyWith(selectedAnswers: updated);

    // Persist answers locally asynchronously
    if (state.attemptId != null && state.version != null && state.idempotencyKey != null) {
      _localService?.saveLocalAttemptAnswers(
        attemptId: state.attemptId!,
        studentId: 'current_student',
        assessmentVersionId: state.version!.id,
        idempotencyKey: state.idempotencyKey!,
        startedAt: state.startedAt ?? DateTime.now(),
        answers: updated,
      );
    }
  }

  /// Navigate to specific question index
  void jumpToQuestion(int index) {
    if (index >= 0 && index < state.totalQuestions) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  /// Navigate to next question
  void nextQuestion() {
    if (state.currentQuestionIndex < state.totalQuestions - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  /// Navigate to previous question
  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  /// Submits the completed attempt
  Future<bool> submit() async {
    final attemptId = state.attemptId;
    final idempotencyKey = state.idempotencyKey;
    final version = state.version;

    if (attemptId == null || idempotencyKey == null || version == null) {
      state = state.copyWith(
        status: AssessmentPlayStatus.error,
        errorMessage: 'Invalid attempt state for submission.',
      );
      return false;
    }

    state = state.copyWith(status: AssessmentPlayStatus.submitting);

    // Format answers array for RPC
    final answersList = version.questions.map((q) {
      return SelectedAnswerSubmission(
        questionId: q.id,
        selectedOptionId: state.selectedAnswers[q.id],
      );
    }).toList();

    try {
      AssessmentSubmissionResult submissionResult;

      if (attemptId.startsWith('local_')) {
        // Offline attempt reconciliation
        submissionResult = await _repository.reconcileOfflineAttempt(
          assessmentVersionId: version.id,
          attemptId: '00000000-0000-0000-0000-${DateTime.now().millisecondsSinceEpoch.toString().padLeft(12, '0').substring(0, 12)}',
          idempotencyKey: idempotencyKey,
          clientStartedAt: state.startedAt ?? DateTime.now(),
          clientSubmittedAt: DateTime.now(),
          answers: answersList,
        );
      } else {
        // Standard online submission
        submissionResult = await _repository.submitAttempt(
          attemptId: attemptId,
          idempotencyKey: idempotencyKey,
          answers: answersList,
        );
      }

      // Save graded result locally in Drift
      await _localService?.saveGradedResult(
        resultId: 'res_${DateTime.now().millisecondsSinceEpoch}',
        attemptId: attemptId,
        studentId: 'current_student',
        assessmentVersionId: version.id,
        result: submissionResult,
      );

      state = state.copyWith(
        status: AssessmentPlayStatus.submitted,
        result: submissionResult,
      );
      return true;
    } catch (e) {
      // Offline fallback: check if local asset evaluation is possible
      final offlineResult = await OfflineAssessmentEvaluator.evaluateFromAsset(
        version: version,
        attemptId: attemptId,
        selectedAnswers: state.selectedAnswers,
      );

      if (offlineResult != null) {
        await _localService?.saveGradedResult(
          resultId: 'res_${DateTime.now().millisecondsSinceEpoch}',
          attemptId: attemptId,
          studentId: 'current_student',
          assessmentVersionId: version.id,
          result: offlineResult,
        );

        state = state.copyWith(
          status: AssessmentPlayStatus.submitted,
          result: offlineResult,
        );
        return true;
      }

      // Mark as pending sync locally
      await _localService?.saveLocalAttemptAnswers(
        attemptId: attemptId,
        studentId: 'current_student',
        assessmentVersionId: version.id,
        idempotencyKey: idempotencyKey,
        startedAt: state.startedAt ?? DateTime.now(),
        answers: state.selectedAnswers,
        isPendingSync: true,
      );

      state = state.copyWith(
        status: AssessmentPlayStatus.error,
        errorMessage: 'Submission failed: $e',
      );
      return false;
    }
  }

  /// Resets state after viewing results
  void reset() {
    state = const AssessmentPlayState();
  }
}

final assessmentPlayControllerProvider =
    StateNotifierProvider<AssessmentPlayController, AssessmentPlayState>((ref) {
  final repo = ref.watch(assessmentRepositoryProvider);
  final localService = ref.watch(localAssessmentServiceProvider);
  return AssessmentPlayController(repo, localService);
});
