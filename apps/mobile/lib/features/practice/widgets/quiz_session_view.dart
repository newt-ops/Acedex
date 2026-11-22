import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/practice_models.dart';
import 'euee_diagram_card.dart';

/// View 2: Interactive Quiz Session Engine
///
/// Implements the full question runner matching the prototype:
/// - Internal quiz control strip: Exit (x), Question Navigator Grid toggle, Flagging, and live Timer / Mode pill
/// - Collapsible Question Navigator Grid with Answered & Flagged state dots
/// - Segmented Progress Bar with jump-to-question interactivity
/// - Question stage with inline vector diagrams (coil, integral, cell, DNA)
/// - Tactile A-D options, Study Mode hints and instant step-by-step EUEE solutions
/// - Sticky bottom footer with Prev, Hint, and Next / Submit Paper (with 950ms wave loader)
class QuizSessionView extends StatefulWidget {
  final String paperId;
  final String title;
  final String shortTitle;
  final String subtitle;
  final String mode; // 'study' | 'exam'
  final int durationSecs;
  final List<EueeQuestion> questions;
  final VoidCallback onExit;
  final ValueChanged<CompletedSession> onComplete;

  const QuizSessionView({
    super.key,
    required this.paperId,
    required this.title,
    required this.shortTitle,
    required this.subtitle,
    required this.mode,
    required this.durationSecs,
    required this.questions,
    required this.onExit,
    required this.onComplete,
  });

  @override
  State<QuizSessionView> createState() => _QuizSessionViewState();
}

class _QuizSessionViewState extends State<QuizSessionView> {
  int _currentIndex = 0;
  late List<int?> _userAnswers;
  late List<bool> _checked;
  late List<bool> _flagged;
  late List<bool> _hintShown;
  bool _navigatorOpen = false;

