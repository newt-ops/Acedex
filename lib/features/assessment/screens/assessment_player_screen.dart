import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/acedex_button.dart';
import '../../../core/widgets/acedex_dialog.dart';
import '../../../core/widgets/acedex_badge.dart';
import '../models/assessment_models.dart';
import '../providers/assessment_providers.dart';
import 'assessment_result_screen.dart';

class AssessmentPlayerScreen extends ConsumerStatefulWidget {
  const AssessmentPlayerScreen({super.key});

  @override
  ConsumerState<AssessmentPlayerScreen> createState() =>
      _AssessmentPlayerScreenState();
}

class _AssessmentPlayerScreenState
    extends ConsumerState<AssessmentPlayerScreen> {
  late final PageController _pageController;
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    final playState = ref.read(assessmentPlayControllerProvider);
    _pageController = PageController(
      initialPage: playState.currentQuestionIndex,
    );

    final timeLimitMinutes = playState.version?.timeLimitMinutes ?? 0;
    if (timeLimitMinutes > 0) {
      _secondsRemaining = timeLimitMinutes * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          _handleAutoSubmit();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleAutoSubmit() {
    if (!mounted) return;
    _submitAssessment(isAutoSubmit: true);
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitAssessment({bool isAutoSubmit = false}) async {
    final controller = ref.read(assessmentPlayControllerProvider.notifier);
    final success = await controller.submit();

    if (!mounted) return;

    if (success) {
      final updatedState = ref.read(assessmentPlayControllerProvider);
      if (updatedState.result != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AssessmentResultScreen(
              result: updatedState.result!,
              assessment: updatedState.assessment,
              version: updatedState.version,
            ),
          ),
        );
      }
    }
  }

  void _showSubmissionConfirmation() {
    final playState = ref.read(assessmentPlayControllerProvider);
    final total = playState.totalQuestions;
    final answered = playState.answeredCount;
    final unanswered = total - answered;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = context.appColors;
        return Container(
          padding: const EdgeInsets.all(AppTheme.space24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.space20),
                Text(
                  'Submit Assessment?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space12),
                Text(
                  unanswered > 0
                      ? 'You have answered $answered of $total questions. There are $unanswered questions left unanswered.'
                      : 'You have answered all $total questions! Ready to grade your test?',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space24),
                Row(
                  children: [
                    Expanded(
                      child: AcedexButton(
                        label: 'Keep Answering',
                        variant: AcedexButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: AcedexButton(
                        label: 'Submit Now',
                        variant: AcedexButtonVariant.primary,
                        onPressed: () {
                          Navigator.of(context).pop();
                          _submitAssessment();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuestionJumperSheet(AssessmentPlayState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final colors = context.appColors;
        final questions = state.version?.questions ?? [];

        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          padding: const EdgeInsets.all(AppTheme.space20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question Navigator',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      final isAnswered = state.selectedAnswers.containsKey(
                        q.id,
                      );
                      final isCurrent = index == state.currentQuestionIndex;
                      final isImmediate =
                          state.feedbackMode ==
                          AssessmentFeedbackMode.immediate;
                      final solution = isImmediate
                          ? state.instantSolutions[q.id]
                          : null;
                      final selectedOptId = state.selectedAnswers[q.id];

                      Color bg = colors.surface;
                      Color textCol = colors.textPrimary;
                      Border border = Border.all(color: colors.border);

                      if (isAnswered) {
                        if (isImmediate && solution != null) {
                          final selectedOpt = q.options
                              .where((o) => o.id == selectedOptId)
                              .firstOrNull;
                          final isCorrect =
                              selectedOpt != null &&
                              selectedOpt.optionLetter ==
                                  solution.correctOptionLetter;
                          if (isCorrect) {
                            bg = colors.statusTint(colors.success);
                            textCol = colors.success;
                            border = Border.all(color: colors.success);
                          } else {
                            bg = colors.statusTint(colors.danger);
                            textCol = colors.danger;
                            border = Border.all(color: colors.danger);
                          }
                        } else {
                          bg = colors.primarySoft;
                          textCol = colors.primary;
                          border = Border.all(color: colors.primary);
                        }
                      }

                      if (isCurrent) {
                        border = Border.all(color: colors.primary, width: 2.0);
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pageController.jumpToPage(index);
                          ref
                              .read(assessmentPlayControllerProvider.notifier)
                              .jumpToQuestion(index);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                            border: border,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: textCol,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final playState = ref.watch(assessmentPlayControllerProvider);
    final questions = playState.version?.questions ?? [];
    final total = playState.totalQuestions;
    final currentIndex = playState.currentQuestionIndex;

    if (playState.status == AssessmentPlayStatus.submitting) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
              const SizedBox(height: AppTheme.space20),
              Text(
                'Grading Assessment...',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'Verifying answers server-side',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: colors.textPrimary,
            size: 22,
          ),
          onPressed: () async {
            final confirm = await AcedexDialog.showConfirmation(
              context,
              title: 'Quit Assessment?',
              message:
                  'Your answer selections will be saved locally so you can resume later.',
              confirmLabel: 'Quit',
              cancelLabel: 'Stay',
              isDestructive: true,
            );
            if (confirm == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playState.assessment?.title ?? 'Assessment',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              playState.feedbackMode == AssessmentFeedbackMode.immediate
                  ? 'Practice Mode • Instant Feedback'
                  : 'Exam Mode • Graded at End',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color:
                    playState.feedbackMode == AssessmentFeedbackMode.immediate
                    ? colors.secondary
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (_secondsRemaining > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    color: colors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_secondsRemaining),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedLayoutGrid,
              color: colors.textPrimary,
              size: 22,
            ),
            onPressed: () => _showQuestionJumperSheet(playState),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: total > 0 ? (currentIndex + 1) / total : 0.0,
            backgroundColor: colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Question Pager
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  ref
                      .read(assessmentPlayControllerProvider.notifier)
                      .jumpToQuestion(index);
                },
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final selectedOptionId = playState.selectedAnswers[q.id];

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Header Card
                        Container(
                          padding: const EdgeInsets.all(AppTheme.space16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusCard,
                            ),
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
                                    label: 'Question ${index + 1} of $total',
                                    color: colors.primary,
                                  ),
                                  AcedexBadge(
                                    label: '${q.points} pt',
                                    color: colors.secondary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.space16),
                              Text(
                                q.questionText,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                  height: 1.45,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppTheme.space16),

                        // Options List (Tactile 0ms Tap Targets)
                        ...q.options.map((option) {
                          final isSelected = selectedOptionId == option.id;
                          final isImmediate =
                              playState.feedbackMode ==
                              AssessmentFeedbackMode.immediate;
                          final hasAnswered = selectedOptionId != null;
                          final solution = isImmediate
                              ? playState.instantSolutions[q.id]
                              : null;

                          final isCorrectOption =
                              solution != null &&
                              (option.optionLetter ==
                                      solution.correctOptionLetter ||
                                  option.id == solution.correctOptionLetter);

                          Color tileBg;
                          Color tileBorderColor;
                          double tileBorderWidth;
                          Color badgeBg;
                          Color badgeTextColor;
                          Widget? badgeIcon;

                          if (isImmediate && hasAnswered) {
                            if (isCorrectOption) {
                              tileBg = colors.statusTint(colors.success);
                              tileBorderColor = colors.success;
                              tileBorderWidth = 1.8;
                              badgeBg = colors.success;
                              badgeTextColor = colors.onPrimary;
                              badgeIcon = HugeIcon(
                                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                                color: colors.onPrimary,
                                size: 16,
                              );
                            } else if (isSelected && !isCorrectOption) {
                              tileBg = colors.statusTint(colors.danger);
                              tileBorderColor = colors.danger;
                              tileBorderWidth = 1.8;
                              badgeBg = colors.danger;
                              badgeTextColor = colors.onDanger;
                              badgeIcon = HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                color: colors.onDanger,
                                size: 16,
                              );
                            } else {
                              tileBg = colors.surface.withValues(alpha: 0.5);
                              tileBorderColor = colors.border.withValues(
                                alpha: 0.6,
                              );
                              tileBorderWidth = 1.0;
                              badgeBg = colors.surfaceAlt;
                              badgeTextColor = colors.textSecondary;
                            }
                          } else {
                            tileBg = isSelected
                                ? colors.primarySoft
                                : colors.surface;
                            tileBorderColor = isSelected
                                ? colors.primary
                                : colors.border;
                            tileBorderWidth = isSelected ? 1.8 : 1.0;
                            badgeBg = isSelected
                                ? colors.primary
                                : colors.surfaceAlt;
                            badgeTextColor = isSelected
                                ? colors.onPrimary
                                : colors.textPrimary;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  ref
                                      .read(
                                        assessmentPlayControllerProvider
                                            .notifier,
                                      )
                                      .selectOption(q.id, option.id);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.space16,
                                    vertical: AppTheme.space16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tileBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: tileBorderColor,
                                      width: tileBorderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: badgeBg,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child:
                                            badgeIcon ??
                                            Text(
                                              option.optionLetter,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: badgeTextColor,
                                              ),
                                            ),
                                      ),
                                      const SizedBox(width: AppTheme.space16),
                                      Expanded(
                                        child: Text(
                                          option.optionText,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: colors.textPrimary,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // In Practice / Instant feedback mode: reveal explanation once selected
                        if (playState.feedbackMode ==
                                AssessmentFeedbackMode.immediate &&
                            selectedOptionId != null) ...[
                          Builder(
                            builder: (context) {
                              final solution = playState.instantSolutions[q.id];
                              final selectedOpt = q.options
                                  .where((o) => o.id == selectedOptionId)
                                  .firstOrNull;
                              final isCorrect =
                                  selectedOpt != null &&
                                  solution != null &&
                                  selectedOpt.optionLetter ==
                                      solution.correctOptionLetter;

                              return Container(
                                margin: const EdgeInsets.only(
                                  top: 6.0,
                                  bottom: 16.0,
                                ),
                                padding: const EdgeInsets.all(AppTheme.space16),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusCard,
                                  ),
                                  border: Border.all(
                                    color: isCorrect
                                        ? colors.statusBorder(colors.success)
                                        : colors.statusBorder(colors.danger),
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        HugeIcon(
                                          icon: isCorrect
                                              ? HugeIcons
                                                    .strokeRoundedCheckmarkCircle02
                                              : HugeIcons.strokeRoundedCancel01,
                                          color: isCorrect
                                              ? colors.success
                                              : colors.danger,
                                          size: 20,
                                        ),
                                        const SizedBox(width: AppTheme.space8),
                                        Text(
                                          isCorrect
                                              ? 'Correct Answer!'
                                              : 'Incorrect',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isCorrect
                                                ? colors.success
                                                : colors.danger,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (solution != null)
                                          AcedexBadge(
                                            label:
                                                'Option ${solution.correctOptionLetter}',
                                            color: colors.success,
                                          ),
                                      ],
                                    ),
                                    if (solution != null &&
                                        solution.explanation.isNotEmpty) ...[
                                      const SizedBox(height: AppTheme.space12),
                                      Text(
                                        solution.explanation,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colors.textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Footer
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
                  if (currentIndex > 0) ...[
                    Expanded(
                      flex: 2,
                      child: AcedexButton(
                        label: 'Previous',
                        variant: AcedexButtonVariant.secondary,
                        leading: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: colors.primary,
                          size: 18,
                        ),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                  ],
                  Expanded(
                    flex: currentIndex > 0 ? 3 : 1,
                    child: currentIndex == total - 1
                        ? AcedexButton(
                            label: 'Review & Submit',
                            trailing: HugeIcon(
                              icon: HugeIcons.strokeRoundedTick02,
                              color: colors.onPrimary,
                              size: 18,
                            ),
                            onPressed: _showSubmissionConfirmation,
                          )
                        : AcedexButton(
                            label: 'Next Question',
                            trailing: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              color: colors.onPrimary,
                              size: 18,
                            ),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeInOutCubic,
                              );
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
}
