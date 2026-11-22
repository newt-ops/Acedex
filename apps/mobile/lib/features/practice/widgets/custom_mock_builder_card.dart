import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/practice_models.dart';

/// Quick Custom Mock Builder Card with Study Mode vs Exam Mode toggle
class CustomMockBuilderCard extends StatefulWidget {
  final String selectedSubjectId;
  final String sessionMode; // 'study' | 'exam'
  final int questionCount; // 3 | 5
  final ValueChanged<String> onModeChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onStartSession;

  const CustomMockBuilderCard({
    super.key,
    required this.selectedSubjectId,
    required this.sessionMode,
    required this.questionCount,
    required this.onModeChanged,
    required this.onCountChanged,
    required this.onStartSession,
  });

  @override
  State<CustomMockBuilderCard> createState() => _CustomMockBuilderCardState();
}

class _CustomMockBuilderCardState extends State<CustomMockBuilderCard> {
  bool _isLoading = false;

  void _handleStartTap() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onStartSession();
  }

  String _getSubjectFocusLabel() {
    if (widget.selectedSubjectId == 'all') {
      return 'Mixed Stream';
    }
    final meta = practiceSubjects.firstWhere(
      (s) => s.id == widget.selectedSubjectId,
      orElse: () => practiceSubjects.first,
    );
    return '${meta.name} Focus';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final accent = isDark ? AppColors.accentDark : AppColors.royalPurple;
    final accentSoft =
        isDark ? accent.withValues(alpha: 0.18) : AppColors.royalPurpleSoft;

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

    final isStudy = widget.sessionMode == 'study';
    final double modeAlignX = isStudy ? -1.0 : 1.0;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: lineColor),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: raisedBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: lineColor),
                    ),
                    child: Text(
                      'QUICK MOCK BUILDER',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Custom EUEE Session',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              // Subject Focus Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: raisedBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: lineColor),
                ),
                child: Text(
                  _getSubjectFocusLabel(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Gliding 2-Option Mode Segmented Bar
          Container(
            height: 34,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: raisedBg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: lineColor),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  alignment: Alignment(modeAlignX, 0.0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 2,
                    child: Container(
                      height: 27,
                      decoration: BoxDecoration(
                        color: accentSoft,
                        borderRadius: BorderRadius.circular(8.5),
                        border: Border.all(color: accent),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onModeChanged('study'),
                        child: Center(
                          child: Text(
                            'Study Mode',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isStudy
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isStudy ? accent : subtextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onModeChanged('exam'),
                        child: Center(
                          child: Text(
                            'Exam Mode',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: !isStudy
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: !isStudy ? accent : subtextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isStudy
                ? 'Instant answer verification, formula hints & step-by-step EUEE explanations.'
                : 'Timed EUEE simulation with live countdown clock and end-of-paper scoring.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: subtextColor,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Controls: Question Count Chips & Start CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Count Chips
              Row(
                children: [
                  _buildCountChip(
                    count: 3,
                    isSelected: widget.questionCount == 3,
                    raisedBg: raisedBg,
                    lineColor: lineColor,
                    accent: accent,
                    accentSoft: accentSoft,
                    subtextColor: subtextColor,
                  ),
                  const SizedBox(width: 6),
                  _buildCountChip(
                    count: 5,
                    isSelected: widget.questionCount == 5,
                    raisedBg: raisedBg,
                    lineColor: lineColor,
                    accent: accent,
                    accentSoft: accentSoft,
                    subtextColor: subtextColor,
                  ),
                ],
              ),

              // Start Session CTA
              AcedexBounceable(
                onTap: _handleStartTap,
                child: Container(
                  height: 38,
                  constraints: const BoxConstraints(minWidth: 156),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    child: _isLoading
                        ? const AcedexDotsLoader(
                            dotSize: 5.5,
                            gap: 4.5,
                            color: Colors.white,
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Start EUEE Session',
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
    );
  }

  Widget _buildCountChip({
    required int count,
    required bool isSelected,
    required Color raisedBg,
    required Color lineColor,
    required Color accent,
    required Color accentSoft,
    required Color subtextColor,
  }) {
    return AcedexBounceable(
      onTap: () => widget.onCountChanged(count),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: isSelected ? accentSoft : raisedBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? accent : lineColor,
          ),
        ),
        child: Center(
          child: Text(
            '$count Qs',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? accent : subtextColor,
            ),
          ),
        ),
      ),
    );
  }
}
