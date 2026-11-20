import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/animations/bounceable.dart';
import '../../../../core/ui/buttons/acedex_button.dart';

class StepGender extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepGender({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category Badge
          Text(
            'ABOUT YOU',
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
            'Select your gender',
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
            'Choose the option that feels right for you.',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtext,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 36),

          // Male and Female Squircle Cards Row
          Row(
            children: [
              Expanded(
                child: _GenderCard(
                  label: 'Male',
                  icon: HugeIcons.strokeRoundedMale02,
                  isSelected: selectedGender.toLowerCase() == 'male',
                  accent: accent,
                  softAccent: softAccent,
                  surface: surface,
                  line: line,
                  isDark: isDark,
                  onTap: () => onGenderChanged('male'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _GenderCard(
                  label: 'Female',
                  icon: HugeIcons.strokeRoundedFemale02,
                  isSelected: selectedGender.toLowerCase() == 'female',
                  accent: accent,
                  softAccent: softAccent,
                  surface: surface,
                  line: line,
                  isDark: isDark,
                  onTap: () => onGenderChanged('female'),
                ),
              ),
            ],
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

class _GenderCard extends StatelessWidget {
  final String label;
  final List<List<dynamic>> icon;
  final bool isSelected;
  final Color accent;
  final Color softAccent;
  final Color surface;
  final Color line;
  final bool isDark;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.softAccent,
    required this.surface,
    required this.line,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AcedexBounceable(
      scaleFactor: 0.95,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? softAccent : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accent : line,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Radio Dot Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accent : line,
                  width: isSelected ? 6.0 : 1.5,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),

            // Icon + Label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HugeIcon(
                  icon: icon,
                  color: isSelected ? accent : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