  late int _remainingSecs;
  int _elapsedSecs = 0;
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final count = widget.questions.length;
    _userAnswers = List<int?>.filled(count, null);
    _checked = List<bool>.filled(count, false);
    _flagged = List<bool>.filled(count, false);
    _hintShown = List<bool>.filled(count, false);
    _remainingSecs = widget.durationSecs;

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSecs += 1;
        if (widget.mode == 'exam') {
          _remainingSecs = (_remainingSecs - 1).clamp(0, 99999);
          if (_remainingSecs == 0) {
            _timer?.cancel();
            _handleSubmitPaper();
          }
        }
      });
    });
  }

  String _formatMMSS(int totalSecs) {
    final s = totalSecs.clamp(0, 99999);
    final mins = (s ~/ 60).toString().padLeft(2, '0');
    final secs = (s % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _handleSelectOption(int optIdx) {
    if (widget.mode == 'study' && _checked[_currentIndex]) return;

    setState(() {
      _userAnswers[_currentIndex] = optIdx;
      if (widget.mode == 'study') {
        _checked[_currentIndex] = true;
      }
    });
  }

  void _handleToggleFlag() {
    setState(() {
      _flagged[_currentIndex] = !_flagged[_currentIndex];
    });
  }

  void _handleToggleHint() {
    setState(() {
      _hintShown[_currentIndex] = !_hintShown[_currentIndex];
    });
  }

  void _handleSubmitPaper() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();

    // 950ms wave loader before smoothly transitioning to View 3
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;

    final total = widget.questions.length;
    int correctCount = 0;
    for (int i = 0; i < total; i++) {
      if (_userAnswers[i] == widget.questions[i].correctIndex) {
        correctCount += 1;
      }
    }
    final scorePct = ((correctCount / total) * 100).round();
    final elapsedStr = _formatMMSS(_elapsedSecs > 10 ? _elapsedSecs : 185);

    final session = CompletedSession(
      id: 'comp-${DateTime.now().millisecondsSinceEpoch}',
      paperId: widget.paperId,
      title: widget.title,
      subtitle: widget.subtitle,
      modeLabel: widget.mode == 'study' ? 'Study Mode' : 'Exam Mode',
      elapsedStr: elapsedStr,
      scorePct: scorePct,
      correctCount: correctCount,
      totalCount: total,
      dateLabel: 'Just now',
      userAnswers: List.from(_userAnswers),
      flagged: List.from(_flagged),
    );

    widget.onComplete(session);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1B1B1F) : const Color(0xFFF4F4F6);
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft =
        isDark ? accent.withValues(alpha: 0.18) : AppColors.royalPurpleSoft;
    final warningColor = isDark ? AppColors.darkWarning : AppColors.warning;
    final warningBg = isDark
        ? AppColors.darkWarning.withValues(alpha: 0.16)
        : AppColors.warningContainer;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;
    final successBg = isDark
        ? AppColors.darkSuccess.withValues(alpha: 0.16)
        : AppColors.successContainer;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;
    final errorBg = isDark
        ? AppColors.darkError.withValues(alpha: 0.16)
        : AppColors.lightErrorSoft;

    final total = widget.questions.length;
    final currentQ = widget.questions[_currentIndex];
    final selectedOpt = _userAnswers[_currentIndex];
    final isChecked = _checked[_currentIndex];
    final isFlagged = _flagged[_currentIndex];
    final isHintShown = _hintShown[_currentIndex];
    final isLast = _currentIndex == total - 1;

    return Column(
      children: [
        // Scrollable Question Body
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Control Strip: Exit (x), Q 1/5 Pill, Flag, Timer/Mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Exit button
                    AcedexBounceable(
                      onTap: widget.onExit,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: lineColor),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: textColor,
                            size: 15,
                          ),
                        ),
                      ),
                    ),

                    // Q X/Y Navigator Drawer Trigger
                    AcedexBounceable(
                      onTap: () {
                        setState(() => _navigatorOpen = !_navigatorOpen);
                      },
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: lineColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Q ${_currentIndex + 1} / $total',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: _navigatorOpen ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Flag & Timer / Mode
                    Row(
                      children: [
                        // Flag button
                        AcedexBounceable(
                          onTap: _handleToggleFlag,
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isFlagged ? warningBg : surfaceColor,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isFlagged ? warningColor : lineColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedFlag01,
                                  color: isFlagged ? warningColor : subtextColor,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Flag',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isFlagged ? warningColor : subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Timer or Study Mode Pill
                        Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: widget.mode == 'exam'
                                    ? HugeIcons.strokeRoundedClock01
                                    : HugeIcons.strokeRoundedBookOpen01,
                                color: accent,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.mode == 'exam'
                                    ? _formatMMSS(_remainingSecs)
                                    : 'Study Mode',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Collapsible Question Navigator Grid
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: _navigatorOpen
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: lineColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Question Navigator',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: subtextColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _buildLegendDot(
                                        color: accent,
                                        label: 'Answered',
                                        subtextColor: subtextColor,
                                      ),
                                      const SizedBox(width: 10),
                                      _buildLegendDot(
                                        color: warningColor,
                                        label: 'Flagged',
                                        subtextColor: subtextColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  for (int i = 0; i < total; i++) ...[
                                    Expanded(
                                      child: _buildNavigatorTile(
                                        index: i,
                                        isCurrent: i == _currentIndex,
                                        isAnswered: _userAnswers[i] != null,
                                        isFlagged: _flagged[i],
                                        raisedBg: raisedBg,
                                        lineColor: lineColor,
                                        accent: accent,
                                        accentSoft: accentSoft,
                                        warningColor: warningColor,
                                        textColor: textColor,
                                      ),
                                    ),
                                    if (i < total - 1) const SizedBox(width: 6),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Dynamic Segmented Progress Bar
                Row(
                  children: [
                    for (int i = 0; i < total; i++) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _currentIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            height: 5,
                            decoration: BoxDecoration(
                              color: i == _currentIndex
                                  ? accent
                                  : (_flagged[i]
                                      ? warningColor
                                      : (_userAnswers[i] != null
                                          ? accentSoft
                                          : lineColor)),
                              borderRadius: BorderRadius.circular(999),
                              border: (_userAnswers[i] != null &&
                                      i != _currentIndex &&
                                      !_flagged[i])
                                  ? Border.all(color: accent)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      if (i < total - 1) const SizedBox(width: 4),
                    ],
                  ],
                ),

                const SizedBox(height: 14),

                // Question Stage Card
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: raisedBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: lineColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unit Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          currentQ.unitTag,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: accent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Question Stem
                      Text(
                        currentQ.stem,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.4,
                        ),
                      ),

                      // Optional Inline Vector Diagram
                      EueeDiagramCard(diagramType: currentQ.diagramType),

                      const SizedBox(height: 12),

                      // 4 Option Cards (A, B, C, D)
                      for (int optIdx = 0;
                          optIdx < currentQ.options.length;
                          optIdx++) ...[
                        _buildOptionCard(
                          letter: String.fromCharCode(65 + optIdx),
                          optionText: currentQ.options[optIdx],
                          isSelected: selectedOpt == optIdx,
                          isCorrect: optIdx == currentQ.correctIndex,
                          isStudyAndChecked:
                              widget.mode == 'study' && isChecked,
                          surfaceColor: surfaceColor,
                          raisedBg: raisedBg,
                          lineColor: lineColor,
                          textColor: textColor,
                          accent: accent,
                          accentSoft: accentSoft,
                          successColor: successColor,
                          successBg: successBg,
                          errorColor: errorColor,
                          errorBg: errorBg,
                          onTap: () => _handleSelectOption(optIdx),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Study Mode Hint Callout
                      if (widget.mode == 'study' && isHintShown) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: warningBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: warningColor),
                          ),
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 11.5,
                                color: textColor,
                                height: 1.35,
                              ),
                              children: [
                                TextSpan(
                                  text: 'EUEE Hint: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: warningColor,
                                  ),
                                ),
                                TextSpan(text: currentQ.hint),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Study Mode Step-by-Step EUEE Solution Card
                      if (widget.mode == 'study' && isChecked) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lineColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedOpt == currentQ.correctIndex
                                        ? 'Correct Answer ✓'
                                        : 'Incorrect • Correct is ${String.fromCharCode(65 + currentQ.correctIndex)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: selectedOpt == currentQ.correctIndex
                                          ? successColor
                                          : errorColor,
                                    ),
                                  ),
                                  Text(
                                    'EUEE Solution',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: raisedBg,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: lineColor),
                                ),
                                child: Text(
                                  currentQ.formula,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentQ.explanation,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textColor,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sticky Bottom Controls Strip
        Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 22),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(top: BorderSide(color: lineColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev Button
              AcedexBounceable(
                onTap: _currentIndex > 0
                    ? () => setState(() => _currentIndex -= 1)
                    : null,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: raisedBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: lineColor),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: _currentIndex > 0 ? textColor : subtextColor.withValues(alpha: 0.4),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Prev',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _currentIndex > 0 ? textColor : subtextColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Study Mode Mid Controls: Hint
              if (widget.mode == 'study') ...[
                AcedexBounceable(
                  onTap: _handleToggleHint,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: warningBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedIdea01,
                          color: warningColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hint',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: warningColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Next / Submit Button
              AcedexBounceable(
                onTap: isLast
                    ? _handleSubmitPaper
                    : () => setState(() => _currentIndex += 1),
                child: Container(
                  height: 40,
                  constraints: const BoxConstraints(minWidth: 116),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.38),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const AcedexDotsLoader(
                            dotSize: 5.5,
                            gap: 4.5,
                            color: Colors.white,
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLast ? 'Submit Paper' : 'Next',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              HugeIcon(
                                icon: isLast
                                    ? HugeIcons.strokeRoundedCheckmarkCircle02
                                    : HugeIcons.strokeRoundedArrowRight01,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot({
    required Color color,
    required String label,
    required Color subtextColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: subtextColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildNavigatorTile({
    required int index,
    required bool isCurrent,
    required bool isAnswered,
    required bool isFlagged,
    required Color raisedBg,
    required Color lineColor,
    required Color accent,
    required Color accentSoft,
    required Color warningColor,
    required Color textColor,
  }) {
    Color bg = raisedBg;
    Color border = lineColor;
    Color fg = textColor;

    if (isCurrent) {
      bg = accent;
      border = accent;
      fg = Colors.white;
    } else if (isAnswered) {
      bg = accentSoft;
      border = accent;
      fg = accent;
    }

    return AcedexBounceable(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: isCurrent ? 1.5 : 1.0),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
          ),
          if (isFlagged)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: warningColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String letter,
    required String optionText,
    required bool isSelected,
    required bool isCorrect,
    required bool isStudyAndChecked,
    required Color surfaceColor,
    required Color raisedBg,
    required Color lineColor,
    required Color textColor,
    required Color accent,
    required Color accentSoft,
    required Color successColor,
    required Color successBg,
    required Color errorColor,
    required Color errorBg,
    required VoidCallback onTap,
  }) {
    Color bg = surfaceColor;
    Color border = lineColor;
    Color letterBg = raisedBg;
    Color letterFg = accent;

    if (isStudyAndChecked) {
      if (isCorrect) {
        bg = successBg;
        border = successColor;
        letterBg = successColor;
        letterFg = Colors.white;
      } else if (isSelected) {
        bg = errorBg;
        border = errorColor;
        letterBg = errorColor;
        letterFg = Colors.white;
      }
    } else if (isSelected) {
      bg = accentSoft;
      border = accent;
      letterBg = accent;
      letterFg = Colors.white;
    }

    return AcedexBounceable(
      onTap: isStudyAndChecked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: border,
            width: isSelected || (isStudyAndChecked && isCorrect) ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: letterBg,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: letterFg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
