import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../models/onboarding_item.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentSoft =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Icon Hero Container with Apple-style Squircle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                item.icon,
                size: 64,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Category Badge
          AcedexBadge(
            label: item.badgeText,
            variant: AcedexBadgeVariant.primary,
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: theme.colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
