import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';

/// Component 5: Smart Notes Reader (Cupertino Bottom Sheet)
///
/// Features breadcrumb header, A- / A+ font size scaling, live-synced bookmark
/// toggle, gliding 3 tabs (Concise Notes, Key Formulas, EUEE Tips), one-tap
/// formula copy with "Copied ✓" feedback, inline Quick Concept Check self-test,
/// and sticky bottom action bar (Mark Complete + Drill This Topic).
class SmartNotesReaderSheet extends StatefulWidget {
  final StudyTopic topic;
  final SubjectCurriculum subject;
  final VoidCallback onToggleBookmark;
  final VoidCallback onToggleComplete;
  final VoidCallback onDrillTopic;

  const SmartNotesReaderSheet({
    super.key,
    required this.topic,
    required this.subject,
    required this.onToggleBookmark,
    required this.onToggleComplete,
    required this.onDrillTopic,
  });

  static Future<void> show(
    BuildContext context, {
    required StudyTopic topic,
    required SubjectCurriculum subject,
    required VoidCallback onToggleBookmark,
    required VoidCallback onToggleComplete,
    required VoidCallback onDrillTopic,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => SmartNotesReaderSheet(
        topic: topic,
        subject: subject,
        onToggleBookmark: onToggleBookmark,
        onToggleComplete: onToggleComplete,
        onDrillTopic: onDrillTopic,
      ),
    );
  }

  @override
  State<SmartNotesReaderSheet> createState() => _SmartNotesReaderSheetState();
}

