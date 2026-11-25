import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/progress_models.dart';

/// Card 1: EUEE Exam Readiness Hero Card & Interactive Pillar Breakdown
class ReadinessHeroCard extends StatefulWidget {
  final TimeframeData data;
  final ReadinessPillarType activePillar;
  final ValueChanged<ReadinessPillarType> onPillarSelected;
  final VoidCallback onOpenSimulator;

  const ReadinessHeroCard({
    super.key,
    required this.data,
    required this.activePillar,
    required this.onPillarSelected,
    required this.onOpenSimulator,
  });

  @override
  State<ReadinessHeroCard> createState() => _ReadinessHeroCardState();
}

class _ReadinessHeroCardState extends State<ReadinessHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _gaugeAnimation;
  bool _isLoadingSimulator = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _gaugeAnimation = Tween<double>(
      begin: 0,
      end: widget.data.readinessPct / 100,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant ReadinessHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.readinessPct != widget.data.readinessPct) {
      _gaugeAnimation = Tween<double>(
        begin: _gaugeAnimation.value,
        end: widget.data.readinessPct / 100,
      ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
      _animCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSimulatorTap() async {
    if (_isLoadingSimulator) return;
    setState(() => _isLoadingSimulator = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() => _isLoadingSimulator = false);
      widget.onOpenSimulator();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final heroGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1523), Color(0xFF26192D), Color(0xFF2D1D36)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF5FC), Color(0xFFF3E4F8), Color(0xFFECE0F3)],
          );

    return Container(
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lineColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BA3).withValues(alpha: isDark ? 0.28 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Circular SVG Gauge + Projected Score Headline
          Row(
            children: [
              // Circular Gauge
              SizedBox(
                width: 86,
                height: 86,
                child: AnimatedBuilder(
                  animation: _gaugeAnimation,
                  builder: (context, _) {
                    final currentPct = (_gaugeAnimation.value * 100).round();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(86, 86),
                          painter: _ReadinessGaugePainter(
                            progress: _gaugeAnimation.value,
                            trackColor: lineColor,
                            progressColor: accentColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$currentPct%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'READY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Headline & Projection Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EUEE READINESS',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: subtextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.data.delta,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Est. ${widget.data.projectedScore} / 600 • ${widget.data.percentile}',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.data.subcopy,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3 Interactive Readiness Pillar Breakdown Bars
          _PillarRow(
            type: ReadinessPillarType.coverage,
            valuePct: widget.data.coveragePct,
            isSelected: widget.activePillar == ReadinessPillarType.coverage,
            accentColor: accentColor,
            accentSoftColor: accentSoftColor,
            lineColor: lineColor,
            cardBg: cardBg,
            onTap: () => widget.onPillarSelected(ReadinessPillarType.coverage),
          ),
          const SizedBox(height: 6),
          _PillarRow(
            type: ReadinessPillarType.accuracy,
            valuePct: widget.data.accuracyPct,
            isSelected: widget.activePillar == ReadinessPillarType.accuracy,
            accentColor: accentColor,
            accentSoftColor: accentSoftColor,
            lineColor: lineColor,
            cardBg: cardBg,
            onTap: () => widget.onPillarSelected(ReadinessPillarType.accuracy),
          ),
          const SizedBox(height: 6),
          _PillarRow(
            type: ReadinessPillarType.consistency,
            valuePct: widget.data.consistencyPct,
            isSelected: widget.activePillar == ReadinessPillarType.consistency,
            accentColor: accentColor,
            accentSoftColor: accentSoftColor,
            lineColor: lineColor,
            cardBg: cardBg,
            onTap: () => widget.onPillarSelected(ReadinessPillarType.consistency),
          ),

          const SizedBox(height: 10),

          // Crisp Pillar Explanation Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lineColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 5, right: 8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    ProgressData.getPillarExplanation(
                      widget.activePillar,
                      widget.data,
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: subtextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Simulate EUEE Score > CTA Button
          AcedexBounceable(
            onTap: _isLoadingSimulator ? null : _handleSimulatorTap,
            child: Container(
              height: 42,
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
              child: _isLoadingSimulator
                  ? const AcedexDotsLoader(
                      color: Colors.white,
                      dotSize: 5,
                      gap: 4,
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Simulate EUEE Score',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarRow extends StatelessWidget {
  final ReadinessPillarType type;
  final int valuePct;
  final bool isSelected;
  final Color accentColor;
  final Color accentSoftColor;
  final Color lineColor;
  final Color cardBg;
  final VoidCallback onTap;

  const _PillarRow({
    required this.type,
    required this.valuePct,
    required this.isSelected,
    required this.accentColor,
    required this.accentSoftColor,
    required this.lineColor,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AcedexBounceable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentSoftColor : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : lineColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$valuePct%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: valuePct / 100,
                minHeight: 5,
                backgroundColor: lineColor,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ReadinessGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 15) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReadinessGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
