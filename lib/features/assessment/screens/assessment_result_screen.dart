import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_badge.dart';
import '../../../core/widgets/acedex_header_bar.dart';
import '../models/assessment_models.dart';
import '../providers/assessment_providers.dart';
import 'assessment_player_screen.dart';

class AssessmentResultScreen extends ConsumerWidget {
  const AssessmentResultScreen({
    super.key,
    required this.result,
    this.assessment,
    this.version,
  });

  final AssessmentSubmissionResult result;
  final Assessment? assessment;
  final AssessmentVersion? version;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isPassed = result.passed ?? (result.percentage >= 60.0);
    final statusColor = isPassed ? colors.success : colors.danger;
    final incorrectCount = result.answeredQuestions - result.correctAnswers;
    final skippedCount = result.totalQuestions - result.answeredQuestions;

    // Build question map for easy correction lookup
    final Map<String, Question> questionMap = {
      for (final q in (version?.questions ?? [])) q.id: q,
    };

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AcedexFloatingHeaderBar(
        title: 'Assessment Results',
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: colors.textPrimary,
            size: 22,
          ),
          onPressed: () {
            ref.read(assessmentPlayControllerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.all(AppTheme.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Score Card
                    Container(
                      padding: const EdgeInsets.all(AppTheme.space24),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: colors.border, width: 1.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.statusTint(statusColor),
                              border: Border.all(
                                color: colors.statusBorder(statusColor),
                                width: 2.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${result.percentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                                Text(
                                  'Score',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.space16),
                          Text(
                            isPassed
                                ? 'Assessment Passed'
                                : 'Review Required',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.space4),
                          Text(
                            'Earned ${result.scoreObtained.toStringAsFixed(1)} out of ${result.maxScore.toStringAsFixed(1)} points',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.space12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AcedexBadge(
                                label: result.timingVerified
                                    ? 'Verified Server Clock'
                                    : 'Offline Attempt',
                                color: result.timingVerified
                                    ? colors.primary
                                    : colors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.space16),

                    // Metrics Breakdown
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultMetric(
                            colors,
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            label: 'Correct',
                            value: '${result.correctAnswers}',
                            color: colors.success,
                          ),
                        ),
                        const SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: _buildResultMetric(
                            colors,
                            icon: HugeIcons.strokeRoundedCancelCircle,
                            label: 'Incorrect',
                            value: '$incorrectCount',
                            color: colors.danger,
                          ),
                        ),
                        const SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: _buildResultMetric(
                            colors,
                            icon: HugeIcons.strokeRoundedHelpCircle,
                            label: 'Skipped',
                            value: '$skippedCount',
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.space24),

                    // Section Title
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBookOpen01,
                          color: colors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.space8),
                        Text(
                          'Pedagogical Review & Explanations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.space12),

                    // Corrections List
                    ...result.corrections.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final c = entry.value;
                      final q = questionMap[c.questionId];

                      // Option lookups
                      final options = q?.options ?? [];
                      final selectedOpt = options
                          .where((o) => o.id == c.selectedOptionId)
                          .firstOrNull;
                      final correctOpt = options
                          .where((o) => o.id == c.correctOptionId)
                          .firstOrNull;

                      final itemColor =
                          c.isCorrect ? colors.success : colors.danger;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(AppTheme.space16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(
                            color: colors.border,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                AcedexBadge(
                                  label: 'Question ${idx + 1}',
                                  color: c.isCorrect
                                      ? colors.success
                                      : colors.danger,
                                ),
                                Text(
                                  c.isCorrect
                                      ? '+${c.pointsAwarded.toStringAsFixed(1)} pts'
                                      : '0.0 pts',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: itemColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.space12),
                            Text(
                              q?.questionText ?? 'Question',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppTheme.space12),

                            // Student Selection
                            if (selectedOpt != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.statusTint(itemColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    HugeIcon(
                                      icon: c.isCorrect
                                          ? HugeIcons.strokeRoundedCheckmarkCircle02
                                          : HugeIcons.strokeRoundedCancelCircle,
                                      color: itemColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Your choice: ${selectedOpt.optionLetter}. ${selectedOpt.optionText}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: itemColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Skipped (No answer selected)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Correct Answer Indicator if user was wrong
                            if (!c.isCorrect && correctOpt != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.statusTint(colors.success),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                      color: colors.success,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Correct answer: ${correctOpt.optionLetter}. ${correctOpt.optionText}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: colors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Pedagogical Explanation
                            if (c.explanation.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(AppTheme.space12),
                                decoration: BoxDecoration(
                                  color: colors.primarySoft.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: colors.primary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedBulb,
                                      color: colors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        c.explanation,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.textPrimary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: colors.border, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  if (assessment != null) ...[
                    Expanded(
                      child: AcedexButton(
                        label: 'Retake Test',
                        variant: AcedexButtonVariant.secondary,
                        leading: HugeIcon(
                          icon: HugeIcons.strokeRoundedRefresh,
                          color: colors.primary,
                          size: 18,
                        ),
                        onPressed: () async {
                          final success = await ref
                              .read(assessmentPlayControllerProvider.notifier)
                              .startAssessment(assessment!);
                          if (context.mounted && success) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const AssessmentPlayerScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                  ],
                  Expanded(
                    child: AcedexButton(
                      label: 'Done',
                      onPressed: () {
                        ref
                            .read(assessmentPlayControllerProvider.notifier)
                            .reset();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultMetric(
    AppColors colors, {
    required List<List<dynamic>> icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1.0),
      ),
      child: Column(
        children: [
          HugeIcon(icon: icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
