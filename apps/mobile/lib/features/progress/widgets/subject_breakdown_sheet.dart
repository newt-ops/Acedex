import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/progress_models.dart';

/// Cupertino Bottom Sheet: Subject Mastery Breakdown & 2-Question Booster Drill
class SubjectBreakdownSheet extends StatefulWidget {
  final SubjectMastery subject;
  final String delta;
  final void Function(String subjectId, int gain) onMasteryBoosted;

  const SubjectBreakdownSheet({
    super.key,
    required this.subject,
    required this.delta,
    required this.onMasteryBoosted,
  });

  static Future<void> show(
    BuildContext context, {
    required SubjectMastery subject,
    required String delta,
    required void Function(String subjectId, int gain) onMasteryBoosted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => SubjectBreakdownSheet(
        subject: subject,
        delta: delta,
        onMasteryBoosted: onMasteryBoosted,
      ),
    );
  }

  @override
  State<SubjectBreakdownSheet> createState() => _SubjectBreakdownSheetState();
}

class _SubjectBreakdownSheetState extends State<SubjectBreakdownSheet> {
  bool _isBoosterMode = false;
  bool _isLoadingBooster = false;

  // Booster Drill State
  int _qIdx = 0;
  int? _selectedOpt;
  int _correctCount = 0;
  bool _boosterCompleted = false;

