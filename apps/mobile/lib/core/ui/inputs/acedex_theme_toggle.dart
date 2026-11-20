import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../main.dart';
import '../../theme/app_colors.dart';
import '../animations/bounceable.dart';

/// Apple-Style Flexible 3-Mode Theme Segmented Control
///
/// Supports System, Light, and Dark modes with fluid animated sliding
/// indicator, continuous squircles, tactile haptic feedback, and flexible layout.
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

        final modes = [
          (ThemeMode.system, HugeIcons.strokeRoundedLaptop, 'System'),
          (ThemeMode.light, HugeIcons.strokeRoundedSun02, 'Light'),
          (ThemeMode.dark, HugeIcons.strokeRoundedMoon02, 'Dark'),
        ];

        final selectedIndex = modes.indexWhere((m) => m.$1 == currentMode);
        final activeIndex = selectedIndex >= 0 ? selectedIndex : 0;

        return Container(
          height: compact ? 32 : 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: line, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(modes.length, (index) {
              final mode = modes[index].$1;
              final icon = modes[index].$2;
              final label = modes[index].$3;
              final isSelected = activeIndex == index;

              return AcedexBounceable(
                scaleFactor: 0.94,
                onTap: () {
                  HapticFeedback.selectionClick();
                  AcedexApp.setThemeMode(mode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppColors.darkAccentSoft
                            : AppColors.lightAccentSoft)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: isSelected
                        ? Border.all(
                            color: accent.withValues(alpha: 0.4),
                            width: 1,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: icon,
                        size: compact ? 14 : 16,
                        color: isSelected ? accent : subtext,
                      ),
                      if (!compact) ...[
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? accent : subtext,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
