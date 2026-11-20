import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/animations/bounceable.dart';
import '../../../../core/ui/buttons/acedex_button.dart';

class StepGrade extends StatelessWidget {
  final int selectedGrade;
  final ValueChanged<int> onGradeChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepGrade({
    super.key,
    required this.selectedGrade,
    required this.onGradeChanged,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final softAccent = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;

    final isSenior = selectedGrade >= 11;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category Badge
          Text(
            'YOUR STUDIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),

          // Main Title
          Text(
            'Which grade are you in?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            'This helps us tailor your learning experience.',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtext,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 36),

          // 4 Squircle Grade Boxes: G9, G10, G11, G12
          Row(
            children: [9, 10, 11, 12].map((grade) {
              final isSelected = selectedGrade == grade;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: grade < 12 ? 10 : 0,
                  ),
                  child: AcedexBounceable(
                    scaleFactor: 0.94,
                    onTap: () => onGradeChanged(grade),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 82,
                      decoration: BoxDecoration(
                        color: isSelected ? softAccent : surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? accent : line,
                          width: isSelected ? 2.0 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.16),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'G$grade',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isSelected
                                  ? accent
                                  : (isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Grade $grade',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? accent : subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Dynamic Curriculum Hint Banner
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: line, width: 1),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: isSenior
                      ? HugeIcons.strokeRoundedGraduationScroll
                      : HugeIcons.strokeRoundedBookOpen01,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isSenior
                        ? 'Grade $selectedGrade includes Natural & Social Science streams.'
                        : 'Grade $selectedGrade follows the unified general Ethiopian curriculum.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: subtext,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Continue Button
          AcedexButton(
            label: 'Continue',
            variant: AcedexButtonVariant.primary,
            size: AcedexButtonSize.lg,
            isFullWidth: true,
            trailingIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: Colors.white,
              size: 18,
            ),
            onPressed: onContinue,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
