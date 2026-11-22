import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';

/// Clean Apple-Style Dashboard Screen (Tab 0: Home)
class DashboardScreen extends StatelessWidget {
  final UserProfile? user;
  final VoidCallback? onNavigateToStudy;
  final VoidCallback? onNavigateToPractice;

  const DashboardScreen({
    super.key,
    this.user,
    this.onNavigateToStudy,
    this.onNavigateToPractice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final displayName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : 'Master Your Curriculum';
    final gradeLabel = user?.gradeLabel ?? 'Grade 12 • Natural Science';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Headline & Grade Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personalized national exam preparation',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AcedexBadge(
                label: gradeLabel,
                variant: AcedexBadgeVariant.primary,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Daily Target Card
          AcedexCard(
            variant: AcedexCardVariant.raised,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.royalPurple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedTarget01,
                            color: AppColors.royalPurple,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Today's Goal",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '0 / 15 Solved',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.0,
                    minHeight: 6,
                    backgroundColor: isDark ? const Color(0xFF2B2B31) : const Color(0xFFE4E4E8),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.royalPurple),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Solve 15 practice questions today to maintain your daily streak.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Action Cards (Study & Practice)
          Row(
            children: [
              Expanded(
                child: AcedexCard(
                  variant: AcedexCardVariant.raised,
                  onTap: () {
                    if (onNavigateToStudy != null) {
                      onNavigateToStudy!();
                    } else {
                      AcedexToast.show(
                        context,
                        message: 'Switching to Study curriculum...',
                        type: AcedexToastType.info,
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedBookOpen01,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Study Units',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Read notes & summary',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AcedexCard(
                  variant: AcedexCardVariant.raised,
                  onTap: () {
                    if (onNavigateToPractice != null) {
                      onNavigateToPractice!();
                    } else {
                      AcedexToast.show(
                        context,
                        message: 'Opening Practice exam drills...',
                        type: AcedexToastType.info,
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkWarning : AppColors.warning)
                              .withValues(alpha: 0.15),
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
                        'Quick Drill',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Timed quiz questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // National Entrance Exam Track Banner
          AcedexCard(
            variant: AcedexCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedGraduationScroll,
                      color: AppColors.royalPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ESSLCE 2026 Preparation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Aligned with the Ethiopian Ministry of Education curriculum. All question banks cover past national exams with step-by-step solutions.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
