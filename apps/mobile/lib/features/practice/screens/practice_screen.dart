import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';

/// Clean Apple-Style Practice & Assessments Screen (Tab 2: Elevated Center Action)
class PracticeScreen extends StatelessWidget {
  final UserProfile? user;

  const PracticeScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Headline
          Text(
            'Practice & Assessments',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Solve entrance exam question drills, timed tests, and weakness reviews.',
            style: TextStyle(
              fontSize: 13.5,
              color: subtextColor,
            ),
          ),

          const SizedBox(height: 20),

          // Primary Action Hero Card: EUEE Past National Exams
          AcedexCard(
            variant: AcedexCardVariant.raised,
            onTap: () {
              AcedexToast.show(
                context,
                message: 'Opening National Exam Question Bank...',
                type: AcedexToastType.info,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.royalPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedAward01,
                        color: AppColors.royalPurple,
                        size: 24,
                      ),
                    ),
                    const AcedexBadge(
                      label: 'OFFICIAL EUEE',
                      variant: AcedexBadgeVariant.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Past National Entrance Exams',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '10+ years of verified Ethiopian entrance exams with thorough, step-by-step mathematical & conceptual explanations.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 16),
                AcedexButton(
                  label: 'Start National Exam Drill',
                  variant: AcedexButtonVariant.primary,
                  size: AcedexButtonSize.md,
                  isFullWidth: true,
                  onPressed: () {
                    AcedexToast.show(
                      context,
                      message: 'Launching EUEE exam session...',
                      type: AcedexToastType.success,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Practice Modes Grid (2x2)
          Row(
            children: [
              // Chapter-by-Chapter Quiz
              Expanded(
                child: AcedexCard(
                  variant: AcedexCardVariant.raised,
                  onTap: () {
                    AcedexToast.show(
                      context,
                      message: 'Opening Chapter Quiz selector...',
                      type: AcedexToastType.info,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedNoteEdit,
                          color: Color(0xFF0284C7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chapter Drills',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Unit practice tests',
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Weakness / Missed Questions Bank
              Expanded(
                child: AcedexCard(
                  variant: AcedexCardVariant.raised,
                  onTap: () {
                    AcedexToast.show(
                      context,
                      message: 'Opening Missed Bank...',
                      type: AcedexToastType.info,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkWarning : AppColors.warning)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFire,
                          color: isDark ? AppColors.darkWarning : AppColors.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Missed Bank',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Retry wrong answers',
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Timed Simulator Card
          AcedexCard(
            variant: AcedexCardVariant.flat,
            onTap: () {
              AcedexToast.show(
                context,
                message: 'Timed Simulator coming soon!',
                type: AcedexToastType.info,
              );
            },
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    color: Color(0xFF16A34A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timed Mock Simulator',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Simulate actual EUEE exam conditions under countdown',
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: subtextColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
