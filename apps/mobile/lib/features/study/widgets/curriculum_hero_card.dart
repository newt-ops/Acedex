import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/progress/acedex_dots_loader.dart';
import '../models/study_models.dart';

/// Active Subject Curriculum Hero Card (Component 2)
///
/// Features:
/// - Badge: "G12 • NATIONAL CURRICULUM"
/// - Active Subject Title and "X of Y Units Completed"
/// - Custom Animated Circular SVG Mastery Ring with central percentage and "MASTERY" label
/// - Linear mastery progress bar
/// - "UP NEXT" preview with dynamic "Continue [Code] >" CTA button
/// - Horizontal `AcedexDotsLoader` for smooth loading (Zero circular spinners!)
class CurriculumHeroCard extends StatefulWidget {
  final SubjectCurriculum subject;
  final String lastTopicLabel;
  final VoidCallback onResumeNote;
  final String? ctaLabel;
  final int grade;

  const CurriculumHeroCard({
    super.key,
    required this.subject,
    required this.lastTopicLabel,
    required this.onResumeNote,
    this.ctaLabel,
    this.grade = 12,
  });

  @override
  State<CurriculumHeroCard> createState() => _CurriculumHeroCardState();
}

class _CurriculumHeroCardState extends State<CurriculumHeroCard> {
  bool _isLoadingNote = false;

  void _handleResumeTap() {
    if (_isLoadingNote) return;
    setState(() => _isLoadingNote = true);

    Future.delayed(const Duration(milliseconds: 500), () {
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
    final lineBorder = isDark ? const Color(0xFF383842) : const Color(0xFFE4E4E8);
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final totalUnits = widget.subject.units.length;
    final completedUnits = widget.subject.units.where((u) => u.isCompleted).length;

    // Determine the "UP NEXT" unit
    StudyUnit? upNextUnit;
    for (final unit in widget.subject.units) {
      if (!unit.isCompleted) {
        upNextUnit = unit;
        break;
      }
    }
    upNextUnit ??= widget.subject.units.isNotEmpty ? widget.subject.units.first : null;

    final upNextTitle = upNextUnit != null
        ? '${upNextUnit.code} • ${upNextUnit.title}'
        : widget.lastTopicLabel;

    final dynamicCta = widget.ctaLabel ??
        (upNextUnit != null
            ? (completedUnits == totalUnits && totalUnits > 0
                ? 'Review ${upNextUnit.code}'
                : 'Continue ${upNextUnit.code}')
            : 'Explore Units');

    final masteryPct = widget.subject.mastery.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF211826),
                  Color(0xFF1C1722),
                  Color(0xFF18181F),
                ]
              : const [
                  Color(0xFFFBF6FD),
                  Color(0xFFF4E9F8),
                  Color(0xFFEFE2F4),
                ],
        ),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: isDark ? 0.24 : 0.12),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===================================================================
          // TOP ROW: Subject Name + Circular Mastery Ring
          // ===================================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      totalUnits > 0
                          ? '$completedUnits of $totalUnits Units Completed'
                          : '${widget.subject.mastery}% Mastery Score',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Animated Circular Mastery Ring
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(68, 68),
                      painter: _MasteryRingPainter(
                        progress: masteryPct / 100.0,
                        trackColor: primaryColor.withValues(alpha: isDark ? 0.20 : 0.14),
                        progressColor: primaryColor,
                        strokeWidth: 5.5,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$masteryPct%',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          'MASTERY',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: subtextColor,
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

          // ===================================================================
          // MIDDLE: Linear Mastery Progress Bar
          // ===================================================================
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 7,
              color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (totalUnits > 0 ? (completedUnits / totalUnits) : (masteryPct / 100))
                      .clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          isDark ? const Color(0xFFC478D8) : const Color(0xFF782390),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===================================================================
          // BOTTOM ROW: UP NEXT Preview + "Continue U3 >" CTA Button
          // ===================================================================
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: lineBorder.withValues(alpha: 0.65)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UP NEXT',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        upNextTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
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
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.28),
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
                                dynamicCta,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
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

/// Custom Circular Arc Painter for Mastery Ring
class _MasteryRingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _MasteryRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MasteryRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
