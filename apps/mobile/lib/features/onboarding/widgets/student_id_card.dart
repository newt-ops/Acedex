import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/student_registration_draft.dart';

/// Clean Apple-Style Digital Student ID Card / Candidate Pass
///
/// Features a refined, crisp appearance with zero distracting neon glows,
/// fully responsive styling for both Light and Dark modes, and interactive tap-to-edit.
class StudentIdCard extends StatelessWidget {
  final StudentRegistrationDraft draft;
  final void Function(int targetStep)? onEditStep;

  const StudentIdCard({
    super.key,
    required this.draft,
    this.onEditStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final softAccent =
        isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final line = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subtext = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;

    final isFemale = draft.gender.toLowerCase() == 'female';
    final isNatural = (draft.stream ?? 'natural').toLowerCase() == 'natural';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B1F) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF382A40)
              : const Color(0xFFE4E4E8),
          width: 1.2,
        ),
        boxShadow: [
          // Clean subtle elevation shadow (ZERO glow)
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Institution Emblem & Security Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: softAccent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedStudentCard,
                        color: accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACEDEX NATIONAL EDUCATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'OFFICIAL CANDIDATE PASS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Clean Verified Pill Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        color: Color(0xFF16A34A),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Container(height: 1, color: line),
            const SizedBox(height: 16),

            // Middle Section: Avatar + Student Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Frame
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: softAccent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: HugeIcon(
                    icon: isFemale
                        ? HugeIcons.strokeRoundedFemale02
                        : HugeIcons.strokeRoundedMale02,
                    color: accent,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Phone + Tap-to-Edit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AcedexBounceable(
                        onTap: () => onEditStep?.call(0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                draft.fullName.isNotEmpty
                                    ? draft.fullName
                                    : 'Abebe Kebede',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedPencilEdit02,
                              color: subtext,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      AcedexBounceable(
                        onTap: () => onEditStep?.call(1),
                        child: Row(
                          children: [
                            Text(
                              draft.phoneNumber.isNotEmpty
                                  ? draft.phoneNumber
                                  : '+251 91 123 4567',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: subtext,
                              ),
                            ),
                            const SizedBox(width: 6),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedPencilEdit02,
                              color: subtext,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Metadata Chips: Gender, Grade, Stream
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Gender Chip
                AcedexBounceable(
                  onTap: () => onEditStep?.call(2),
                  child: _buildChip(
                    icon: isFemale
                        ? HugeIcons.strokeRoundedFemale02
                        : HugeIcons.strokeRoundedMale02,
                    label: isFemale ? 'Female' : 'Male',
                    accent: accent,
                    softAccent: softAccent,
                    textColor: textColor,
                  ),
                ),

                // Grade Chip
                AcedexBounceable(
                  onTap: () => onEditStep?.call(3),
                  child: _buildChip(
                    icon: HugeIcons.strokeRoundedMortarboard02,
                    label: 'Grade ${draft.grade}',
                    accent: accent,
                    softAccent: softAccent,
                    textColor: textColor,
                  ),
                ),

                // Stream Chip (if Senior)
                if (draft.requiresStream)
                  AcedexBounceable(
                    onTap: () => onEditStep?.call(4),
                    child: _buildChip(
                      icon: isNatural
                          ? HugeIcons.strokeRoundedAtom02
                          : HugeIcons.strokeRoundedGlobe02,
                      label: isNatural ? 'Natural Science' : 'Social Science',
                      accent: accent,
                      softAccent: softAccent,
                      textColor: textColor,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Academic Summary Line
            Text(
              draft.academicSummary,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subtext,
              ),
            ),

            const SizedBox(height: 14),
            Container(height: 1, color: line),
            const SizedBox(height: 14),

            // Bottom Bar: Candidate ID & Clean Barcode Graphic
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CANDIDATE ID',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: subtext,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      draft.candidateId,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: accent,
                      ),
                    ),
                  ],
                ),

                // Clean Exam Ticket Barcode Graphic
                _buildBarcode(isDark: isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required List<List<dynamic>> icon,
    required String label,
    required Color accent,
    required Color softAccent,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: softAccent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            color: accent,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode({required bool isDark}) {
    final stripeColor = isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.7);
    final barHeights = [18.0, 22.0, 16.0, 24.0, 18.0, 20.0, 24.0, 16.0, 22.0, 18.0, 24.0, 16.0, 20.0];
    final barWidths = [2.0, 1.5, 3.0, 1.5, 2.0, 3.5, 1.5, 2.0, 1.5, 3.0, 1.5, 2.5, 1.5];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(barHeights.length, (index) {
        return Container(
          width: barWidths[index],
          height: barHeights[index],
          margin: const EdgeInsets.only(right: 2.2),
          decoration: BoxDecoration(
            color: stripeColor,
            borderRadius: BorderRadius.circular(0.8),
          ),
        );
      }),
    );
  }
}
