import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../main.dart';
import '../../theme/app_colors.dart';
import '../animations/bounceable.dart';

/// Cupertino-Grade Icon-Only 3-Mode Theme Segmented Control
///
/// Clean, symmetrical 3-option control displaying only icons for
/// System, Light, and Dark modes with a fluid sliding glider pill,
/// continuous squircles, and tactile haptic feedback.
class AcedexThemeToggle extends StatelessWidget {
  final bool compact;

  const AcedexThemeToggle({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AcedexApp.themeModeNotifier,
      builder: (context, currentMode, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
        final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        final line = isDark ? AppColors.darkLine : AppColors.lightLine;
        final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

        final modes = const [
          (ThemeMode.system, HugeIcons.strokeRoundedLaptop, 'System'),
          (ThemeMode.light, HugeIcons.strokeRoundedSun02, 'Light'),
          (ThemeMode.dark, HugeIcons.strokeRoundedMoon02, 'Dark'),
        ];

        final selectedIndex = modes.indexWhere((m) => m.$1 == currentMode);
        final activeIndex = selectedIndex >= 0 ? selectedIndex : 0;

        final slotWidth = compact ? 30.0 : 34.0;
        final slotHeight = compact ? 26.0 : 28.0;
        final iconSize = compact ? 14.0 : 15.5;

        return Container(
          height: slotHeight + 6.0,
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: line, width: 1.0),
          ),
          child: Stack(
            children: [
              // Sliding Animated Glider Pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: activeIndex * slotWidth,
                top: 0,
                width: slotWidth,
                height: slotHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: isDark ? 0.25 : 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Icon Buttons Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(modes.length, (index) {
                  final mode = modes[index].$1;
                  final icon = modes[index].$2;
                  final tooltip = modes[index].$3;
                  final isSelected = activeIndex == index;

                  return Tooltip(
                    message: tooltip,
                    child: AcedexBounceable(
                      scaleFactor: 0.90,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        AcedexApp.setThemeMode(mode);
                      },
                      child: SizedBox(
                        width: slotWidth,
                        height: slotHeight,
                        child: Center(
                          child: HugeIcon(
                            icon: icon,
                            size: iconSize,
                            color: isSelected ? accent : subtext,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