  Future<void> _launchBooster() async {
    if (_isLoadingBooster) return;
    setState(() => _isLoadingBooster = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() {
        _isLoadingBooster = false;
        _isBoosterMode = true;
        _qIdx = 0;
        _selectedOpt = null;
        _correctCount = 0;
        _boosterCompleted = false;
      });
    }
  }

  void _handleOptionSelect(int optIdx) {
    if (_selectedOpt != null) return;
    final q = widget.subject.boosterQuestions[_qIdx];
    setState(() {
      _selectedOpt = optIdx;
      if (optIdx == q.correctIndex) {
        _correctCount++;
      }
    });
  }

  void _handleNextOrComplete() {
    if (_boosterCompleted) {
      Navigator.of(context).pop();
      return;
    }

    if (_qIdx == 0) {
      setState(() {
        _qIdx = 1;
        _selectedOpt = null;
      });
    } else {
      // Booster Complete!
      final gain = _correctCount == 2 ? 4 : (_correctCount == 1 ? 2 : 1);
      widget.subject.mastery = (widget.subject.mastery + gain).clamp(0, 99);
      final weakUnit = widget.subject.units.where((u) => u.isWeakest).firstOrNull;
      if (weakUnit != null) {
        weakUnit.pct = (weakUnit.pct + gain * 2).clamp(0, 98);
      }
      widget.onMasteryBoosted(widget.subject.id, gain);

      setState(() {
        _boosterCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final sheetBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle & Header
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'G12 NATURAL SCIENCE • ${widget.subject.weightLabel.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            '${widget.subject.name} Mastery',
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: lineColor),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: theme.colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mode A: Breakdown View or Mode B: Booster View
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: _isBoosterMode ? _buildBoosterView(context) : _buildBreakdownView(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mode A: Unit-by-Unit Syllabus Breakdown View
  Widget _buildBreakdownView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mastery & Pacing Metric Pair
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: lineColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT MASTERY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.subject.mastery}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.delta,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkSuccess : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: lineColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVG PACING / Q',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${widget.subject.pacingSec}s',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ 72s EUEE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Unit-by-Unit Syllabus Progress List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unit-by-Unit Progress',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${widget.subject.units.length} Core Units',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        for (final u in widget.subject.units) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: u.isWeakest ? accentSoftColor : surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: u.isWeakest ? accentColor : lineColor,
                width: u.isWeakest ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        u.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${u.pct}%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: u.isWeakest ? accentColor : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: u.pct / 100,
                    minHeight: 5,
                    backgroundColor: lineColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      u.isWeakest
                          ? (isDark ? AppColors.darkWarning : AppColors.warning)
                          : accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Boost Weakest Unit CTA Button
        AcedexBounceable(
          onTap: _isLoadingBooster ? null : _launchBooster,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A2BA3).withValues(alpha: 0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _isLoadingBooster
                ? const AcedexDotsLoader(color: Colors.white, dotSize: 5, gap: 4)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Boost ${widget.subject.weakestTopic}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Mode B: 2-Question Interactive Booster Drill View
  Widget _buildBoosterView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final q = widget.subject.boosterQuestions[_qIdx];
    const letters = ['A', 'B', 'C', 'D'];

    final heroGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1E1523), Color(0xFF26192D), Color(0xFF2D1D36)],
          )
        : const LinearGradient(
            colors: [Color(0xFFFAF5FC), Color(0xFFF3E4F8), Color(0xFFECE0F3)],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Subheader: Question Counter & Back to Units Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: accentSoftColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Booster Question ${_qIdx + 1} of 2',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ),
            if (!_boosterCompleted)
              AcedexBounceable(
                onTap: () => setState(() => _isBoosterMode = false),
                child: Text(
                  '← Units',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: subtextColor,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // 2-Step Segmented Progress Bar
        Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: _qIdx == 1 || _boosterCompleted ? accentColor : lineColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (!_boosterCompleted) ...[
          // Question Stem
          Text(
            q.stem,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          // Options A-D
          for (int optIdx = 0; optIdx < q.options.length; optIdx++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _BoosterOptionButton(
                letter: letters[optIdx],
                text: q.options[optIdx],
                isSelected: _selectedOpt == optIdx,
                isCorrect: optIdx == q.correctIndex,
                hasAnswered: _selectedOpt != null,
                accentColor: accentColor,
                lineColor: lineColor,
                surfaceColor: surfaceColor,
                cardBg: cardBg,
                isDark: isDark,
                onTap: () => _handleOptionSelect(optIdx),
              ),
            ),
          ],

          // Step-by-Step EUEE Explanation Card
          if (_selectedOpt != null) ...[
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: lineColor),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'EUEE Solution: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    TextSpan(
                      text: q.explanation,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ] else ...[
          // Booster Summary Result Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: heroGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lineColor),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'MASTERY BOOSTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.subject.name} +${_correctCount == 2 ? 4 : (_correctCount == 1 ? 2 : 1)}% Mastery!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_correctCount/2 correct • ${widget.subject.name} mastery updated to ${widget.subject.mastery}%.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Next / Complete Button
        AcedexBounceable(
          onTap: _selectedOpt == null && !_boosterCompleted ? null : _handleNextOrComplete,
          child: AnimatedOpacity(
            opacity: _selectedOpt != null || _boosterCompleted ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(999),
                boxShadow: _selectedOpt != null || _boosterCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8A2BA3).withValues(alpha: 0.38),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _boosterCompleted
                        ? 'Done'
                        : (_selectedOpt == null
                            ? 'Select an Answer'
                            : (_qIdx == 0 ? 'Next Question' : 'Complete Booster')),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  HugeIcon(
                    icon: _boosterCompleted
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
    );
  }
}

class _BoosterOptionButton extends StatelessWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final Color accentColor;
  final Color lineColor;
  final Color surfaceColor;
  final Color cardBg;
  final bool isDark;
  final VoidCallback onTap;

  const _BoosterOptionButton({
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.accentColor,
    required this.lineColor,
    required this.surfaceColor,
    required this.cardBg,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bg = surfaceColor;
    Color border = lineColor;
    Color badgeBg = cardBg;
    Color badgeColor = accentColor;

    if (hasAnswered) {
      if (isCorrect) {
        bg = isDark
            ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
            : const Color(0xFFDCFCE7);
        border = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
        badgeBg = border;
        badgeColor = Colors.white;
      } else if (isSelected) {
        bg = isDark
            ? const Color(0xFFF87171).withValues(alpha: 0.16)
            : const Color(0xFFFEE2E2);
        border = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        badgeBg = border;
        badgeColor = Colors.white;
      }
    }

    return AcedexBounceable(
      onTap: hasAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: isSelected || (hasAnswered && isCorrect) ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
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
    );
  }
}
