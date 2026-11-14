import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/assessment_models.dart';

/// Solution summary for a question, used in Practice / Instant Feedback mode
class QuestionSolutionInfo {
  final String questionId;
  final String correctOptionLetter; // 'A', 'B', 'C', 'D'
  final String explanation;

  const QuestionSolutionInfo({
    required this.questionId,
    required this.correctOptionLetter,
    required this.explanation,
  });
}

/// Evaluates student answers locally from bundled curriculum assessment assets
/// when working offline or in local test mode.
class OfflineAssessmentEvaluator {
  const OfflineAssessmentEvaluator._();

  static const Map<String, String> _chapterToAssetMap = {
    'PHYS_G9_U1': 'assets/data/PHY-G09-U01.json',
    'PHYS_G9_U01': 'assets/data/PHY-G09-U01.json',
    'PHY_G09_U01': 'assets/data/PHY-G09-U01.json',
    'PHY-G09-U01': 'assets/data/PHY-G09-U01.json',
    'PHYS_G9_U2': 'assets/data/PHY-G09-U02.json',
    'PHYS_G9_U02': 'assets/data/PHY-G09-U02.json',
    'PHY_G09_U02': 'assets/data/PHY-G09-U02.json',
    'PHY-G09-U02': 'assets/data/PHY-G09-U02.json',
  };

  /// Fetches solutions and explanations map for an assessment version (used in instant feedback mode)
  static Future<Map<String, QuestionSolutionInfo>> getSolutionsMap(
    AssessmentVersion version,
  ) async {
    String? assetPath;
    for (final ch in version.coveredChapterIds) {
      if (_chapterToAssetMap.containsKey(ch)) {
        assetPath = _chapterToAssetMap[ch];
        break;
      }
    }

    if (assetPath == null) return {};

    try {
      final raw = await rootBundle.loadString(assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final questionsList = data['questions'] as List<dynamic>? ?? [];

      final Map<String, QuestionSolutionInfo> solutions = {};
      for (final rawQ in questionsList) {
        final q = rawQ as Map<String, dynamic>;
        final qId = q['id'] as String;
        solutions[qId] = QuestionSolutionInfo(
          questionId: qId,
          correctOptionLetter: q['correctOptionId'] as String? ?? 'A',
          explanation: q['explanation'] as String? ?? '',
        );
      }
      return solutions;
    } catch (_) {
      return {};
    }
  }

  /// Evaluates an attempt using bundled asset solutions
  static Future<AssessmentSubmissionResult?> evaluateFromAsset({
    required AssessmentVersion version,
    required String attemptId,
    required Map<String, String> selectedAnswers,
  }) async {
    // Find asset path from covered chapters
    String? assetPath;
    for (final ch in version.coveredChapterIds) {
      if (_chapterToAssetMap.containsKey(ch)) {
        assetPath = _chapterToAssetMap[ch];
        break;
      }
    }

    if (assetPath == null) return null;

    try {
      final raw = await rootBundle.loadString(assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final questionsList = data['questions'] as List<dynamic>? ?? [];

      final Map<String, dynamic> solutionsMap = {};
      for (final rawQ in questionsList) {
        final q = rawQ as Map<String, dynamic>;
        final qId = q['id'] as String;
        solutionsMap[qId] = {
          'correctOptionId': q['correctOptionId'] as String,
          'explanation': q['explanation'] as String? ?? '',
        };
      }

      int correctCount = 0;
      double totalScore = 0.0;
      final List<QuestionCorrection> corrections = [];

      for (final q in version.questions) {
        final solution = solutionsMap[q.id];
        final selectedOptId = selectedAnswers[q.id];

        // The correct option in the asset is 'A', 'B', 'C', 'D'
        // In Drift/models, option IDs are '${q.id}_OPT_$letter'
        final correctLetter = solution?['correctOptionId'] as String?;
        final correctOpt = q.options.where((o) =>
            o.optionLetter == correctLetter || o.id == correctLetter).firstOrNull;

        final isCorrect = selectedOptId != null &&
            correctOpt != null &&
            (selectedOptId == correctOpt.id ||
                selectedOptId == correctLetter);

        final points = isCorrect ? q.points.toDouble() : 0.0;
        if (isCorrect) {
          correctCount++;
          totalScore += points;
        }

        corrections.add(QuestionCorrection(
          questionId: q.id,
          selectedOptionId: selectedOptId,
          correctOptionId: correctOpt?.id ?? '${q.id}_OPT_$correctLetter',
          isCorrect: isCorrect,
          pointsAwarded: points,
          explanation: solution?['explanation'] as String? ?? '',
        ));
      }

      final totalQuestions = version.questions.length;
      final maxScore = version.totalPoints > 0
          ? version.totalPoints
          : totalQuestions.toDouble();
      final percentage = maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0;
      final passed = percentage >= (version.passingPercentage ?? 60.0);

      return AssessmentSubmissionResult(
        status: 'success',
        attemptId: attemptId,
        totalQuestions: totalQuestions,
        answeredQuestions: selectedAnswers.length,
        correctAnswers: correctCount,
        scoreObtained: totalScore,
        maxScore: maxScore,
        percentage: double.parse(percentage.toStringAsFixed(2)),
        passed: passed,
        isOverdue: false,
        timingVerified: false,
        durationSeconds: null,
        corrections: corrections,
      );
    } catch (_) {
      return null;
    }
  }
}
