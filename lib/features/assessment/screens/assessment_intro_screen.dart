import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_header_bar.dart';
import '../../../core/widgets/acedex_badge.dart';
import '../models/assessment_models.dart';
import '../providers/assessment_providers.dart';
import 'assessment_player_screen.dart';

class AssessmentIntroScreen extends ConsumerStatefulWidget {
  const AssessmentIntroScreen({
    super.key,
    required this.chapterId,
    required this.unitTitle,
    required this.subjectName,
  });

  final String chapterId;
  final String unitTitle;
  final String subjectName;

  @override
  ConsumerState<AssessmentIntroScreen> createState() =>
      _AssessmentIntroScreenState();
}

class _AssessmentIntroScreenState
    extends ConsumerState<AssessmentIntroScreen> {
  AssessmentFeedbackMode _feedbackMode = AssessmentFeedbackMode.afterSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final assessmentAsync =
        ref.watch(currentChapterAssessmentProvider(widget.chapterId));

    return Scaffold(
      appBar: AcedexFloatingHeaderBar(
        title: 'Unit Assessment',
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.textPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: assessmentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        error: (err, stack) => _buildErrorOrEmptyState(context, ref, null),
        data: (assessment) {
          if (assessment == null || assessment.currentVersion == null) {
            return _buildErrorOrEmptyState(context, ref, assessment);
          }
          return _buildAssessmentContent(context, ref, assessment);
        },
      ),
    );
  }

  Widget _buildAssessmentContent(
    BuildContext context,
    WidgetRef ref,
    Assessment assessment,
  ) {
    final colors = context.appColors;
    final version = assessment.currentVersion!;
    final totalQuestions = version.questions.length;
    final limitMins = version.timeLimitMinutes ?? 0;
    final timeLimit = limitMins > 0 ? '$limitMins min' : 'Untimed';
    final passingPercentage =
        '${(version.passingPercentage ?? 60.0).toStringAsFixed(0)}%';

    return SafeArea(
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
                  // Unit & Assessment Title Banner
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: colors.border, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AcedexBadge(
                              label: widget.subjectName,
                              color: colors.primary,
                            ),
                            const SizedBox(width: AppTheme.space8),
                            AcedexBadge(
                              label: 'Unit Test',
                              color: colors.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space12),
                        Text(
                          assessment.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (assessment.description != null &&
                            assessment.description!.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.space8),
                          Text(
                            assessment.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.space16),

                  // 4-Pill Metric Summary
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          colors,
                          icon: HugeIcons.strokeRoundedHelpCircle,
                          label: 'Questions',
                          value: '$totalQuestions items',
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: _buildMetricTile(
                          colors,
                          icon: HugeIcons.strokeRoundedClock01,
                          label: 'Time Limit',
                          value: timeLimit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          colors,
                          icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                          label: 'Pass Mark',
                          value: passingPercentage,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: _buildMetricTile(
                          colors,
                          icon: HugeIcons.strokeRoundedTask01,
                          label: 'Format',
                          value: 'Multiple Choice',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.space20),

                  // Feedback & Answer Reveal Mode Selector Card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: colors.border, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedSlidersHorizontal,
                              color: colors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.space8),
                            Text(
                              'Answer Reveal Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space4),
                        Text(
                          'Choose whether to see solutions immediately or after test submission.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.space16),

                        // Mode 1: After Submit (Exam Mode)
                        _buildFeedbackModeTile(
                          colors: colors,
                          mode: AssessmentFeedbackMode.afterSubmit,
                          title: 'See Answers After Submit',
                          badge: 'Exam Mode',
                          description:
                              'Answers and explanations stay private until you submit the test.',
                          icon: HugeIcons.strokeRoundedAward01,
                        ),

                        const SizedBox(height: AppTheme.space12),

                        // Mode 2: Immediate (Practice Mode)
                        _buildFeedbackModeTile(
                          colors: colors,
                          mode: AssessmentFeedbackMode.immediate,
                          title: 'See Answers Immediately',
                          badge: 'Practice Mode',
                          description:
                              'Instant feedback: see if you are correct and read explanations right after each question.',
                          icon: HugeIcons.strokeRoundedBulb,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.space20),

                  // Assessment Rules / Instructions Card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: colors.border, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedInformationCircle,
                              color: colors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.space8),
                            Text(
                              'Test Rules & Guidelines',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space16),
                        _buildInstructionRow(
                          colors,
                          number: '1',
                          text: 'Instant selection: tap any option to record your answer instantly.',
                        ),
                        const SizedBox(height: AppTheme.space12),
                        _buildInstructionRow(
                          colors,
                          number: '2',
                          text: 'Review & jump: navigate freely between questions at any time.',
                        ),
                        const SizedBox(height: AppTheme.space12),
                        _buildInstructionRow(
                          colors,
                          number: '3',
                          text: _feedbackMode == AssessmentFeedbackMode.immediate
                              ? 'Instant learning: correct answers and explanations appear immediately upon tapping each option.'
                              : 'Secure grading: solutions and explanations are unlocked upon final submission.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Fixed Start Button
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.border, width: 1.0)),
            ),
            child: AcedexButton(
              label: 'Start Assessment',
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedPlay,
                color: colors.onPrimary,
                size: 20,
              ),
              onPressed: () async {
                final success = await ref
                    .read(assessmentPlayControllerProvider.notifier)
                    .startAssessment(assessment, feedbackMode: _feedbackMode);

                if (context.mounted && success) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AssessmentPlayerScreen(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackModeTile({
    required AppColors colors,
    required AssessmentFeedbackMode mode,
    required String title,
    required String badge,
    required String description,
    required List<List<dynamic>> icon,
  }) {
    final isSelected = _feedbackMode == mode;

    return InkWell(
      onTap: () => setState(() => _feedbackMode = mode),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(AppTheme.space12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primarySoft
              : colors.surfaceAlt.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: HugeIcon(
                icon: icon,
                color: isSelected ? colors.onPrimary : colors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      AcedexBadge(
                        label: badge,
                        color:
                            isSelected ? colors.primary : colors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                      height: 1.3,
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

  Widget _buildMetricTile(
    AppColors colors, {
    required List<List<dynamic>> icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: colors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: icon, color: colors.primary, size: 22),
          const SizedBox(height: AppTheme.space8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(
    AppColors colors, {
    required String number,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.space12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrEmptyState(
    BuildContext context,
    WidgetRef ref,
    Assessment? assessment,
  ) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  color: colors.primary,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'Assessment Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              'Questions for ${widget.unitTitle} are currently being reviewed by curriculum curators.',
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space24),
            Row(
              children: [
                Expanded(
                  child: AcedexButton(
                    label: 'Return',
                    variant: AcedexButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: AcedexButton(
                    label: 'Check Again',
                    variant: AcedexButtonVariant.primary,
                    onPressed: () {
                      ref.invalidate(currentChapterAssessmentProvider(widget.chapterId));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
