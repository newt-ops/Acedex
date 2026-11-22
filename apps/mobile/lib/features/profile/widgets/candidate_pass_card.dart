import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/models/student_avatar.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/profile_models.dart';

/// Hero Interactive 3D-Tilt & 180° Flippable Official Candidate Pass (Apple Wallet Style)
class CandidatePassCard extends StatefulWidget {
  final ProfileCandidateRecord record;
  final VoidCallback onTapAvatar;
  final ValueChanged<String> onEditField;
  final ValueChanged<String> onShowToast;

  const CandidatePassCard({
    super.key,
    required this.record,
    required this.onTapAvatar,
    required this.onEditField,
    required this.onShowToast,
  });

  @override
  State<CandidatePassCard> createState() => _CandidatePassCardState();
}

class _CandidatePassCardState extends State<CandidatePassCard>
    with TickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnimation;
  bool _isBack = false;

  late final AnimationController _laserCtrl;
  bool _isScanningBarcode = false;
  bool _isCopiedCandidateId = false;
  Timer? _copyTimer;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipCtrl,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    _laserCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _laserCtrl.dispose();
    _copyTimer?.cancel();
    super.dispose();
  }

  void _toggleFlip() {
    HapticFeedback.lightImpact();
    if (_flipCtrl.isAnimating) return;
    if (_isBack) {
      _flipCtrl.reverse();
      setState(() => _isBack = false);
    } else {
      _flipCtrl.forward();
      setState(() => _isBack = true);
    }
  }

  void _handleCopyCandidateId() {
    _copyTimer?.cancel();
    Clipboard.setData(ClipboardData(text: widget.record.candidateId));
    setState(() => _isCopiedCandidateId = true);
    widget.onShowToast('Candidate ID copied');

    _copyTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _isCopiedCandidateId = false);
    });
  }

  void _triggerBarcodeScan() {
    if (_isScanningBarcode) return;
    HapticFeedback.mediumImpact();
    setState(() => _isScanningBarcode = true);
    _laserCtrl
      ..reset()
      ..forward().then((_) {
        if (mounted) {
          setState(() => _isScanningBarcode = false);
          widget.onShowToast('Barcode verified: ${widget.record.candidateId}');
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, _) {
        final angle = _flipAnimation.value * math.pi;
        final isFront = angle < math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isFront ? _buildFrontFace(context) : _buildBackFace(context),
        );
      },
    );
  }

  /// Front Face of Official Candidate Pass
  Widget _buildFrontFace(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final passGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1820), Color(0xFF24192A), Color(0xFF2D1D36)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFFAF3FC), Color(0xFFF1E1F7)],
          );

    return Container(
      constraints: const BoxConstraints(minHeight: 294),
      decoration: BoxDecoration(
        gradient: passGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: lineColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A2BA3).withValues(alpha: isDark ? 0.26 : 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Brand & Verification Row
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Acedex Geometric Purple Logo Emblem
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentSoftColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: lineColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACEDEX NATIONAL EDUCATION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          'OFFICIAL CANDIDATE PASS',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: lineColor),
          const SizedBox(height: 12),

          // Student Identity & Metadata Chips
          Row(
            children: [
              // 62x62px Rounded-Square Avatar with Camera Badge
              GestureDetector(
                onTap: widget.onTapAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: accentSoftColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: accentColor, width: 1.8),
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ValueListenableBuilder<StudentAvatar>(
                          valueListenable: AuthStorage.instance.avatarNotifier,
                          builder: (context, avatar, _) {
                            return StudentAvatarWidget(
                              avatar: avatar,
                              size: 60,
                              initials: widget.record.name,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: -3,
                      bottom: -3,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardBg, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCamera01,
                          color: Colors.white,
                          size: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Name & Phone with Pencil Tap Targets
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AcedexBounceable(
                      onTap: () => widget.onEditField('name'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.record.name,
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            color: accentColor,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    AcedexBounceable(
                      onTap: () => widget.onEditField('phone'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.record.phone,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedEdit02,
                            color: subtextColor,
                            size: 11.5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Metadata Chips (Gender, Grade, Stream)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _PassChip(
                icon: HugeIcons.strokeRoundedUser,
                label: widget.record.gender,
                accentColor: accentColor,
                accentSoftColor: accentSoftColor,
                onTap: () => widget.onEditField('gender'),
              ),
              _PassChip(
                icon: HugeIcons.strokeRoundedMortarboard02,
                label: widget.record.grade,
                accentColor: accentColor,
                accentSoftColor: accentSoftColor,
                onTap: () => widget.onEditField('grade'),
              ),
              _PassChip(
                icon: HugeIcons.strokeRoundedAtom01,
                label: widget.record.stream,
                accentColor: accentColor,
                accentSoftColor: accentSoftColor,
                onTap: () => widget.onEditField('stream'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: lineColor),
          const SizedBox(height: 10),

          // Bottom Candidate ID, Vector Barcode & Flip Pass Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Candidate ID with Tap to Copy
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CANDIDATE ID',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AcedexBounceable(
                    onTap: _handleCopyCandidateId,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.record.candidateId,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: _isCopiedCandidateId
                                ? (isDark
                                    ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                                    : const Color(0xFFDCFCE7))
                                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isCopiedCandidateId ? 'Copied ✓' : 'Copy',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: _isCopiedCandidateId
                                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                                  : subtextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Interactive Vector Barcode with Laser Animation
              AcedexBounceable(
                key: const Key('candidate_barcode_tap'),
                onTap: _triggerBarcodeScan,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: lineColor),
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: const Size(86, 26),
                        painter: _BarcodePainter(color: theme.colorScheme.onSurface),
                      ),
                      if (_isScanningBarcode)
                        AnimatedBuilder(
                          animation: _laserCtrl,
                          builder: (context, _) {
                            final dx = _laserCtrl.value * 86;
                            return Positioned(
                              left: dx,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 2.5,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Flip Pass Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tap barcode to test scan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
              AcedexBounceable(
                onTap: _toggleFlip,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: lineColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedRefresh,
                        color: accentColor,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Flip Pass',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Back Face of Official Candidate Pass (180° Flipped)
  Widget _buildBackFace(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    final passBackGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1620), Color(0xFF231829), Color(0xFF2C1C34)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFBF7FD), Color(0xFFF2E3F7), Color(0xFFEAD6F2)],
          );

    final subjects = ProfileData.subjectsByStream[widget.record.stream] ??
        ProfileData.subjectsByStream['Natural Science']!;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: Container(
        constraints: const BoxConstraints(minHeight: 294),
        decoration: BoxDecoration(
          gradient: passBackGradient,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: lineColor),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BA3).withValues(alpha: isDark ? 0.26 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICIAL DIGITAL SEAL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      'EUEE Candidate Verification',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                AcedexBounceable(
                  onTap: _toggleFlip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: lineColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedRefresh,
                          color: accentColor,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Flip Pass',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Divider(height: 1, color: lineColor),

            // Vector QR Code & Exam Center Details
            Row(
              children: [
                // White Rounded Container with Vector QR Code
                Container(
                  width: 92,
                  height: 92,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: lineColor),
                  ),
                  child: QrImageView(
                    data: 'https://acedex.edu.et/verify/${widget.record.candidateId}',
                    version: QrVersions.auto,
                    size: 80,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF8A2BA3),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Center & Seat Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXAM CENTER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: subtextColor,
                        ),
                      ),
                      Text(
                        '${widget.record.examCenter} • ${widget.record.hall}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SEAT NO.',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: subtextColor,
                                ),
                              ),
                              Text(
                                widget.record.seatNo,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: lineColor,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PASS CODE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: subtextColor,
                                ),
                              ),
                              Text(
                                widget.record.candidateId,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(height: 1, color: lineColor),

            // Registered Subjects Summary Pills
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final s in subjects)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentSoftColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      s.name,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
              ],
            ),

            // Digital Signature Authenticated Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DIGITAL SIGNATURE AUTHENTICATED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                Text(
                  '2018 E.C. / 2026',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PassChip extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Color accentColor;
  final Color accentSoftColor;
  final VoidCallback onTap;

  const _PassChip({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.accentSoftColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AcedexBounceable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: accentSoftColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              color: accentColor,
              size: 11,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final Color color;

  _BarcodePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Pattern of barcode bars
    const bars = [
      (1.0, 2.0),
      (5.0, 1.5),
      (9.0, 3.0),
      (14.0, 1.5),
      (18.0, 2.2),
      (23.0, 1.5),
      (27.0, 3.2),
      (33.0, 1.5),
      (37.0, 2.0),
      (42.0, 2.8),
      (47.0, 1.5),
      (51.0, 2.4),
      (56.0, 1.5),
      (60.0, 3.0),
      (66.0, 1.8),
      (70.0, 2.5),
      (75.0, 1.5),
      (79.0, 2.2),
      (83.0, 2.0),
    ];

    for (final b in bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(b.$1, 2, b.$2, size.height - 4),
          const Radius.circular(0.8),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) => oldDelegate.color != color;
}
