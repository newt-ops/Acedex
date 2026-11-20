import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/animations/bounceable.dart';
import '../../../../core/ui/buttons/acedex_button.dart';

class StepStream extends StatelessWidget {
  final String selectedStream; // 'natural' | 'social'
  final ValueChanged<String> onStreamChanged;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const StepStream({
    super.key,
    required this.selectedStream,
    required this.onStreamChanged,
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

    final isNatural = selectedStream.toLowerCase() == 'natural';

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
            'Choose your stream',
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
            "Pick the subjects you're focused on.",
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtext,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 32),

          // Natural Science Card
          _StreamCard(
            title: 'Natural Science',
            subtitle: 'Physics, Chemistry, Biology, Technical Math',
            icon: HugeIcons.strokeRoundedAtom02,
            isSelected: isNatural,
            accent: accent,
            softAccent: softAccent,
            surface: surface,
            line: line,
            isDark: isDark,
            onTap: () => onStreamChanged('natural'),
          ),

          const SizedBox(height: 14),

          // Social Science Card
          _StreamCard(
            title: 'Social Science',
            subtitle: 'History, Geography, Economics, Social Math',
            icon: HugeIcons.strokeRoundedGlobe02,
            isSelected: !isNatural,
            accent: accent,
            softAccent: softAccent,
            surface: surface,
            line: line,
            isDark: isDark,
            onTap: () => onStreamChanged('social'),
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

class _StreamCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<List<dynamic>> icon;
  final bool isSelected;
  final Color accent;
  final Color softAccent;
  final Color surface;
  final Color line;
  final bool isDark;
  final VoidCallback onTap;

  const _StreamCard({
    required this.title,
    required this.subtitle,
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
      scaleFactor: 0.96,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            // Radio Indicator Circle
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
            const SizedBox(width: 16),

            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.16)
                    : (isDark ? AppColors.darkLine : AppColors.lightLine),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: HugeIcon(
                icon: icon,
                color: isSelected
                    ? accent
                    : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