class _SmartNotesReaderSheetState extends State<SmartNotesReaderSheet> {
  int _activeTabIndex = 0; // 0: Concise, 1: Formulas, 2: Tips
  double _fontSize = 13.0; // Scalable from 11.5 to 16.0
  int? _conceptCheckSelectedIdx;
  int? _copiedFormulaIndex;
  bool _isDrillLoading = false;
  late bool _isBookmarked;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.topic.bookmarked;
    _isCompleted = widget.topic.completed;
  }

  void _handleFontScale(bool increase) {
    setState(() {
      if (increase) {
        _fontSize = (_fontSize + 1.0).clamp(11.5, 16.0);
      } else {
        _fontSize = (_fontSize - 1.0).clamp(11.5, 16.0);
      }
    });
  }

  void _handleBookmarkToggle() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    widget.onToggleBookmark();
  }

  void _handleCompleteToggle() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
    widget.onToggleComplete();
  }

  void _copyFormula(String expr, int index) async {
    await Clipboard.setData(ClipboardData(text: expr));
    HapticFeedback.lightImpact();
    setState(() => _copiedFormulaIndex = index);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _copiedFormulaIndex = null);
    }
  }

  void _handleDrillTopic() async {
    if (_isDrillLoading) return;
    setState(() => _isDrillLoading = true);
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _isDrillLoading = false);
    Navigator.pop(context);
    widget.onDrillTopic();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF16161C) : const Color(0xFFFFFFFF);
    final cardBg = isDark ? const Color(0xFF1E1E26) : const Color(0xFFF7F7F9);
    final raisedBg = isDark ? const Color(0xFF2B2B36) : const Color(0xFFECECEF);
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft =
        isDark ? accent.withValues(alpha: 0.18) : AppColors.royalPurpleSoft;

    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.90;

    // Glider alignment math for 3 tabs
    final double gliderAlignX = _activeTabIndex == 0
        ? -1.0
        : (_activeTabIndex == 1 ? 0.0 : 1.0);

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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top control bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Breadcrumb pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${widget.subject.name} • Topic ${widget.topic.code}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: accent,
                        ),
                      ),
                    ),

                    // Controls: A-, A+, Bookmark, Close
                    Row(
                      children: [
                        _buildHeaderBtn(
                          child: const Text('A-',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w800)),
                          onTap: () => _handleFontScale(false),
                          isDark: isDark,
                          lineColor: lineColor,
                        ),
                        const SizedBox(width: 5),
                        _buildHeaderBtn(
                          child: const Text('A+',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w800)),
                          onTap: () => _handleFontScale(true),
                          isDark: isDark,
                          lineColor: lineColor,
                        ),
                        const SizedBox(width: 5),
                        _buildHeaderBtn(
                          child: HugeIcon(
                            icon: _isBookmarked
                                ? HugeIcons.strokeRoundedBookmark02
                                : HugeIcons.strokeRoundedBookmark01,
                            color: _isBookmarked ? accent : subtextColor,
                            size: 14,
                          ),
                          onTap: _handleBookmarkToggle,
                          isDark: isDark,
                          lineColor: _isBookmarked ? accent : lineColor,
                          bgColor: _isBookmarked ? accentSoft : null,
                        ),
                        const SizedBox(width: 5),
                        _buildHeaderBtn(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: subtextColor,
                            size: 14,
                          ),
                          onTap: () => Navigator.pop(context),
                          isDark: isDark,
                          lineColor: lineColor,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Topic Title
                Text(
                  widget.topic.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.topic.duration} read • ${widget.topic.questionCount} EUEE Questions',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Gliding 3-Tab Segmented Control
                Container(
                  height: 33,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: lineColor),
                  ),
                  child: Stack(
                    children: [
                      // Glider
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeInOut,
                        alignment: Alignment(gliderAlignX, 0.0),
                        child: FractionallySizedBox(
                          widthFactor: 1 / 3,
                          child: Container(
                            height: 27,
                            decoration: BoxDecoration(
                              color: isDark ? raisedBg : Colors.white,
                              borderRadius: BorderRadius.circular(8.5),
                              border: Border.all(color: lineColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Tabs
                      Row(
                        children: [
                          _buildTabBtn(
                            label: 'Concise Notes',
                            isActive: _activeTabIndex == 0,
                            onTap: () => setState(() => _activeTabIndex = 0),
                            accent: accent,
                            subtextColor: subtextColor,
                          ),
                          _buildTabBtn(
                            label: 'Key Formulas',
                            isActive: _activeTabIndex == 1,
                            onTap: () => setState(() => _activeTabIndex = 1),
                            accent: accent,
                            subtextColor: subtextColor,
                          ),
                          _buildTabBtn(
                            label: 'EUEE Tips',
                            isActive: _activeTabIndex == 2,
                            onTap: () => setState(() => _activeTabIndex = 2),
                            accent: accent,
                            subtextColor: subtextColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Scrollable Content Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: _buildTabContent(
                context,
                cardBg: cardBg,
                raisedBg: raisedBg,
                lineColor: lineColor,
                textColor: textColor,
                subtextColor: subtextColor,
                accent: accent,
                accentSoft: accentSoft,
                isDark: isDark,
              ),
            ),
          ),

          // Sticky Footer Action Bar
          Container(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 12,
              bottom: mediaQuery.padding.bottom > 0
                  ? mediaQuery.padding.bottom + 6
                  : 18,
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: lineColor)),
            ),
            child: Row(
              children: [
                // Mark Complete button
                AcedexBounceable(
                  onTap: _handleCompleteToggle,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _isCompleted
                          ? (isDark
                              ? AppColors.darkSuccess.withValues(alpha: 0.18)
                              : AppColors.successContainer)
                          : cardBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _isCompleted
                            ? (isDark
                                ? AppColors.darkSuccess
                                : AppColors.success)
                            : lineColor,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: _isCompleted
                              ? HugeIcons.strokeRoundedCheckmarkCircle02
                              : HugeIcons.strokeRoundedCircle,
                          color: _isCompleted
                              ? (isDark
                                  ? AppColors.darkSuccess
                                  : AppColors.success)
                              : subtextColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isCompleted ? 'Completed ✓' : 'Mark Complete',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _isCompleted
                                ? (isDark
                                    ? AppColors.darkSuccess
                                    : AppColors.success)
                                : textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Drill This Topic CTA
                Expanded(
                  child: AcedexBounceable(
                    onTap: _handleDrillTopic,
                    child: Container(
                      height: 42,
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
                      child: Center(
                        child: _isDrillLoading
                            ? const AcedexDotsLoader(
                                dotSize: 5.5,
                                gap: 4.5,
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Drill This Topic',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedArrowRight01,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBtn({
    required Widget child,
    required VoidCallback onTap,
    required bool isDark,
    required Color lineColor,
    Color? bgColor,
  }) {
    return AcedexBounceable(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        constraints: const BoxConstraints(minWidth: 28),
        decoration: BoxDecoration(
          color: bgColor ?? (isDark ? const Color(0xFF24242C) : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: lineColor),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildTabBtn({
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

  Widget _buildTabContent(
    BuildContext context, {
    required Color cardBg,
    required Color raisedBg,
    required Color lineColor,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
    required Color accentSoft,
    required bool isDark,
  }) {
    final notes = widget.topic.notes;
    if (notes == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Smart notes for this unit topic are being prepared.',
            style: TextStyle(fontSize: 12, color: subtextColor),
          ),
        ),
      );
    }

    if (_activeTabIndex == 1) {
      // Tab 1: Key Formulas
      final formulas = notes.formulas;
      if (formulas.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'No formulas in this conceptual topic.',
              style: TextStyle(fontSize: 12, color: subtextColor),
            ),
          ),
        );
      }

      return Column(
        children: [
          for (int i = 0; i < formulas.length; i++) ...[
            _buildFormulaCard(
              formulas[i],
              index: i,
              cardBg: cardBg,
              raisedBg: raisedBg,
              lineColor: lineColor,
              textColor: textColor,
              subtextColor: subtextColor,
              accent: accent,
              accentSoft: accentSoft,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    if (_activeTabIndex == 2) {
      // Tab 2: EUEE Tips
      final tips = notes.tips;
      return Column(
        children: [
          for (int i = 0; i < tips.length; i++) ...[
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: lineColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '#${i + 1}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tips[i],
                      style: TextStyle(
                        fontSize: _fontSize - 0.5,
                        height: 1.45,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    // Tab 0: Concise Notes + Quick Concept Check
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Bullets Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: lineColor),
          ),
          child: Column(
            children: [
              for (final bullet in notes.summary)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 9),
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bullet,
                          style: TextStyle(
                            fontSize: _fontSize,
                            height: 1.45,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Inline Quick Concept Check Self-Test
        _buildConceptCheckCard(
          cardBg: cardBg,
          lineColor: lineColor,
          textColor: textColor,
          subtextColor: subtextColor,
          accent: accent,
          accentSoft: accentSoft,
          isDark: isDark,
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildFormulaCard(
    FormulaItem f, {
    required int index,
    required Color cardBg,
    required Color raisedBg,
    required Color lineColor,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
    required Color accentSoft,
    required bool isDark,
  }) {
    final isCopied = _copiedFormulaIndex == index;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  f.name,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: subtextColor,
                  ),
                ),
              ),
              AcedexBounceable(
                onTap: () => _copyFormula(f.expr, index),
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    color: isCopied
                        ? (isDark
                            ? AppColors.darkSuccess.withValues(alpha: 0.2)
                            : AppColors.successContainer)
                        : accentSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      isCopied ? 'Copied ✓' : 'Copy',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isCopied
                            ? (isDark
                                ? AppColors.darkSuccess
                                : AppColors.success)
                            : accent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: raisedBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: lineColor),
            ),
            child: Text(
              f.expr,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            f.vars,
            style: TextStyle(
              fontSize: 10.5,
              color: subtextColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptCheckCard({
    required Color cardBg,
    required Color lineColor,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
    required Color accentSoft,
    required bool isDark,
  }) {
    final check = widget.topic.notes?.conceptCheck;
    if (check == null) return const SizedBox.shrink();
    final letters = ['A', 'B', 'C', 'D'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK CONCEPT CHECK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: accent,
                ),
              ),
              Text(
                'Self-Test',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            check.q,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < check.options.length; i++) ...[
            _buildConceptOptionBtn(
              check.options[i],
              letter: letters[i % letters.length],
              index: i,
              correctIndex: check.correctIdx,
              lineColor: lineColor,
              textColor: textColor,
              accent: accent,
              accentSoft: accentSoft,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
          ],
          if (_conceptCheckSelectedIdx != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _conceptCheckSelectedIdx == check.correctIdx
                    ? (isDark
                        ? AppColors.darkSuccess.withValues(alpha: 0.18)
                        : AppColors.successContainer)
                    : (isDark
                        ? AppColors.darkErrorSoft
                        : AppColors.lightErrorSoft),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _conceptCheckSelectedIdx == check.correctIdx
                    ? check.feedback
                    : 'Not quite — ${check.feedback}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _conceptCheckSelectedIdx == check.correctIdx
                      ? (isDark ? AppColors.darkSuccess : AppColors.success)
                      : (isDark ? AppColors.darkError : AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConceptOptionBtn(
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
    final isSelected = _conceptCheckSelectedIdx == index;
    final isAnswered = _conceptCheckSelectedIdx != null;
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
      onTap: () {
        setState(() => _conceptCheckSelectedIdx = index);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: accentSoft,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
