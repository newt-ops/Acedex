import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/progress_models.dart';

/// Card 3: 28-Day Study Consistency Heatmap (4×7 Royal Purple Intensity Grid)
class ConsistencyHeatmapCard extends StatefulWidget {
  final List<HeatmapDay> days;

  const ConsistencyHeatmapCard({
    super.key,
    required this.days,
  });

  @override
  State<ConsistencyHeatmapCard> createState() => _ConsistencyHeatmapCardState();
}

class _ConsistencyHeatmapCardState extends State<ConsistencyHeatmapCard> {
  late int _selectedIdx;

  @override
  void initState() {
    super.initState();
    _selectedIdx = (widget.days.length - 1).clamp(0, 27);
  }

  Color _getHeatColor(int level, bool isDark) {
    if (isDark) {
      switch (level) {
        case 1:
          return const Color(0xFF3D2446);
        case 2:
          return const Color(0xFF643773);
        case 3:
          return const Color(0xFF8F4DA4);
        case 4:
          return const Color(0xFFB866CF);
        case 0:
        default:
          return const Color(0xFF232329);
      }
    } else {
      switch (level) {
        case 1:
          return const Color(0xFFE5C8ED);
        case 2:
          return const Color(0xFFC988DB);
        case 3:
          return const Color(0xFFA64DBE);
        case 4:
          return const Color(0xFF8A2BA3);
        case 0:
        default:
          return const Color(0xFFECECF0);
      }
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
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final selectedDay = widget.days[_selectedIdx.clamp(0, widget.days.length - 1)];
    final selectedInfoText = selectedDay.hours > 0
        ? '${selectedDay.date}: ${selectedDay.hours.toStringAsFixed(1)}h • ${selectedDay.acc}% acc'
        : '${selectedDay.date}: Rest & Recovery Day';

    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
          // Header: Title & Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '28-Day Consistency',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedInfoText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentSoftColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '12d Streak',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: lineColor),
                    ),
                    child: Text(
                      'Best 19d',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weekday Micro Labels
          Row(
            children: [
              for (final w in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // 4x7 Heatmap Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.days.length,
            itemBuilder: (context, idx) {
              final day = widget.days[idx];
              final isSelected = idx == _selectedIdx;
              final cellColor = _getHeatColor(day.level, isDark);

              return AcedexBounceable(
                onTap: () {
                  setState(() => _selectedIdx = idx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                      width: isSelected ? 1.8 : 0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF8A2BA3).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Intensity Legend Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tap any day to inspect',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Less',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  for (int lvl = 0; lvl <= 4; lvl++) ...[
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: _getHeatColor(lvl, isDark),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Text(
                    'More',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
