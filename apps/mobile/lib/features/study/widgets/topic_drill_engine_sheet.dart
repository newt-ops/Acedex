import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/study_models.dart';

/// Component 6: Topic Drill Engine (Cupertino Bottom Sheet)
///
/// Features dynamic segmented progress bar (3, 5, or 8 segments), step counter,
/// EUEE multiple-choice (A-D) verification with step-by-step explanations, and
/// a completion summary that boosts subject mastery live.
class TopicDrillEngineSheet extends StatefulWidget {
  final List<DrillQuestionItem> questions;
  final String headerBadge;
  final String headerTitle;
  final SubjectCurriculum subject;
  final Function(int score, int total, int boost) onDrillCompleted;
  final void Function(List<Map<String, dynamic>> answers, int durationSeconds)?
      onAssessmentCompletedWithAnswers;

  const TopicDrillEngineSheet({
    super.key,
    required this.questions,
    required this.headerBadge,
    required this.headerTitle,
    required this.subject,
    required this.onDrillCompleted,
    this.onAssessmentCompletedWithAnswers,
  });

  static Future<void> show(
    BuildContext context, {
    required List<DrillQuestionItem> questions,
    required String headerBadge,
    required String headerTitle,
    required SubjectCurriculum subject,
    required Function(int score, int total, int boost) onDrillCompleted,
    void Function(List<Map<String, dynamic>> answers, int durationSeconds)?
        onAssessmentCompletedWithAnswers,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => TopicDrillEngineSheet(
        questions: questions,
        headerBadge: headerBadge,
        headerTitle: headerTitle,
        subject: subject,
        onDrillCompleted: onDrillCompleted,
        onAssessmentCompletedWithAnswers: onAssessmentCompletedWithAnswers,
      ),
    );
  }

  @override
  State<TopicDrillEngineSheet> createState() => _TopicDrillEngineSheetState();
}

class _TopicDrillEngineSheetState extends State<TopicDrillEngineSheet> {
  static const List<String> _optionLetters = ['A', 'B', 'C', 'D'];
  final DateTime _startedAt = DateTime.now();
  final Map<int, String> _selectedOptionByIndex = {};
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  int _score = 0;
  bool _isCompleted = false;
  int _boost = 0;

  void _handleSelectOption(int index) {
    if (_selectedOptionIndex != null) return; // Locked once chosen

    final currentQ = widget.questions[_currentIndex];
    final isRight = index == currentQ.correctIndex;
    if (index >= 0 && index < _optionLetters.length) {
      _selectedOptionByIndex[_currentIndex] = _optionLetters[index];
    }

    setState(() {
      _selectedOptionIndex = index;
      if (isRight) {
        _score += 1;
      }
    });
  }

