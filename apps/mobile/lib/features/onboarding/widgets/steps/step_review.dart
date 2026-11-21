import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/animations/bounceable.dart';
import '../../../../core/ui/buttons/acedex_button.dart';
import '../../models/student_registration_draft.dart';
import '../student_id_card.dart';

class StepReview extends StatefulWidget {
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
  State<StepReview> createState() => _StepReviewState();
}

class _StepReviewState extends State<StepReview> {
  final GlobalKey<StudentIdCardState> _cardKey = GlobalKey<StudentIdCardState>();
  bool _isBack = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final softAccent =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
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

                      // Main Title + Flip Pass Pill Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                Text(
                                  'Tap any field to edit, or tap card to flip.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: subtext,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Interactive Flip Pass Button Pill
                          AcedexBounceable(
                            scaleFactor: 0.94,
                            onTap: () {
                              _cardKey.currentState?.toggleFlip();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: softAccent,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedRotateRight01,
                                    color: accent,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isBack ? 'Show Front' : 'Flip Pass',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 180° Flippable Student Candidate Pass
                      StudentIdCard(
                        key: _cardKey,
                        draft: widget.draft,
                        onEditStep: widget.onEditStep,
                        onFlipChanged: (flipped) {
                          setState(() {
                            _isBack = flipped;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      // Helper Note with Rotate Icon (Defensively wrapped to avoid overflow)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedRotateRight01,
                              color: subtext,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _isBack
                                    ? 'Showing Digital Credential Back & Official QR Code'
                                    : 'Tap card to flip & view your digital credential QR',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: subtext,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Create Account Action Button (Positioned at bottom with clean padding)
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 16),
                    child: AcedexButton(
                      label: 'Create account',
                      variant: AcedexButtonVariant.primary,
                      size: AcedexButtonSize.lg,
                      isLoading: widget.isSubmitting,
                      isFullWidth: true,
                      trailingIcon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight01,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: widget.isSubmitting ? null : widget.onSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
