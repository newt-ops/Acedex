import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/animations/bounceable.dart';
import '../models/student_registration_draft.dart';

/// Apple-Grade 3D-Tilt & 180° Flippable Student Candidate Pass
///
/// Features:
/// - Full 3D perspective flip between Front and Back faces
/// - Front Face: Institution emblem, Verified badge, candidate details, tap-to-edit, Candidate ID, and barcode
/// - Back Face: Digital Credential Back, official Vector QR Code encoding student credentials, enrolled curriculum subject chips, metadata footer
/// - Tap-to-flip and dedicated "Flip Pass" / "Flip to Front" pill buttons
/// - Responsive Light & Dark styling with zero neon glare
class StudentIdCard extends StatefulWidget {
  final StudentRegistrationDraft draft;
  final void Function(int targetStep)? onEditStep;
  final bool initialFlipped;
  final ValueChanged<bool>? onFlipChanged;

  const StudentIdCard({
    super.key,
    required this.draft,
    this.onEditStep,
    this.initialFlipped = false,
    this.onFlipChanged,
  });

  @override
  State<StudentIdCard> createState() => StudentIdCardState();
}

class StudentIdCardState extends State<StudentIdCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isBack = false;

  bool get isBack => _isBack;

  @override
  void initState() {
    super.initState();
    _isBack = widget.initialFlipped;
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      value: _isBack ? 1.0 : 0.0,
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  /// Public method to toggle flip from external parent controls
  void toggleFlip() {
    HapticFeedback.lightImpact();
    if (_flipController.isAnimating) return;

    if (_isBack) {
      _flipController.reverse();
      setState(() => _isBack = false);
    } else {
      _flipController.forward();
      setState(() => _isBack = true);
    }
    widget.onFlipChanged?.call(_isBack);
  }

  String _buildQrPayload() {
    final streamStr = widget.draft.requiresStream
        ? ((widget.draft.stream ?? 'natural').toLowerCase() == 'social'
            ? 'Social Science'
            : 'Natural Science')
        : 'General Curriculum';

    return 'ACEDEX OFFICIAL CANDIDATE PASS\n'
        'Candidate ID: ${widget.draft.candidateId}\n'
        'Full Name: ${widget.draft.fullName.isNotEmpty ? widget.draft.fullName : "Candidate"}\n'
        'Phone: ${widget.draft.phoneNumber.isNotEmpty ? widget.draft.phoneNumber : "+251"}\n'
        'Grade: Grade ${widget.draft.grade}\n'
        'Stream: $streamStr\n'
        'Gender: ${widget.draft.gender.toUpperCase()}\n'
        'Status: VERIFIED\n'
        'Issued by: Ministry of Education / Acedex National Platform\n'
        'Exam Track: ESSLCE 2026';
  }

  List<String> _getEnrolledSubjects() {
    final isSocial = (widget.draft.stream ?? '').toLowerCase() == 'social';
    if (widget.draft.grade >= 11) {
      if (isSocial) {
        return ['History', 'Geography', 'Economics', 'Social Math'];
      } else {
        return ['Physics', 'Chemistry', 'Biology', 'Technical Math'];
      }
    } else {
      return ['General Curriculum', 'Mathematics', 'English', 'General Science'];
    }
  }

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

    final isFemale = widget.draft.gender.toLowerCase() == 'female';
    final isNatural =
        (widget.draft.stream ?? 'natural').toLowerCase() == 'natural';

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, _) {
        final angle = _flipAnimation.value * math.pi;
        final isFrontFace = angle <= (math.pi / 2);

        return AcedexBounceable(
          scaleFactor: 0.985,
          onTap: toggleFlip,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0009) // 3D perspective
              ..rotateY(angle),
            child: isFrontFace
                ? _buildFrontFace(
                    isDark: isDark,
                    accent: accent,
                    softAccent: softAccent,
                    line: line,
                    textColor: textColor,
                    subtext: subtext,
                    isFemale: isFemale,
                    isNatural: isNatural,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi), // Un-mirror back face
                    child: _buildBackFace(
                      isDark: isDark,
                      accent: accent,
                      softAccent: softAccent,
                      line: line,
                      textColor: textColor,
                      subtext: subtext,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCardContainer({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B1F) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF382A40) : const Color(0xFFE4E4E8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  // ===========================================================================
  // FRONT FACE OF PASS
  // ===========================================================================
  Widget _buildFrontFace({
    required bool isDark,
    required Color accent,
    required Color softAccent,
    required Color line,
    required Color textColor,
    required Color subtext,
    required bool isFemale,
    required bool isNatural,
  }) {
    return _buildCardContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Institution + VERIFIED badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACEDEX NATIONAL EDUCATION',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'OFFICIAL CANDIDATE PASS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Green Verified Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkBadge01,
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

          const SizedBox(height: 16),
          Container(height: 1, color: line),
          const SizedBox(height: 14),

          // Avatar + Student Name & Phone (with edit pencils)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
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
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AcedexBounceable(
                      onTap: () => widget.onEditStep?.call(0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.draft.fullName.isNotEmpty
                                  ? widget.draft.fullName
                                  : 'Candidate Name',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: textColor,
                              ),
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
                    const SizedBox(height: 4),
                    AcedexBounceable(
                      onTap: () => widget.onEditStep?.call(1),
                      child: Row(
                        children: [
                          Text(
                            widget.draft.phoneNumber.isNotEmpty
                                ? widget.draft.phoneNumber
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
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Metadata Chips: Gender, Grade, Stream
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AcedexBounceable(
                onTap: () => widget.onEditStep?.call(2),
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
              AcedexBounceable(
                onTap: () => widget.onEditStep?.call(3),
                child: _buildChip(
                  icon: HugeIcons.strokeRoundedMortarboard02,
                  label: 'Grade ${widget.draft.grade}',
                  accent: accent,
                  softAccent: softAccent,
                  textColor: textColor,
                ),
              ),
              if (widget.draft.requiresStream)
                AcedexBounceable(
                  onTap: () => widget.onEditStep?.call(4),
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

          const SizedBox(height: 14),
          Container(height: 1, color: line),
          const SizedBox(height: 12),

          // Bottom Bar: Candidate ID + Barcode Graphic
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
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: subtext,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.draft.candidateId,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: accent,
                    ),
                  ),
                ],
              ),
              _buildBarcode(isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BACK FACE OF PASS (QR CODE + ENROLLED SUBJECTS + METADATA)
  // ===========================================================================
  Widget _buildBackFace({
    required bool isDark,
    required Color accent,
    required Color softAccent,
    required Color line,
    required Color textColor,
    required Color subtext,
  }) {
    final subjects = _getEnrolledSubjects();
    final qrPayload = _buildQrPayload();

    return _buildCardContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back Header Row: DIGITAL CREDENTIAL BACK + Flip front button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DIGITAL CREDENTIAL BACK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ENROLLED CURRICULUM & QR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              // Flip to Front Button Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: softAccent,
                  borderRadius: BorderRadius.circular(8),
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
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Flip Front',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: line),
          const SizedBox(height: 14),

          // Middle: QR Code + Enrolled Subjects List
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean White QR Container with Official Candidate Data
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: line,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrPayload,
                  version: QrVersions.auto,
                  size: 78.0,
                  gapless: false,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1C1C1E),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Enrolled Subjects Pills
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENROLLED SUBJECTS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: subtext,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: subjects.map((subj) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: softAccent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            subj,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1, color: line),
          const SizedBox(height: 12),

          // Back Footer: Examination Metadata + PIN Encrypted
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESSLCE 2026 • Addis Ababa, ET',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: subtext,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedSquareLock02,
                    color: accent,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'PIN Encrypted',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: softAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            color: accent,
            size: 12.5,
          ),
          const SizedBox(width: 4.5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarcode({required bool isDark}) {
    final stripeColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.7);
    final barHeights = [
      16.0, 20.0, 14.0, 22.0, 16.0, 18.0, 22.0, 14.0, 20.0, 16.0, 22.0, 14.0, 18.0
    ];
    final barWidths = [
      2.0, 1.5, 2.5, 1.5, 2.0, 3.0, 1.5, 2.0, 1.5, 2.5, 1.5, 2.0, 1.5
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(barHeights.length, (index) {
        return Container(
          width: barWidths[index],
          height: barHeights[index],
          margin: const EdgeInsets.only(right: 2.0),
          decoration: BoxDecoration(
            color: stripeColor,
            borderRadius: BorderRadius.circular(0.8),
          ),
        );
      }),
    );
  }
}