  void _handleAdvance() {
    final total = widget.questions.length;
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex += 1;
        _selectedOptionIndex = null;
      });
    } else {
      // Calculate mastery boost
      final boost = math.max(1, ((_score / total) * 3).round());
      final elapsedSec = DateTime.now().difference(_startedAt).inSeconds;
      final answers = List.generate(total, (i) {
        return <String, dynamic>{
          'questionId': widget.questions[i].topicCode,
          'selectedOptionId': _selectedOptionByIndex[i],
        };
      });
      setState(() {
        _boost = boost;
        _isCompleted = true;
      });
      widget.onDrillCompleted(_score, total, boost);
      widget.onAssessmentCompletedWithAnswers?.call(
        answers,
        elapsedSec < 1 ? 1 : elapsedSec,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF16161C)
        : const Color(0xFFFFFFFF);
    final cardBg = isDark ? const Color(0xFF1E1E26) : const Color(0xFFF7F7F9);
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft = isDark
        ? accent.withValues(alpha: 0.18)
        : AppColors.royalPurpleSoft;

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.90;
    final total = widget.questions.length;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineColor)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 36,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sheet Grabber Handle
          Container(
            width: 36,
            height: 4.5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          if (!_isCompleted) ...[
            // Header: Badges, Counter, Title, Close, Segmented Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge and counter
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              widget.headerBadge,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: lineColor),
                            ),
                            child: Text(
                              '${_currentIndex + 1} of $total',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: subtextColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Close button
                      AcedexBounceable(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF24242C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: lineColor),
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: subtextColor,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    widget.questions[_currentIndex].topicTitle ??
                        widget.headerTitle,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Dynamic Segmented Progress Bar
                  Row(
                    children: [
                      for (int i = 0; i < total; i++) ...[
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _currentIndex ? accent : lineColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        if (i < total - 1) const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Scrollable Question Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                child: _buildQuestionView(
                  widget.questions[_currentIndex],
                  cardBg: cardBg,
                  lineColor: lineColor,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  accent: accent,
                  accentSoft: accentSoft,
                  isDark: isDark,
                ),
              ),
            ),
          ] else ...[
            // Completion View
            Expanded(
              child: _buildCompletionView(
                cardBg: cardBg,
                textColor: textColor,
                subtextColor: subtextColor,
                accent: accent,
                isDark: isDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionView(
    DrillQuestionItem q, {
    required Color cardBg,
    required Color lineColor,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
    required Color accentSoft,
    required bool isDark,
  }) {
    final letters = ['A', 'B', 'C', 'D'];
    final isAnswered = _selectedOptionIndex != null;
    final isRight = _selectedOptionIndex == q.correctIndex;
    final total = widget.questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question prompt text
        Text(
          q.q,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 14),

        // Option A-D Buttons
        for (int i = 0; i < q.options.length; i++) ...[
          _buildDrillOptionBtn(
            q.options[i],
            letter: letters[i % letters.length],
            index: i,
            correctIndex: q.correctIndex,
            lineColor: lineColor,
            textColor: textColor,
            accent: accent,
            accentSoft: accentSoft,
            isDark: isDark,
          ),
          const SizedBox(height: 9),
        ],

        // Explanation Card (revealed once answered)
        if (isAnswered) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRight
                      ? 'Correct Answer!'
                      : 'Correct Option: ${letters[q.correctIndex]}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isRight
                        ? (isDark ? AppColors.darkSuccess : AppColors.success)
                        : accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.explanation,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Advance Action Button
          Align(
            alignment: Alignment.centerRight,
            child: AcedexBounceable(
              onTap: _handleAdvance,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentIndex < total - 1
                          ? 'Next Question'
                          : 'Complete Assessment',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
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
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildDrillOptionBtn(
    String optionText, {
    required String letter,
    required int index,
    required int correctIndex,
    required Color lineColor,
    required Color textColor,
    required Color accent,
    required Color accentSoft,
    required bool isDark,
  }) {
    final isSelected = _selectedOptionIndex == index;
    final isAnswered = _selectedOptionIndex != null;
    final isCorrect = index == correctIndex;

    Color border = lineColor;
    Color bg = isDark ? const Color(0xFF24242C) : Colors.white;

    if (isAnswered) {
      if (isSelected) {
        if (isCorrect) {
          border = isDark ? AppColors.darkSuccess : AppColors.success;
          bg = isDark
              ? AppColors.darkSuccess.withValues(alpha: 0.18)
              : AppColors.successContainer;
        } else {
          border = isDark ? AppColors.darkError : AppColors.error;
          bg = isDark ? AppColors.darkErrorSoft : AppColors.lightErrorSoft;
        }
      } else if (isCorrect) {
        border = isDark ? AppColors.darkSuccess : AppColors.success;
      }
    }

    return AcedexBounceable(
      onTap: isAnswered ? null : () => _handleSelectOption(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: isSelected ? 1.6 : 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: accentSoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionView({
    required Color cardBg,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
    required bool isDark,
  }) {
    final total = widget.questions.length;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;
    final successBg = isDark
        ? AppColors.darkSuccess.withValues(alpha: 0.16)
        : AppColors.successContainer;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkmark badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: successBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: successColor,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Score headline
            Text(
              '$_score / $total Correct!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: textColor,
              ),
            ),

            const SizedBox(height: 5),

            // Mastery update detail
            Text(
              '${widget.subject.name} mastery updated to ${widget.subject.mastery}% (+$_boost%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subtextColor,
              ),
            ),

            const SizedBox(height: 24),

            // Back to Study Syllabus CTA
            AcedexBounceable(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 42,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Back to Study Syllabus',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
