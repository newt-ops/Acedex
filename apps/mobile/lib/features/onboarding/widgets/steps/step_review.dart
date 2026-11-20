import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/buttons/acedex_button.dart';
import '../../models/student_registration_draft.dart';
import '../student_id_card.dart';

class StepReview extends StatelessWidget {
  final StudentRegistrationDraft draft;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final void Function(int targetStep) onEditStep;
  final VoidCallback onBack;

  const StepReview({
    super.key,
    required this.draft,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onEditStep,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category Badge
          Text(
            'FINAL CHECK',
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
            'Review your details',
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
            'Make sure everything looks right.',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: subtext,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),

          // Digital Student ID Card
          StudentIdCard(
            draft: draft,
            onEditStep: onEditStep,
          ),

          const SizedBox(height: 14),

          // Tap to Edit Helper Note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedEdit02,
                color: subtext,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Tap any field on your pass to edit before creating account',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: subtext,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Create Account Action Button
          AcedexButton(
            label: 'Create account',
            variant: AcedexButtonVariant.primary,
            size: AcedexButtonSize.lg,
            isLoading: isSubmitting,
            isFullWidth: true,
            trailingIcon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: Colors.white,
              size: 18,
            ),
            onPressed: isSubmitting ? null : onSubmit,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
