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
    final softAccent =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;

    final isSenior = selectedGrade >= 11;

    final gradeDetails = [
      (
        grade: 9,
        label: 'G9',
        title: 'Grade 9',
        track: 'General Curriculum',
        icon: HugeIcons.strokeRoundedBook02,
      ),
      (
        grade: 10,
        label: 'G10',
        title: 'Grade 10',
        track: 'General Curriculum',
        icon: HugeIcons.strokeRoundedMortarboard02,
      ),
      (
        grade: 11,
        label: 'G11',
        title: 'Grade 11',
        track: 'Stream Specialization',
        icon: HugeIcons.strokeRoundedAtom02,
      ),
      (
        grade: 12,
        label: 'G12',
        title: 'Grade 12',
        track: 'National Exam Track',
        icon: HugeIcons.strokeRoundedGlobalEducation,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
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
                    const SizedBox(height: 20),

                    // Flexible Interactive 2x2 Grade Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildGradeCard(
                            detail: gradeDetails[0],
                            isSelected: selectedGrade == 9,
                            accent: accent,
                            softAccent: softAccent,
                            surface: surface,
                            line: line,
                            isDark: isDark,
                            onTap: () => onGradeChanged(9),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGradeCard(
                            detail: gradeDetails[1],
                            isSelected: selectedGrade == 10,
                            accent: accent,
                            softAccent: softAccent,
                            surface: surface,
                            line: line,
                            isDark: isDark,
                            onTap: () => onGradeChanged(10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildGradeCard(
                            detail: gradeDetails[2],
                            isSelected: selectedGrade == 11,
                            accent: accent,
                            softAccent: softAccent,
                            surface: surface,
                            line: line,
                            isDark: isDark,
                            onTap: () => onGradeChanged(11),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGradeCard(
                            detail: gradeDetails[3],
                            isSelected: selectedGrade == 12,
                            accent: accent,
                            softAccent: softAccent,
                            surface: surface,
                            line: line,
                            isDark: isDark,
                            onTap: () => onGradeChanged(12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Hint banner based on grade level
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: line, width: 1),
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: isSenior
                                ? HugeIcons.strokeRoundedHierarchy
                                : HugeIcons.strokeRoundedCheckmarkBadge01,
                            color: accent,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isSenior
                                  ? 'Grades 11 & 12 feature Natural or Social Science stream tracks.'
                                  : 'Grades 9 & 10 follow the Ethiopian National Unified Curriculum.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkSubtext
                                    : AppColors.lightSubtext,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: 16),

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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeCard({
    required ({int grade, String label, String title, String track, List<List<dynamic>> icon})
        detail,
    required bool isSelected,
    required Color accent,
    required Color softAccent,
    required Color surface,
    required Color line,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AcedexBounceable(
      scaleFactor: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
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
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Icon + Selection Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: 0.2)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: detail.icon,
                    size: 19,
                    color: isSelected ? accent : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
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
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedTick02,
                            size: 12,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle & Bottom: Code + Full Title + Track
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  detail.label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: isSelected
                        ? accent
                        : (isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    detail.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? accent
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              detail.track,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
