import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/practice_models.dart';

/// View 3: Score Summary & Answer Review Engine
class AnswerReviewView extends StatefulWidget {
  final CompletedSession session;
  final List<EueeQuestion> questions;
  final VoidCallback onRetake;
  final VoidCallback onAllPapers;

  const AnswerReviewView({
    super.key,
    required this.session,
    required this.questions,
    required this.onRetake,
    required this.onAllPapers,
  });

  @override
  State<AnswerReviewView> createState() => _AnswerReviewViewState();
}

class _AnswerReviewViewState extends State<AnswerReviewView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;
  String _activeFilter = 'all'; // 'all' | 'incorrect' | 'flagged'
  bool _isRetaking = false;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final targetProgress = (widget.session.scorePct / 100).clamp(0.0, 1.0);
    _ringAnimation = Tween<double>(begin: 0.0, end: targetProgress).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOutCubic),
    );

    _ringController.forward();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _handleRetakeTap() async {
    if (_isRetaking) return;
    setState(() => _isRetaking = true);
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _isRetaking = false);
    widget.onRetake();
  }

  String _getAccuracyBadge(int scorePct) {
    if (scorePct >= 80) return 'EUEE Distinction';
    if (scorePct >= 60) return 'Solid Pass';
    return 'Needs Drill';
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
    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;
    final successBg = isDark
        ? AppColors.darkSuccess.withValues(alpha: 0.16)
        : AppColors.successContainer;
    final warningColor = isDark ? AppColors.darkWarning : AppColors.warning;
    final warningBg = isDark
        ? AppColors.darkWarning.withValues(alpha: 0.16)
        : AppColors.warningContainer;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;
    final errorBg = isDark
        ? AppColors.darkError.withValues(alpha: 0.16)
        : AppColors.lightErrorSoft;

    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1E1523), Color(0xFF26192C), Color(0xFF2C1C34)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFAF5FC), Color(0xFFF3E5F7), Color(0xFFEFE1F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final total = widget.questions.length;
    int incorrectCount = 0;
    int flaggedCount = 0;

    for (int i = 0; i < total; i++) {
      if (widget.session.userAnswers[i] != widget.questions[i].correctIndex) {
        incorrectCount += 1;
      }
      if (widget.session.flagged[i]) {
        flaggedCount += 1;
      }
    }

    final double filterAlignX = _activeFilter == 'all'
        ? -1.0
        : (_activeFilter == 'incorrect' ? 0.0 : 1.0);

    // Filter review items
    final filteredQuestions = <Map<String, dynamic>>[];
    for (int i = 0; i < total; i++) {
      final q = widget.questions[i];
      final userAns = widget.session.userAnswers[i];
      final isCorrect = userAns == q.correctIndex;
      final isFlagged = widget.session.flagged[i];

      if (_activeFilter == 'incorrect' && isCorrect) continue;
      if (_activeFilter == 'flagged' && !isFlagged) continue;

      filteredQuestions.add({
        'question': q,
        'index': i,
        'userAnswer': userAns,
        'isCorrect': isCorrect,
        'isFlagged': isFlagged,
      });
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: 130, // Clears floating bottom navigation bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Celebratory Score Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: lineColor),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.25 : 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Animated Circular Score Ring
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: AnimatedBuilder(
                        animation: _ringAnimation,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _CircularScoreRingPainter(
                              progress: _ringAnimation.value,
                              ringColor: accent,
                              trackColor: lineColor,
                            ),
                            child: Center(
                              child: Text(
                                '${widget.session.scorePct}%',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: textColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Detail Stack
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: raisedBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: lineColor),
                            ),
                            child: Text(
                              widget.session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${widget.session.correctCount} of $total Correct',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                'Time: ${widget.session.elapsedStr}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: subtextColor,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text('•',
                                    style: TextStyle(color: subtextColor)),
                              ),
                              Text(
                                _getAccuracyBadge(widget.session.scorePct),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: widget.session.scorePct >= 80
                                      ? successColor
                                      : (widget.session.scorePct >= 60
                                          ? accent
                                          : warningColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Action Buttons: Retake Paper & All Papers
                Row(
                  children: [
                    Expanded(
                      child: AcedexBounceable(
                        onTap: _handleRetakeTap,
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: raisedBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: lineColor),
                          ),
                          child: Center(
                            child: _isRetaking
                                ? AcedexDotsLoader(
                                    dotSize: 4.5,
                                    gap: 3.5,
                                    color: textColor,
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedReload,
                                        color: textColor,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Retake Paper',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AcedexBounceable(
                        onTap: widget.onAllPapers,
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'All Papers',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              HugeIcon(
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
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Gliding 3-Tab Filter Bar
          Container(
            height: 34,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: lineColor),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  alignment: Alignment(filterAlignX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: Container(
                      height: 27,
                      decoration: BoxDecoration(
                        color: raisedBg,
                        borderRadius: BorderRadius.circular(8.5),
                        border: Border.all(color: lineColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildFilterTab(
                      label: 'All ($total)',
                      isActive: _activeFilter == 'all',
                      onTap: () => setState(() => _activeFilter = 'all'),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                    _buildFilterTab(
                      label: 'Incorrect ($incorrectCount)',
                      isActive: _activeFilter == 'incorrect',
                      onTap: () => setState(() => _activeFilter = 'incorrect'),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                    _buildFilterTab(
                      label: 'Flagged ($flaggedCount)',
                      isActive: _activeFilter == 'flagged',
                      onTap: () => setState(() => _activeFilter = 'flagged'),
                      accent: accent,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Question-by-Question Review Cards
          if (filteredQuestions.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: lineColor),
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'No questions in this filter',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Switch back to "All" to inspect every question and explanation.',
                      style: TextStyle(
                        fontSize: 11,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            for (final item in filteredQuestions) ...[
              _buildQuestionReviewCard(
                q: item['question'] as EueeQuestion,
                index: item['index'] as int,
                userAnswer: item['userAnswer'] as int?,
                isCorrect: item['isCorrect'] as bool,
                isFlagged: item['isFlagged'] as bool,
                surfaceColor: surfaceColor,
                raisedBg: raisedBg,
                lineColor: lineColor,
                textColor: textColor,
                subtextColor: subtextColor,
                accent: accent,
                accentSoft: accentSoft,
                successColor: successColor,
                successBg: successBg,
                warningColor: warningColor,
                warningBg: warningBg,
                errorColor: errorColor,
                errorBg: errorBg,
              ),
              const SizedBox(height: 12),
            ],
          ],

          const SizedBox(height: 8),

          // 4. Back to Practice Hub CTA
          AcedexBounceable(
            onTap: widget.onAllPapers,
            child: Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: lineColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: textColor,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Back to Practice Hub',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color accent,
    required Color subtextColor,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? accent : subtextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionReviewCard({
    required EueeQuestion q,
    required int index,
    required int? userAnswer,
    required bool isCorrect,
    required bool isFlagged,
    required Color surfaceColor,
    required Color raisedBg,
    required Color lineColor,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
    required Color accentSoft,
    required Color successColor,
    required Color successBg,
    required Color warningColor,
    required Color warningBg,
    required Color errorColor,
    required Color errorBg,
  }) {
    final statusLabel = isCorrect
        ? 'Correct'
        : (userAnswer == null ? 'Skipped' : 'Incorrect');
    final statusBg = isCorrect
        ? successBg
        : (userAnswer == null ? warningBg : errorBg);
    final statusColor = isCorrect
        ? successColor
        : (userAnswer == null ? warningColor : errorColor);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Q# + Status Badge + Flagged + Unit Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Q${index + 1}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (isFlagged) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: warningBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Flagged',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: warningColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Flexible(
                child: Text(
                  q.unitTag.split('•').last.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: subtextColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          // Question Stem
          Text(
            q.stem,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),

          // Choices Comparison
          for (int optIdx = 0; optIdx < q.options.length; optIdx++) ...[
            _buildReviewChoiceRow(
              letter: String.fromCharCode(65 + optIdx),
              text: q.options[optIdx],
              isRightOpt: optIdx == q.correctIndex,
              isUserOpt: optIdx == userAnswer,
              isCorrect: isCorrect,
              raisedBg: raisedBg,
              lineColor: lineColor,
              textColor: textColor,
              subtextColor: subtextColor,
              successColor: successColor,
              successBg: successBg,
              errorColor: errorColor,
              errorBg: errorBg,
            ),
            const SizedBox(height: 6),
          ],

          const SizedBox(height: 8),

          // EUEE Step-by-Step Explanation Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: raisedBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EUEE Step-by-Step Explanation',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    q.formula,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  q.explanation,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewChoiceRow({
    required String letter,
    required String text,
    required bool isRightOpt,
    required bool isUserOpt,
    required bool isCorrect,
    required Color raisedBg,
    required Color lineColor,
    required Color textColor,
    required Color subtextColor,
    required Color successColor,
    required Color successBg,
    required Color errorColor,
    required Color errorBg,
  }) {
    Color bg = raisedBg;
    Color border = lineColor;
    Widget? tag;

    if (isRightOpt) {
      bg = successBg;
      border = successColor;
      tag = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: successColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Correct Answer',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
    } else if (isUserOpt && !isCorrect) {
      bg = errorBg;
      border = errorColor;
      tag = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: errorColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Your Answer',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(
            '$letter.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: isRightOpt
                  ? successColor
                  : (isUserOpt ? errorColor : subtextColor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          ?tag,
        ],
      ),
    );
  }
}

class _CircularScoreRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;

  _CircularScoreRingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Active sweep
    final sweepPaint = Paint()
      ..color = ringColor
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor;
  }
}
