import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/database.dart';
import '../models/assessment_models.dart';

class LocalAssessmentService {
  final AppDatabase _db;

  LocalAssessmentService(this._db);

  /// Caches a downloaded assessment and its sanitized questions/options into Drift SQLite
  Future<void> cacheAssessment(Assessment assessment) async {
    final version = assessment.currentVersion;
    if (version == null) return;

    await _db.batch((batch) {
      // 1. Insert/Update Assessment
      batch.insert(
        _db.localAssessments,
        LocalAssessmentsCompanion.insert(
          id: assessment.id,
          code: assessment.code,
          title: assessment.title,
          description: Value(assessment.description),
          assessmentType: Value(assessment.assessmentType.toDbString()),
          currentVersionId: Value(assessment.currentVersionId),
          subjectId: Value(assessment.subjectId),
          grade: Value(assessment.grade),
          stream: Value(assessment.stream),
          updatedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrReplace,
      );

      // 2. Insert/Update Version
      batch.insert(
        _db.localAssessmentVersions,
        LocalAssessmentVersionsCompanion.insert(
          id: version.id,
          assessmentId: assessment.id,
          versionNumber: version.versionNumber,
          status: Value(version.status),
          totalQuestions: Value(version.totalQuestions),
          totalPoints: Value(version.totalPoints),
          timeLimitMinutes: Value(version.timeLimitMinutes),
          passingPercentage: Value(version.passingPercentage),
          publishedAt: Value(version.publishedAt),
        ),
        mode: InsertMode.insertOrReplace,
      );

      // 3. Insert Version Chapters
      int sortOrder = 1;
      for (final chapterId in version.coveredChapterIds) {
        batch.insert(
          _db.localAssessmentVersionChapters,
          LocalAssessmentVersionChaptersCompanion.insert(
            assessmentVersionId: version.id,
            chapterId: chapterId,
            sortOrder: Value(sortOrder++),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }

      // 4. Insert Questions & Options
      for (final q in version.questions) {
        batch.insert(
          _db.localQuestions,
          LocalQuestionsCompanion.insert(
            id: q.id,
            assessmentVersionId: version.id,
            chapterId: q.chapterId,
            questionText: q.questionText,
            questionType: Value(q.questionType),
            imageUrl: Value(q.imageUrl),
            points: Value(q.points),
            sortOrder: Value(q.sortOrder),
          ),
          mode: InsertMode.insertOrReplace,
        );

        for (final opt in q.options) {
          batch.insert(
            _db.localQuestionOptions,
            LocalQuestionOptionsCompanion.insert(
              id: opt.id,
              questionId: q.id,
              optionLetter: opt.optionLetter,
              optionText: opt.optionText,
              imageUrl: Value(opt.imageUrl),
              sortOrder: Value(opt.sortOrder),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }
    });
  }

  /// Retrieves a cached assessment for a given chapter from Drift SQLite
  Future<Assessment?> getCachedAssessmentForChapter(String chapterId) async {
    // 1. Direct match
    var chapterLinks = await (_db.select(
      _db.localAssessmentVersionChapters,
    )..where((tbl) => tbl.chapterId.equals(chapterId))).get();

    // 2. Fallback aliases if direct match fails
    if (chapterLinks.isEmpty) {
      final possibleAliases = <String>{
        chapterId.replaceAll('-', '_'),
        chapterId.replaceAll('_', '-'),
        if (chapterId.contains('_U') && !chapterId.contains('_U0'))
          chapterId.replaceFirst('_U', '_U0'),
        if (chapterId.contains('_U0'))
          chapterId.replaceFirst('_U0', '_U'),
        if (chapterId.contains('-U') && !chapterId.contains('-U0'))
          chapterId.replaceFirst('-U', '-U0'),
        if (chapterId.contains('-U0'))
          chapterId.replaceFirst('-U0', '-U'),
      };

      for (final alias in possibleAliases) {
        final links = await (_db.select(
          _db.localAssessmentVersionChapters,
        )..where((tbl) => tbl.chapterId.equals(alias))).get();
        if (links.isNotEmpty) {
          chapterLinks = links;
          break;
        }
      }
    }

    if (chapterLinks.isEmpty) return null;

    final versionId = chapterLinks.first.assessmentVersionId;

    // Fetch Version
    final versions = await (_db.select(
      _db.localAssessmentVersions,
    )..where((tbl) => tbl.id.equals(versionId))).get();

    if (versions.isEmpty) return null;
    final verRow = versions.first;

    // Fetch Assessment Header
    final assessments = await (_db.select(
      _db.localAssessments,
    )..where((tbl) => tbl.id.equals(verRow.assessmentId))).get();

    if (assessments.isEmpty) return null;
    final assessRow = assessments.first;

    // Fetch Questions
    final questions =
        await (_db.select(_db.localQuestions)
              ..where((tbl) => tbl.assessmentVersionId.equals(versionId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();

    final List<Question> questionModels = [];

    for (final qRow in questions) {
      final options =
          await (_db.select(_db.localQuestionOptions)
                ..where((tbl) => tbl.questionId.equals(qRow.id))
                ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
              .get();

      final optionModels = options
          .map(
            (opt) => QuestionOption(
              id: opt.id,
              questionId: opt.questionId,
              optionLetter: opt.optionLetter,
              optionText: opt.optionText,
              imageUrl: opt.imageUrl,
              sortOrder: opt.sortOrder,
            ),
          )
          .toList();

      questionModels.add(
        Question(
          id: qRow.id,
          assessmentVersionId: qRow.assessmentVersionId,
          chapterId: qRow.chapterId,
          questionText: qRow.questionText,
          questionType: qRow.questionType,
          imageUrl: qRow.imageUrl,
          points: qRow.points,
          sortOrder: qRow.sortOrder,
          options: optionModels,
        ),
      );
    }

    final versionModel = AssessmentVersion(
      id: verRow.id,
      assessmentId: verRow.assessmentId,
      versionNumber: verRow.versionNumber,
      status: verRow.status,
      totalQuestions: verRow.totalQuestions,
      totalPoints: verRow.totalPoints,
      timeLimitMinutes: verRow.timeLimitMinutes,
      passingPercentage: verRow.passingPercentage,
      publishedAt: verRow.publishedAt,
      coveredChapterIds: chapterLinks.map((c) => c.chapterId).toList(),
      questions: questionModels,
    );

    return Assessment(
      id: assessRow.id,
      code: assessRow.code,
      title: assessRow.title,
      description: assessRow.description,
      assessmentType: AssessmentType.fromString(assessRow.assessmentType),
      currentVersionId: assessRow.currentVersionId,
      subjectId: assessRow.subjectId,
      grade: assessRow.grade,
      stream: assessRow.stream,
      createdAt: assessRow.updatedAt,
      updatedAt: assessRow.updatedAt,
      currentVersion: versionModel,
    );
  }

  /// Persists student answers locally during active test-taking
  Future<void> saveLocalAttemptAnswers({
    required String attemptId,
    required String studentId,
    required String assessmentVersionId,
    required String idempotencyKey,
    required DateTime startedAt,
    required Map<String, String> answers,
    bool isPendingSync = false,
  }) async {
    await _db
        .into(_db.localAssessmentAttempts)
        .insertOnConflictUpdate(
          LocalAssessmentAttemptsCompanion.insert(
            id: attemptId,
            studentId: studentId,
            assessmentVersionId: assessmentVersionId,
            status: Value(isPendingSync ? 'pending_sync' : 'in_progress'),
            isOfflineSync: const Value(true),
            timingVerified: const Value(false),
            startedAt: startedAt,
            submittedAt: Value(isPendingSync ? DateTime.now() : null),
            idempotencyKey: idempotencyKey,
            answersJson: Value(jsonEncode(answers)),
          ),
        );
  }

  /// Caches the final graded result and corrections
  Future<void> saveGradedResult({
    required String resultId,
    required String attemptId,
    required String studentId,
    required String assessmentVersionId,
    required AssessmentSubmissionResult result,
  }) async {
    final correctionsString = jsonEncode(
      result.corrections
          .map(
            (c) => {
              'question_id': c.questionId,
              'selected_option_id': c.selectedOptionId,
              'correct_option_id': c.correctOptionId,
              'is_correct': c.isCorrect,
              'points_awarded': c.pointsAwarded,
              'explanation': c.explanation,
            },
          )
          .toList(),
    );

    await _db
        .into(_db.localAssessmentResults)
        .insertOnConflictUpdate(
          LocalAssessmentResultsCompanion.insert(
            id: resultId,
            attemptId: attemptId,
            studentId: studentId,
            assessmentVersionId: assessmentVersionId,
            totalQuestions: result.totalQuestions,
            answeredQuestions: Value(result.answeredQuestions),
            correctAnswers: Value(result.correctAnswers),
            scoreObtained: Value(result.scoreObtained),
            maxScore: result.maxScore,
            percentage: result.percentage,
            passed: Value(result.passed),
            isOverdue: Value(result.isOverdue),
            correctionsJson: Value(correctionsString),
            gradedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Retrieves pending sync attempts
  Future<List<LocalAssessmentAttempt>> getPendingSyncAttempts() async {
    return (_db.select(
      _db.localAssessmentAttempts,
    )..where((tbl) => tbl.status.equals('pending_sync'))).get();
  }
}
