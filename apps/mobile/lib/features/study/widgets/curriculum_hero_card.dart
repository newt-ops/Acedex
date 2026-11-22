import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';

/// Active Subject Curriculum Hero Card (Component 2)
///
/// Features:
/// - Badge: "G12 • NATIONAL CURRICULUM"
/// - Active Subject Title and Mastery Percentage readout
/// - Units Mastered ratio & Topics completed ratio with linear progress bar
/// - Last Studied topic preview with "Resume Last Note >" CTA pill
/// - Loading state: Zero circular spinners! Uses horizontal `AcedexDotsLoader`
class CurriculumHeroCard extends StatefulWidget {
  final SubjectCurriculum subject;
  final String lastTopicLabel;
  final VoidCallback onResumeNote;
  final String? ctaLabel;

  const CurriculumHeroCard({
    super.key,
    required this.subject,
    required this.lastTopicLabel,
    required this.onResumeNote,
    this.ctaLabel,
  });

  @override
  State<CurriculumHeroCard> createState() => _CurriculumHeroCardState();
}

class _CurriculumHeroCardState extends State<CurriculumHeroCard> {
  bool _isLoadingNote = false;

  void _handleResumeTap() {
    if (_isLoadingNote) return;
    setState(() => _isLoadingNote = true);

    Future.delayed(const Duration(milliseconds: 620), () {
      if (mounted) {
        setState(() => _isLoadingNote = false);
        widget.onResumeNote();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final raisedBg = isDark ? const Color(0xFF2B2B31) : Colors.white;
    final lineBorder = isDark ? const Color(0xFF383842) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final totalUnits = widget.subject.units.length;
    int completedUnits = 0;
    int totalTopics = 0;
    int completedTopics = 0;

    for (final unit in widget.subject.units) {
      final done = unit.topics.where((t) => t.completed).length;
      if (done == unit.topics.length && unit.topics.isNotEmpty) {
        completedUnits += 1;
      }
      totalTopics += unit.topics.length;
      completedTopics += done;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF1E1523),
                  Color(0xFF26192C),
                  Color(0xFF2C1C34),
                ]
              : const [
                  Color(0xFFFAF5FC),
                  Color(0xFFF3E5F7),
                  Color(0xFFEFE1F2),
                ],
        ),
        border: Border.all(color: lineBorder),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.28 : 0.14),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===================================================================
          // TOP ROW: Grade Badge + Subject Name + Mastery Score
          // ===================================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: raisedBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: lineBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'G12 • NATIONAL CURRICULUM',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subject.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.subject.mastery}%',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: primaryColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MASTERY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===================================================================
          // MIDDLE: Units & Topics Ratios + Linear Progress Bar
          // ===================================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedUnits of $totalUnits Units Mastered',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '$completedTopics / $totalTopics Topics',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 7,
              color: raisedBg,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (widget.subject.mastery / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===================================================================
          // BOTTOM ROW: Last Studied Topic Preview + "Resume Last Note >" CTA
          // ===================================================================
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: lineBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAST STUDIED',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.lastTopicLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                AcedexBounceable(
                  onTap: _handleResumeTap,
                  child: Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoadingNote
                        ? const AcedexDotsLoader(
                            color: Colors.white,
                            dotSize: 4.5,
                            gap: 3.5,
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.ctaLabel ?? 'Resume Last Note',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.1,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
