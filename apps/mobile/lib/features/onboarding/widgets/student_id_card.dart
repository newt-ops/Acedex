import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/student_registration_draft.dart';

/// Apple-Style Digital Student ID Card / Exam Candidate Pass
///
/// Presented in the final onboarding review screen to give students a tangible,
/// delightful sense of academic credential ownership before account creation.
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
    final isFemale = draft.gender.toLowerCase() == 'female';
    final isNatural = (draft.stream ?? 'natural').toLowerCase() == 'natural';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B0B24),
            Color(0xFF2C103A),
            Color(0xFF16081E),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFB866CF).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BA3).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Holographic Ambient Orbs
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFB866CF).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8A2BA3).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Card Content
          Padding(
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF8A2BA3).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFB866CF)
                                  .withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedStudentCard,
                            color: Color(0xFFEFE1F2),
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
                                letterSpacing: 1.1,
                                color: const Color(0xFFB866CF),
                              ),
                            ),
                            Text(
                              'OFFICIAL CANDIDATE PASS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Verified Smart Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color:
                              const Color(0xFFFBBF24).withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedCardSim,
                            color: Color(0xFFFBBF24),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VERIFIED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 18),

                // Center Row: Student Avatar + Details + Candidate ID
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar Box (Tap to jump to Gender step 2)
                    AcedexBounceable(
                      onTap: onEditStep != null ? () => onEditStep!(2) : null,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF8A2BA3).withValues(alpha: 0.45),
                              const Color(0xFFB866CF).withValues(alpha: 0.25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFB866CF)
                                .withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: HugeIcon(
                          icon: isFemale
                              ? HugeIcons.strokeRoundedFemale02
                              : HugeIcons.strokeRoundedMale02,
                          color: const Color(0xFFEFE1F2),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Student Name & Phone (Tap to jump to Name/Phone)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AcedexBounceable(
                            onTap: onEditStep != null
                                ? () => onEditStep!(0)
                                : null,
                            child: Text(
                              draft.fullName.isNotEmpty
                                  ? draft.fullName
                                  : 'Candidate Name',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          AcedexBounceable(
                            onTap: onEditStep != null
                                ? () => onEditStep!(1)
                                : null,
                            child: Text(
                              draft.phoneNumber.isNotEmpty
                                  ? draft.phoneNumber
                                  : '+251 90 000 0000',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Gender Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isFemale ? 'Female' : 'Male',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Grade Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8A2BA3)
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFB866CF)
                                        .withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Grade ${draft.grade}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEFE1F2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Candidate ID
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CANDIDATE ID',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          draft.candidateId,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                            letterSpacing: 0.6,
                            color: Color(0xFFB866CF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '2026/27 SESSION',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 14),

                // Bottom Row: Academic Stream Pill + Digital Barcode
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stream Pill
                    AcedexBounceable(
                      onTap: draft.requiresStream && onEditStep != null
                          ? () => onEditStep!(4)
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: !draft.requiresStream
                                ? HugeIcons.strokeRoundedGraduationCap
                                : (isNatural
                                    ? HugeIcons.strokeRoundedAtom02
                                    : HugeIcons.strokeRoundedGlobe02),
                            color: const Color(0xFFB866CF),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            draft.academicSummary,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEFE1F2),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stylized Digital Exam Barcode
                    _buildStylizedBarcode(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylizedBarcode() {
    const barWidths = [
      2.0,
      4.0,
      1.5,
      3.0,
      2.0,
      1.0,
      5.0,
      2.0,
      3.0,
      1.5,
      4.0,
      2.0
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: barWidths.map((w) {
        return Container(
          width: w,
          height: 22,
          margin: const EdgeInsets.only(right: 2.5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }).toList(),
    );
  }
}
