import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/progress_models.dart';

/// Card 2: Interactive Study & Accuracy Analytics Chart (Tap & Scrub)
class StudyAnalyticsChartCard extends StatefulWidget {
  final TimeframeData data;

  const StudyAnalyticsChartCard({super.key, required this.data});

  @override
  State<StudyAnalyticsChartCard> createState() =>
      _StudyAnalyticsChartCardState();
}

class _StudyAnalyticsChartCardState extends State<StudyAnalyticsChartCard> {
  ChartMetricType _metric = ChartMetricType.hours;
  late int _activeIdx;

  @override
  void initState() {
    super.initState();
    _activeIdx = (widget.data.points.length - 1).clamp(0, 6);
  }

  @override
  void didUpdateWidget(covariant StudyAnalyticsChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _activeIdx = (widget.data.points.length - 1).clamp(0, 6);
    }
  }

  void _selectColumnFromDx(double dx, double width) {
    if (width <= 0) return;
    final slotW = width / widget.data.points.length;
    final idx = (dx / slotW).floor().clamp(0, widget.data.points.length - 1);
    if (idx != _activeIdx) {
      setState(() => _activeIdx = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark
        ? AppColors.accentSoftDark
        : AppColors.accentSoftLight;
    final subtextColor = isDark
        ? AppColors.darkSubtext
        : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final points = widget.data.points;
    final activePt = points.isEmpty
        ? const TimeframePoint(short: '-', label: 'No Activity', hours: 0, qs: 0, acc: 0)
        : points[_activeIdx.clamp(0, points.length - 1)];
    final dailyTargetHours = (widget.data.dailyGoalMinutes / 60).clamp(0.5, 8.0);
    final goalLabel = dailyTargetHours == dailyTargetHours.roundToDouble()
        ? '${dailyTargetHours.toInt()}h'
        : '${dailyTargetHours.toStringAsFixed(1)}h';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lineColor),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title + Gliding Segmented Control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study & Accuracy Trend',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _metric == ChartMetricType.hours
                          ? 'Dashed line: $goalLabel daily target'
                          : 'Dashed line: 80% EUEE accuracy goal',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // 2-Tab Segmented Control
              Container(
                height: 32,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: lineColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ChartMetricTab(
                      label: 'Study Hours',
                      isSelected: _metric == ChartMetricType.hours,
                      accentColor: accentColor,
                      accentSoftColor: accentSoftColor,
                      subtextColor: subtextColor,
                      onTap: () =>
                          setState(() => _metric = ChartMetricType.hours),
                    ),
                    _ChartMetricTab(
                      label: 'Quiz Accuracy',
                      isSelected: _metric == ChartMetricType.accuracy,
                      accentColor: accentColor,
                      accentSoftColor: accentSoftColor,
                      subtextColor: subtextColor,
                      onTap: () =>
                          setState(() => _metric = ChartMetricType.accuracy),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Apple-Style Inline Floating Readout Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lineColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activePt.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${activePt.hours.toStringAsFixed(1)}h',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text('•', style: TextStyle(color: lineColor)),
                    ),
                    Text(
                      '${activePt.qs} Qs',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text('•', style: TextStyle(color: lineColor)),
                    ),
                    Text(
                      '${activePt.acc}%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkSuccess
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Interactive Scrubbable Chart Area
          LayoutBuilder(
            builder: (context, constraints) {
              final chartW = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _selectColumnFromDx(details.localPosition.dx, chartW),
                onHorizontalDragUpdate: (details) =>
                    _selectColumnFromDx(details.localPosition.dx, chartW),
                child: SizedBox(
                  height: 154,
                  width: chartW,
                  child: CustomPaint(
                    size: Size(chartW, 154),
                    painter: _StudyAnalyticsChartPainter(
                      points: points,
                      activeIdx: _activeIdx,
                      metric: _metric,
                      dailyTargetHours: dailyTargetHours,
                      accentColor: accentColor,
                      accentSoftColor: accentSoftColor,
                      lineColor: lineColor,
                      textColor: theme.colorScheme.onSurface,
                      subtextColor: subtextColor,
                      cardBg: cardBg,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Footer Totals Strip
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: lineColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'TOTAL STUDY',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.footerHours,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: lineColor),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'AVG ACCURACY',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.footerAcc,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 26, color: lineColor),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'QUESTIONS',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.footerQs,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
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

class _ChartMetricTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentColor;
  final Color accentSoftColor;
  final Color subtextColor;
  final VoidCallback onTap;

  const _ChartMetricTab({
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.accentSoftColor,
    required this.subtextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AcedexBounceable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? accentSoftColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.5),
          border: isSelected ? Border.all(color: accentColor, width: 1) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? accentColor : subtextColor,
          ),
        ),
      ),
    );
  }
}

class _StudyAnalyticsChartPainter extends CustomPainter {
  final List<TimeframePoint> points;
  final int activeIdx;
  final ChartMetricType metric;
  final double dailyTargetHours;
  final Color accentColor;
  final Color accentSoftColor;
  final Color lineColor;
  final Color textColor;
  final Color subtextColor;
  final Color cardBg;

  _StudyAnalyticsChartPainter({
    required this.points,
    required this.activeIdx,
    required this.metric,
    required this.dailyTargetHours,
    required this.accentColor,
    required this.accentSoftColor,
    required this.lineColor,
    required this.textColor,
    required this.subtextColor,
    required this.cardBg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final chartBottom = size.height - 28;
    const chartTop = 16.0;
    final chartH = chartBottom - chartTop;
    final count = points.length;
    final colSlotW = size.width / count;
    const barW = 20.0;

    final isHours = metric == ChartMetricType.hours;
    double highestHour = dailyTargetHours;
    if (isHours) {
      for (final p in points) {
        if (p.hours > highestHour) highestHour = p.hours;
      }
    }
    final maxVal = isHours ? (highestHour * 1.25).clamp(2.0, 12.0) : 100.0;
    final minVal = 0.0;
    final targetVal = isHours ? dailyTargetHours : 80.0;

    double getY(double val) {
      final norm = ((val - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
      return chartBottom - norm * chartH;
    }

    // 1. Draw Baseline
    final basePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(4, chartBottom),
      Offset(size.width - 4, chartBottom),
      basePaint,
    );

    // 2. Draw Dashed Daily Goal Line
    final targetY = getY(targetVal);
    final dashPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 4;
    while (startX < size.width - 4) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset((startX + dashWidth).clamp(4, size.width - 4), targetY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // 3. Collect coordinates
    final coords = <Offset>[];
    for (int i = 0; i < count; i++) {
      final val = isHours ? points[i].hours : points[i].acc.toDouble();
      final cx = i * colSlotW + colSlotW / 2;
      final cy = getY(val);
      coords.add(Offset(cx, cy));
    }

    // 4. Draw Bars & Labels
    for (int i = 0; i < count; i++) {
      final c = coords[i];
      final val = isHours ? points[i].hours : points[i].acc.toDouble();
      final isSelected = i == activeIdx;
      final barH = val <= 0 ? 3.0 : (chartBottom - c.dy).clamp(6.0, chartH);

      final barRect = Rect.fromCenter(
        center: Offset(c.dx, chartBottom - barH / 2),
        width: barW,
        height: barH,
      );

      final barPaint = Paint()
        ..color = isSelected ? accentColor : accentSoftColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(6)),
        barPaint,
      );

      // Label below bar
      final textSpan = TextSpan(
        text: points[i].short,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? accentColor : subtextColor,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(c.dx - textPainter.width / 2, chartBottom + 8),
      );
    }

    // 5. Draw Smooth Trend Curve (Cubic Bezier)
    if (coords.length > 1) {
      final path = Path()..moveTo(coords[0].dx, coords[0].dy);
      for (int i = 0; i < coords.length - 1; i++) {
        final p0 = coords[i];
        final p1 = coords[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }

      final curvePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, curvePaint);
    }

    // 6. Draw Trend Nodes
    for (int i = 0; i < count; i++) {
      final c = coords[i];
      final isSelected = i == activeIdx;

      if (isSelected) {
        // Outer halo
        final haloPaint = Paint()..color = accentColor.withValues(alpha: 0.26);
        canvas.drawCircle(c, 7, haloPaint);

        // Core dot with stroke
        final dotBg = Paint()..color = cardBg;
        canvas.drawCircle(c, 4, dotBg);
        final dotStroke = Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        canvas.drawCircle(c, 4, dotStroke);
      } else {
        final dotBg = Paint()..color = cardBg;
        canvas.drawCircle(c, 2.5, dotBg);
        final dotStroke = Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
        canvas.drawCircle(c, 2.5, dotStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StudyAnalyticsChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.activeIdx != activeIdx ||
        oldDelegate.metric != metric ||
        oldDelegate.dailyTargetHours != dailyTargetHours ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.lineColor != lineColor;
  }
}
