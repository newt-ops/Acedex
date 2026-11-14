import 'package:flutter/foundation.dart';

/// Assessment types supported across Acedex.
enum AssessmentType {
  unit,
  subjectMock,
  gradeCumulative,
  eueeMock;

  static AssessmentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'unit':
        return AssessmentType.unit;
      case 'subject_mock':
        return AssessmentType.subjectMock;
      case 'grade_cumulative':
        return AssessmentType.gradeCumulative;
      case 'euee_mock':
        return AssessmentType.eueeMock;
      default:
        return AssessmentType.unit;
    }
  }

  String toDbString() {
    switch (this) {
      case AssessmentType.unit:
        return 'unit';
      case AssessmentType.subjectMock:
        return 'subject_mock';
      case AssessmentType.gradeCumulative:
        return 'grade_cumulative';
      case AssessmentType.eueeMock:
        return 'euee_mock';
    }
  }
}

/// Timing mode for revealing answers and explanations to students.
enum AssessmentFeedbackMode {
  /// Standard exam mode: answers & explanations revealed only after final submission.
  afterSubmit,

  /// Practice mode: correct answer & explanation revealed immediately upon selecting an option.
  immediate;

  bool get isImmediate => this == AssessmentFeedbackMode.immediate;
  bool get isAfterSubmit => this == AssessmentFeedbackMode.afterSubmit;
}

/// Logical Assessment entity.
@immutable
class Assessment {
  final String id;
  final String code;
  final String title;
  final String? description;
  final AssessmentType assessmentType;
  final String? currentVersionId;
  final String? subjectId;
  final int? grade;
  final String? stream;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AssessmentVersion? currentVersion;

  const Assessment({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.assessmentType = AssessmentType.unit,
    this.currentVersionId,
    this.subjectId,
    this.grade,
    this.stream,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.currentVersion,
  });

