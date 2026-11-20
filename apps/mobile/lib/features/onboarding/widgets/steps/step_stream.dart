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
    final softAccent =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;

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

          // Natural Science Card (Zooms & tilts slightly when selected)
          _AnimatedStreamCard(
            title: 'Natural Science',
            subtitle: 'Physics, Chemistry, Biology, Technical Mathematics',
            badge: 'Engineering & Medicine Track',
            icon: HugeIcons.strokeRoundedAtom02,
            isSelected: isNatural,
            tiltTurns: -0.007, // ~2.5 degrees counterclockwise tilt
            accent: accent,
            softAccent: softAccent,
            surface: surface,
            line: line,
            isDark: isDark,
            onTap: () => onStreamChanged('natural'),
          ),

          const SizedBox(height: 20),

          // Social Science Card (Zooms & tilts slightly when selected)
          _AnimatedStreamCard(
            title: 'Social Science',
            subtitle: 'History, Geography, Economics, Social Mathematics',
            badge: 'Business, Law & Humanities Track',
            icon: HugeIcons.strokeRoundedGlobe02,
            isSelected: !isNatural,
            tiltTurns: 0.007, // ~2.5 degrees clockwise tilt
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
              size: 18,
              color: Colors.white,
            ),
            onPressed: onContinue,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AnimatedStreamCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final List<List<dynamic>> icon;
  final bool isSelected;
  final double tiltTurns;
  final Color accent;
  final Color softAccent;
  final Color surface;
  final Color line;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedStreamCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.isSelected,
    required this.tiltTurns,
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
      child: AnimatedRotation(
        turns: isSelected ? tiltTurns : 0.0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        child: AnimatedScale(
          scale: isSelected ? 1.03 : 0.96,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.52,
            duration: const Duration(milliseconds: 240),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected ? softAccent : surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? accent : line,
                  width: isSelected ? 2.0 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  // Stream Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent.withValues(alpha: 0.22)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? accent.withValues(alpha: 0.35)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: HugeIcon(
                      icon: icon,
                      size: 26,
                      color: isSelected
                          ? accent
                          : (isDark
                              ? AppColors.darkSubtext
                              : AppColors.lightSubtext),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isSelected
                                ? accent
                                : (isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.darkSubtext
                                : AppColors.lightSubtext,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent.withValues(alpha: 0.14)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? accent
                                  : (isDark
                                      ? AppColors.darkSubtext
                                      : AppColors.lightSubtext),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Radio Selector Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? accent : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? accent : line,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
