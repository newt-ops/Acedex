import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../../../core/ui/inputs/acedex_theme_toggle.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep; // 0-indexed (0 to totalSteps - 1)
  final int totalSteps; // 6 or 7
  final VoidCallback? onBack;
  final VoidCallback? onSignInTap;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.onSignInTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Brand / Back + Step Counter / Sign In Link + Flexible Theme Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Back button (if step > 0) or Brand
              if (currentStep > 0 && onBack != null)
                AcedexBounceable(
                  onTap: onBack,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: accent,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Acedex',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: accent,
                      ),
                    ),
                  ],
                ),

              // Right: Sign In Link (if step 0) + Flexible 3-Mode Theme Toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentStep == 0 && onSignInTap != null) ...[
                    AcedexBounceable(
                      onTap: onSignInTap,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Flexible 3-Mode Theme Segmented Toggle
                  const AcedexThemeToggle(compact: true),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Segmented Progress Bar (7 or 6 squircle pills)
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index <= currentStep;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < totalSteps - 1 ? 5 : 0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isCompleted ? accent : line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