  factory Assessment.fromMap(Map<String, dynamic> map) {
    AssessmentVersion? version;
    if (map['current_version'] != null &&
        map['current_version'] is Map<String, dynamic>) {
      version = AssessmentVersion.fromMap(
        map['current_version'] as Map<String, dynamic>,
      );
    }

    return Assessment(
      id: map['id'] as String,
      code: map['code'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      assessmentType: AssessmentType.fromString(
        map['assessment_type'] as String? ?? 'unit',
      ),
      currentVersionId: map['current_version_id'] as String?,
      subjectId: map['subject_id'] as String?,
      grade: map['grade'] as int?,
      stream: map['stream'] as String?,
      isArchived: map['is_archived'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
      currentVersion: version,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'assessment_type': assessmentType.toDbString(),
      'current_version_id': currentVersionId,
      'subject_id': subjectId,
      'grade': grade,
      'stream': stream,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Immutable Assessment Version snapshot.
@immutable
class AssessmentVersion {
  final String id;
  final String assessmentId;
  final int versionNumber;
  final String status; // 'draft', 'published', 'archived'
  final int totalQuestions;
  final double totalPoints;
  final int? timeLimitMinutes;
  final double? passingPercentage;
  final DateTime? publishedAt;
  final List<String> coveredChapterIds;
  final List<Question> questions;

  const AssessmentVersion({
    required this.id,
    required this.assessmentId,
    required this.versionNumber,
    required this.status,
    required this.totalQuestions,
    required this.totalPoints,
    this.timeLimitMinutes,
    this.passingPercentage,
    this.publishedAt,
    this.coveredChapterIds = const [],
    this.questions = const [],
  });

  factory AssessmentVersion.fromMap(Map<String, dynamic> map) {
    List<String> chapters = [];
    if (map['chapters'] != null && map['chapters'] is List) {
      chapters = (map['chapters'] as List)
          .map((c) => (c as Map<String, dynamic>)['chapter_id'] as String)
          .toList();
    }

    List<Question> questionList = [];
    if (map['questions'] != null && map['questions'] is List) {
      questionList = (map['questions'] as List)
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList();
      questionList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return AssessmentVersion(
      id: map['id'] as String,
      assessmentId: map['assessment_id'] as String? ?? '',
      versionNumber: map['version_number'] as int? ?? 1,
      status: map['status'] as String? ?? 'published',
      totalQuestions: map['total_questions'] as int? ?? questionList.length,
      totalPoints: (map['total_points'] as num?)?.toDouble() ?? 0.0,
      timeLimitMinutes: map['time_limit_minutes'] as int?,
      passingPercentage: (map['passing_percentage'] as num?)?.toDouble(),
      publishedAt: map['published_at'] != null
          ? DateTime.tryParse(map['published_at'] as String)
          : null,
      coveredChapterIds: chapters,
      questions: questionList,
    );
  }
}

/// Sanitized Public Question (No correct option or explanation).
@immutable
class Question {
  final String id;
  final String assessmentVersionId;
  final String chapterId;
  final String? code;
  final String? difficulty;
  final String questionText;
  final String questionType;
  final String? imageUrl;
  final double points;
  final int sortOrder;
  final List<QuestionOption> options;

  const Question({
    required this.id,
    required this.assessmentVersionId,
    required this.chapterId,
    this.code,
    this.difficulty,
    required this.questionText,
    this.questionType = 'single_choice',
    this.imageUrl,
    this.points = 1.0,
    required this.sortOrder,
    this.options = const [],
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    List<QuestionOption> optionsList = [];
    if (map['question_options'] != null && map['question_options'] is List) {
      optionsList = (map['question_options'] as List)
          .map((opt) => QuestionOption.fromMap(opt as Map<String, dynamic>))
          .toList();
      optionsList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return Question(
      id: map['id'] as String,
      assessmentVersionId: map['assessment_version_id'] as String? ?? '',
      chapterId: map['chapter_id'] as String? ?? '',
      code: map['code'] as String?,
      difficulty: map['difficulty'] as String?,
      questionText: map['question_text'] as String,
      questionType: map['question_type'] as String? ?? 'single_choice',
      imageUrl: map['image_url'] as String?,
      points: (map['points'] as num?)?.toDouble() ?? 1.0,
      sortOrder: map['sort_order'] as int? ?? 0,
      options: optionsList,
    );
  }
}

/// Sanitized Option Choice (A, B, C, D).
@immutable
class QuestionOption {
  final String id;
  final String questionId;
  final String optionLetter;
  final String optionText;
  final String? imageUrl;
  final int sortOrder;

  const QuestionOption({
    required this.id,
    required this.questionId,
    required this.optionLetter,
    required this.optionText,
    this.imageUrl,
    required this.sortOrder,
  });

  factory QuestionOption.fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      id: map['id'] as String,
      questionId: map['question_id'] as String? ?? '',
      optionLetter: map['option_letter'] as String,
      optionText: map['option_text'] as String,
      imageUrl: map['image_url'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}

/// Student's Selected Answer during live test.
@immutable
class SelectedAnswerSubmission {
  final String questionId;
  final String? selectedOptionId;

  const SelectedAnswerSubmission({
    required this.questionId,
    this.selectedOptionId,
  });

  Map<String, dynamic> toMap() {
    return {'question_id': questionId, 'selected_option_id': selectedOptionId};
  }
}

/// Result returned from starting an online assessment attempt.
@immutable
class AssessmentAttemptCreationResult {
  final String status; // 'created' or 'existing'
  final String attemptId;
  final String assessmentVersionId;
  final DateTime serverStartedAt;
  final int? timeLimitMinutes;
  final int totalQuestions;

  const AssessmentAttemptCreationResult({
    required this.status,
    required this.attemptId,
    required this.assessmentVersionId,
    required this.serverStartedAt,
    this.timeLimitMinutes,
    required this.totalQuestions,
  });

  factory AssessmentAttemptCreationResult.fromMap(Map<String, dynamic> map) {
    return AssessmentAttemptCreationResult(
      status: map['status'] as String? ?? 'created',
      attemptId: map['attempt_id'] as String,
      assessmentVersionId: map['assessment_version_id'] as String,
      serverStartedAt:
          DateTime.tryParse(map['server_started_at'] as String? ?? '') ??
          DateTime.now(),
      timeLimitMinutes: map['time_limit_minutes'] as int?,
      totalQuestions: map['total_questions'] as int? ?? 0,
    );
  }
}

/// Pedagogical Explanation & Correction for a question after submission.
@immutable
class QuestionCorrection {
  final String questionId;
  final String? selectedOptionId;
  final String correctOptionId;
  final bool isCorrect;
  final double pointsAwarded;
  final String explanation;

  const QuestionCorrection({
    required this.questionId,
    this.selectedOptionId,
    required this.correctOptionId,
    required this.isCorrect,
    required this.pointsAwarded,
    required this.explanation,
  });

  factory QuestionCorrection.fromMap(Map<String, dynamic> map) {
    return QuestionCorrection(
      questionId: map['question_id'] as String,
      selectedOptionId: map['selected_option_id'] as String?,
      correctOptionId: map['correct_option_id'] as String,
      isCorrect: map['is_correct'] as bool? ?? false,
      pointsAwarded: (map['points_awarded'] as num?)?.toDouble() ?? 0.0,
      explanation: map['explanation'] as String? ?? '',
    );
  }
}

/// Graded outcome returned after atomic submission.
@immutable
class AssessmentSubmissionResult {
  final String status; // 'success' or 'already_submitted'
  final String attemptId;
  final int totalQuestions;
  final int answeredQuestions;
  final int correctAnswers;
  final double scoreObtained;
  final double maxScore;
  final double percentage;
  final bool? passed;
  final bool isOverdue;
  final bool timingVerified;
  final int? durationSeconds;
  final List<QuestionCorrection> corrections;

  const AssessmentSubmissionResult({
    required this.status,
    required this.attemptId,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.scoreObtained,
    required this.maxScore,
    required this.percentage,
    this.passed,
    this.isOverdue = false,
    this.timingVerified = true,
    this.durationSeconds,
    this.corrections = const [],
  });

  factory AssessmentSubmissionResult.fromMap(Map<String, dynamic> map) {
    List<QuestionCorrection> correctionList = [];
    if (map['corrections'] != null && map['corrections'] is List) {
      correctionList = (map['corrections'] as List)
          .map((c) => QuestionCorrection.fromMap(c as Map<String, dynamic>))
          .toList();
    }

    return AssessmentSubmissionResult(
      status: map['status'] as String? ?? 'success',
      attemptId: map['attempt_id'] as String,
      totalQuestions: map['total_questions'] as int? ?? 0,
      answeredQuestions: map['answered_questions'] as int? ?? 0,
      correctAnswers: map['correct_answers'] as int? ?? 0,
      scoreObtained: (map['score_obtained'] as num?)?.toDouble() ?? 0.0,
      maxScore: (map['max_score'] as num?)?.toDouble() ?? 0.0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      passed: map['passed'] as bool?,
      isOverdue: map['is_overdue'] as bool? ?? false,
      timingVerified: map['timing_verified'] as bool? ?? true,
      durationSeconds: map['duration_seconds'] as int?,
      corrections: correctionList,
    );
  }
}
