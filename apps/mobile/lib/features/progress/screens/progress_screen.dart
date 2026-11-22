import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';

/// Clean Apple-Style Progress & Performance Analytics Screen (Tab 3: Progress)
class ProgressScreen extends StatelessWidget {
  final UserProfile? user;

  const ProgressScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final metrics = [
      {'title': 'Curriculum Mastery', 'value': '0%', 'caption': '0 of 42 Units Completed', 'icon': HugeIcons.strokeRoundedCheckmarkBadge01, 'color': AppColors.royalPurple},
      {'title': 'Questions Solved', 'value': '0', 'caption': 'Across all enrolled subjects', 'icon': HugeIcons.strokeRoundedTask01, 'color': Color(0xFF0284C7)},
      {'title': 'Average Accuracy', 'value': '--', 'caption': 'National Benchmark: >= 70%', 'icon': HugeIcons.strokeRoundedAnalytics01, 'color': Color(0xFF16A34A)},
      {'title': 'Daily Streak', 'value': '1 Day', 'caption': 'Personal Best: 1 Day', 'icon': HugeIcons.strokeRoundedFire, 'color': isDark ? AppColors.darkWarning : AppColors.warning},
    ];

    final isSocial = (user?.stream ?? 'natural').toLowerCase() == 'social';
    final subjects = isSocial
        ? [
            {'name': 'Mathematics', 'percent': 0.0, 'color': AppColors.royalPurple},
            {'name': 'History', 'percent': 0.0, 'color': Color(0xFFD97706)},
            {'name': 'Geography', 'percent': 0.0, 'color': Color(0xFF16A34A)},
            {'name': 'Economics', 'percent': 0.0, 'color': Color(0xFF0284C7)},
            {'name': 'English', 'percent': 0.0, 'color': Color(0xFF8B5CF6)},
          ]
        : [
            {'name': 'Physics', 'percent': 0.0, 'color': Color(0xFF0284C7)},
            {'name': 'Mathematics', 'percent': 0.0, 'color': AppColors.royalPurple},
            {'name': 'Chemistry', 'percent': 0.0, 'color': Color(0xFF16A34A)},
            {'name': 'Biology', 'percent': 0.0, 'color': Color(0xFFD97706)},
            {'name': 'English', 'percent': 0.0, 'color': Color(0xFF8B5CF6)},
          ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Headline
          Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Diagnostic metrics across curriculum subjects and exam readiness.',
            style: TextStyle(
              fontSize: 13.5,
              color: subtextColor,
            ),
          ),

          const SizedBox(height: 20),

          // 2x2 Metric Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.18,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, i) {
              final m = metrics[i];
              return AcedexCard(
                variant: AcedexCardVariant.raised,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          m['title'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: subtextColor,
                          ),
                        ),
                        HugeIcon(
                          icon: m['icon'] as dynamic,
                          color: m['color'] as Color,
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      m['value'] as String,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      m['caption'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Subject Mastery Breakdown
          AcedexCard(
            variant: AcedexCardVariant.raised,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUBJECT MASTERY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: subtextColor,
                      ),
                    ),
                    const Text(
                      'Goal: 80%+',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.royalPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final sub in subjects) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sub['name'] as String,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${((sub['percent'] as double) * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: sub['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: sub['percent'] as double,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? const Color(0xFF2B2B31)
                                : const Color(0xFFE4E4E8),
                            valueColor: AlwaysStoppedAnimation<Color>(sub['color'] as Color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
