import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/dashboard_data.dart';

/// 3-Question EUEE Mini-Drill Cupertino Bottom Sheet
///
/// Features:
/// - 3-Step Mini Progress Bar
/// - Options A, B, C, D with instant green/red validation and explanation card
/// - "Next Question" & "Finish Drill" CTAs
/// - Final Drill Summary Screen displaying score and mastery boost (+2%)
class MiniDrillSheet extends StatefulWidget {
  final SubjectMasteryItem subject;
  final void Function(String subjectId, int newMastery) onMasteryUpdated;

  const MiniDrillSheet({
    super.key,
    required this.subject,
    required this.onMasteryUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required SubjectMasteryItem subject,
    required void Function(String subjectId, int newMastery) onMasteryUpdated,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (context) => MiniDrillSheet(
        subject: subject,
        onMasteryUpdated: onMasteryUpdated,
      ),
    );
  }

  @override
  State<MiniDrillSheet> createState() => _MiniDrillSheetState();
}

class _MiniDrillSheetState extends State<MiniDrillSheet> {
  int _stepIndex = 0; // 0, 1, 2
  int _correctCount = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _isFinished = false;

  late int _updatedMastery;

  @override
  void initState() {
    super.initState();
    _updatedMastery = widget.subject.mastery;
  }

  void _handleOptionSelect(int index) {
    if (_isAnswered) return;

    final q = widget.subject.questions[_stepIndex];
    final isCorrect = (index == q.correctIndex);

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _correctCount += 1;
      }
    });
  }

  void _handleNextQuestion() {
    if (_stepIndex < 2) {
      setState(() {
        _stepIndex += 1;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      // Finished all 3 questions
      final boost = _correctCount > 0 ? _correctCount : 1;
      _updatedMastery = (_updatedMastery + boost).clamp(0, 99);
      widget.onMasteryUpdated(widget.subject.id, _updatedMastery);

      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final lineBorder = isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141418) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 36,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 320),
        crossFadeState: _isFinished ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: _buildDrillActiveBody(
          theme: theme,
          primaryColor: primaryColor,
          surfaceColor: surfaceColor,
          lineBorder: lineBorder,
          subtextColor: subtextColor,
          isDark: isDark,
        ),
        secondChild: _buildSummaryBody(
          theme: theme,
          primaryColor: primaryColor,
          subtextColor: subtextColor,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildDrillActiveBody({
    required ThemeData theme,
    required Color primaryColor,
    required Color surfaceColor,
    required Color lineBorder,
    required Color subtextColor,
    required bool isDark,
  }) {
    final q = widget.subject.questions[_stepIndex];
    final letters = ['A', 'B', 'C', 'D'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag Grabber Pill
        Center(
          child: Container(
            width: 36,
            height: 4.5,
            decoration: BoxDecoration(
              color: lineBorder,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Header Row: Subject Badge + Step Pill + Close Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${widget.subject.name.toUpperCase()} • EUEE DRILL',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: lineBorder),
                      ),
                      child: Text(
                        '${_stepIndex + 1} of 3',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: subtextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  q.topic,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            AcedexBounceable(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: lineBorder),
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: subtextColor,
                  size: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 3-Step Progress Bar
        Row(
          children: List.generate(3, (i) {
            final isCurrentOrDone = i <= _stepIndex;
            return Expanded(
              child: Container(
                height: 4.5,
                margin: EdgeInsets.only(right: i < 2 ? 6.0 : 0.0),
                decoration: BoxDecoration(
                  color: isCurrentOrDone ? primaryColor : lineBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 14),

        // Question Prompt Text
        Text(
          q.q,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.35,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        // Options A, B, C, D
        ...List.generate(q.options.length, (optIdx) {
          final optText = q.options[optIdx];
          final isSelected = _selectedOptionIndex == optIdx;
          final isCorrect = (optIdx == q.correctIndex);

          Color optBg = surfaceColor;
          Color optBorder = lineBorder;

          if (_isAnswered) {
            if (isCorrect) {
              optBg = (isDark ? AppColors.darkSuccess : AppColors.success).withValues(alpha: 0.16);
              optBorder = isDark ? AppColors.darkSuccess : AppColors.success;
            } else if (isSelected) {
              optBg = (isDark ? AppColors.darkError : AppColors.error).withValues(alpha: 0.16);
              optBorder = isDark ? AppColors.darkError : AppColors.error;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: AcedexBounceable(
              onTap: () => _handleOptionSelect(optIdx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: optBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: optBorder, width: isSelected ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letters[optIdx],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        optText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Explanation Box
        if (_isAnswered) ...[
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: lineBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedOptionIndex == q.correctIndex
                      ? 'Correct Answer!'
                      : 'Correct Option: ${letters[q.correctIndex]}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _selectedOptionIndex == q.correctIndex
                        ? (isDark ? AppColors.darkSuccess : AppColors.success)
                        : primaryColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  q.explanation,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Next / Finish Button
          Align(
            alignment: Alignment.centerRight,
            child: AcedexBounceable(
              onTap: _handleNextQuestion,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _stepIndex < 2 ? 'Next Question' : 'Finish Drill',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: Colors.white,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryBody({
    required ThemeData theme,
    required Color primaryColor,
    required Color subtextColor,
    required bool isDark,
  }) {
    final boost = _correctCount > 0 ? _correctCount : 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Grabber Pill
        Center(
          child: Container(
            width: 36,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Big Green Checkmark Icon
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkSuccess : AppColors.success).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
            color: isDark ? AppColors.darkSuccess : AppColors.success,
            size: 28,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          '$_correctCount / 3 Correct!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '${widget.subject.name} mastery updated to $_updatedMastery% (+$boost%)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: subtextColor,
          ),
        ),

        const SizedBox(height: 24),

        // Back to Dashboard Button
        AcedexBounceable(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Back to Dashboard',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
