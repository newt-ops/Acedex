import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/buttons/acedex_button.dart';
import '../models/student_registration_draft.dart';

/// Celebratory Apple-Style Registration Success Modal Dialog
///
/// Displayed immediately upon successful backend registration before
/// redirecting the candidate to the Login screen with their normalized credentials.
class RegistrationSuccessDialog extends StatelessWidget {
  final StudentRegistrationDraft draft;
  final VoidCallback onContinueToLogin;

  const RegistrationSuccessDialog({
    super.key,
    required this.draft,
    required this.onContinueToLogin,
  });

  static Future<void> show(
    BuildContext context, {
    required StudentRegistrationDraft draft,
    required VoidCallback onContinueToLogin,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Registration Success',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return RegistrationSuccessDialog(
          draft: draft,
          onContinueToLogin: onContinueToLogin,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final softAccent =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B1B1F).withValues(alpha: 0.95)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFB866CF).withValues(alpha: 0.3)
                      : const Color(0xFF8A2BA3).withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: isDark ? 0.35 : 0.2),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration Badge Insignia
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: softAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                      color: accent,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  Text(
                    'Account Created!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Student Greeting & Candidate Pass Chip
                  Text(
                    'Welcome to Acedex, ${draft.fullName.trim()}!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Candidate ID Pass Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: line, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedStudentCard,
                          color: accent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          draft.candidateId,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subtitle Explanation
                  Text(
                    'Your official student pass has been issued. Sign in with your phone and PIN to start learning.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: subtext,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  AcedexButton(
                    label: 'Continue to Sign In',
                    variant: AcedexButtonVariant.primary,
                    size: AcedexButtonSize.lg,
                    isFullWidth: true,
                    trailingIcon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: onContinueToLogin,
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
