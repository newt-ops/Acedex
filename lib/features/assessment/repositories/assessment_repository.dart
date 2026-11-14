import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/assessment_models.dart';

abstract class AssessmentRepository {
  /// Fetches all published assessments that cover a given chapter (Unit, Mock, or Cumulative).
  Future<List<Assessment>> getAssessmentsForChapter(String chapterId);

  /// Fetches the primary current published assessment for a unit.
  Future<Assessment?> getCurrentAssessmentForChapter(String chapterId);

  /// Initiates an online assessment attempt, pinning it to the current version.
  Future<AssessmentAttemptCreationResult> startAttempt({
    required String assessmentId,
    required String idempotencyKey,
  });

  /// Atomically submits and grades an online attempt.
  Future<AssessmentSubmissionResult> submitAttempt({
    required String attemptId,
    required String idempotencyKey,
    required List<SelectedAnswerSubmission> answers,
  });

  /// Reconciles an offline attempt taken in Drift SQLite upon internet reconnection.
  Future<AssessmentSubmissionResult> reconcileOfflineAttempt({
    required String assessmentVersionId,
    required String attemptId,
    required String idempotencyKey,
    required DateTime clientStartedAt,
    required DateTime clientSubmittedAt,
    required List<SelectedAnswerSubmission> answers,
  });

  /// Fetches historical assessment result by attempt ID.
  Future<AssessmentSubmissionResult?> getResultForAttempt(String attemptId);
}

class SupabaseAssessmentRepository implements AssessmentRepository {
  final SupabaseClient? _client;

  SupabaseAssessmentRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService.clientOrNull;

  SupabaseClient get _activeClient {
    final client = _client ?? SupabaseService.clientOrNull;
    if (client == null) {
      throw const AuthException(
        'Supabase client is uninitialized. Please check network connectivity.',
      );
    }
    return client;
  }

  @override
  Future<List<Assessment>> getAssessmentsForChapter(String chapterId) async {
    final client = _activeClient;

    // PostgREST query retrieving assessments covering chapter via current version
    final response = await client
        .from('assessments')
        .select('''
          id,
          code,
          title,
          description,
          assessment_type,
          subject_id,
          grade,
          stream,
          current_version:assessment_versions!current_version_id (
            id,
            version_number,
            total_questions,
            total_points,
            time_limit_minutes,
            passing_percentage,
            chapters:assessment_version_chapters!inner (
              chapter_id,
              sort_order
            ),
            questions (
              id,
              chapter_id,
              code,
              difficulty,
              question_text,
              image_url,
              points,
              sort_order,
              question_options (
                id,
                option_letter,
                option_text,
                image_url,
                sort_order
              )
            )
          )
        ''')
        .eq('is_archived', false)
        .eq('current_version.chapters.chapter_id', chapterId)
        .order('sort_order', ascending: true, referencedTable: 'current_version.chapters')
        .order('sort_order', ascending: true, referencedTable: 'current_version.questions')
        .order('sort_order', ascending: true, referencedTable: 'current_version.questions.question_options');

    final list = response as List<dynamic>;
    return list.map((item) => Assessment.fromMap(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Assessment?> getCurrentAssessmentForChapter(String chapterId) async {
    final assessments = await getAssessmentsForChapter(chapterId);
    if (assessments.isEmpty) return null;
    return assessments.first;
  }

  @override
  Future<AssessmentAttemptCreationResult> startAttempt({
    required String assessmentId,
    required String idempotencyKey,
  }) async {
    final client = _activeClient;

    final response = await client.rpc(
      'start_assessment_attempt',
      params: {
        'p_assessment_id': assessmentId,
        'p_idempotency_key': idempotencyKey,
      },
    );

    final map = response as Map<String, dynamic>;
    return AssessmentAttemptCreationResult.fromMap(map);
  }

  @override
  Future<AssessmentSubmissionResult> submitAttempt({
    required String attemptId,
    required String idempotencyKey,
    required List<SelectedAnswerSubmission> answers,
  }) async {
    final client = _activeClient;

    final answersJson = answers.map((a) => a.toMap()).toList();

    final response = await client.rpc(
      'grade_and_submit_attempt',
      params: {
        'p_attempt_id': attemptId,
        'p_idempotency_key': idempotencyKey,
        'p_answers': answersJson,
      },
    );

    final map = response as Map<String, dynamic>;
    return AssessmentSubmissionResult.fromMap(map);
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
    final client = _activeClient;

    final answersJson = answers.map((a) => a.toMap()).toList();

    final response = await client.rpc(
      'reconcile_and_grade_offline_attempt',
      params: {
        'p_assessment_version_id': assessmentVersionId,
        'p_attempt_id': attemptId,
        'p_idempotency_key': idempotencyKey,
        'p_client_started_at': clientStartedAt.toIso8601String(),
        'p_client_submitted_at': clientSubmittedAt.toIso8601String(),
        'p_answers': answersJson,
      },
    );

    final map = response as Map<String, dynamic>;
    return AssessmentSubmissionResult.fromMap(map);
  }

  @override
  Future<AssessmentSubmissionResult?> getResultForAttempt(String attemptId) async {
    final client = _activeClient;

    final response = await client
        .from('assessment_results')
        .select('''
          *,
          answers:student_answers (
            question_id,
            selected_option_id,
            is_correct,
            points_awarded
          )
        ''')
        .eq('attempt_id', attemptId)
        .maybeSingle();

    if (response == null) return null;
    return AssessmentSubmissionResult.fromMap(response);
  }
}
