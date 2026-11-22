import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/ui.dart';
import '../models/profile_models.dart';
import '../widgets/candidate_avatar_picker_sheet.dart';
import '../widgets/candidate_pass_card.dart';
import '../widgets/credential_export_sheet.dart';
import '../widgets/edit_registration_sheet.dart';
import '../widgets/exam_registration_card.dart';
import '../widgets/share_qr_sheet.dart';
import '../widgets/storage_security_card.dart';

/// Clean Apple-Style Candidate Profile Inside Screen (Tab 4: Profile)
///
/// Features:
/// - Strictly zero top header bar or bottom navigation bar (rendered by shell)
/// - 130px bottom scroll padding clearing the concave notch navigation bar
/// - Top Page Title Block ("STUDENT CREDENTIALS" / "Profile" + "Verified")
/// - Hero Interactive 3D-Tilt & 180° Flippable Candidate Pass (Apple Wallet Style)
/// - Credential Export & Share QR Action Row
/// - EUEE 2026 Exam Registration Details Card with Expandable Subject Accordion
/// - Offline Storage & Account Security Card (iOS Grouped Settings)
/// - Theme Appearance & Sign Out
class ProfileScreen extends StatefulWidget {
  final UserProfile? user;
  final VoidCallback onSignOut;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late ProfileCandidateRecord _record;

  bool _isExporting = false;

  // Floating iOS Toast State
  String? _toastMessage;
  Timer? _toastTimer;
  late final AnimationController _toastCtrl;
  late final Animation<Offset> _toastSlide;
  late final Animation<double> _toastFade;

  @override
  void initState() {
    super.initState();
    _record = ProfileData.defaultRecord();

    // Initialize from provided user profile if available
    if (widget.user != null) {
      final u = widget.user!;
      if (u.displayName.isNotEmpty) _record.name = u.displayName;
      if (u.phone != null && u.phone!.isNotEmpty) _record.phone = u.phone!;
      if (u.gender != null && u.gender!.isNotEmpty) {
        _record.gender = u.gender!.toLowerCase() == 'female' ? 'Female' : 'Male';
      }
      if (u.grade != null) _record.grade = 'Grade ${u.grade}';
      if (u.stream != null && u.stream!.isNotEmpty) {
        _record.stream = u.stream!.toLowerCase() == 'social'
            ? 'Social Science'
            : 'Natural Science';
      }
    }

    _toastCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _toastSlide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _toastCtrl, curve: Curves.easeOutBack));
    _toastFade = CurvedAnimation(parent: _toastCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _toastCtrl.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toastMessage = message);
    _toastCtrl.forward();

    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _toastCtrl.reverse();
      }
    });
  }

  void _openAvatarPicker() {
    CandidateAvatarPickerSheet.show(
      context,
      studentName: _record.name,
      onShowToast: _showToast,
    );
  }

  void _openEditRegistration([String? field]) {
    EditRegistrationSheet.show(
      context,
      record: _record,
      initialFocusField: field,
      onSaveRecord: (updated) {
        setState(() => _record = updated);
      },
      onShowToast: _showToast,
    );
  }

  Future<void> _handleExportCredential() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 660));
    if (mounted) {
      setState(() => _isExporting = false);
      CredentialExportSheet.show(
        context,
        record: _record,
        onShowToast: _showToast,
      );
    }
  }

  void _openShareQr() {
    ShareQrSheet.show(
      context,
      record: _record,
      onShowToast: _showToast,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    return Stack(
      children: [
        // Main Scrollable Viewport (130px bottom padding)
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 22, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==============================================================
              // 1. TOP PAGE TITLE BLOCK
              // ==============================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'STUDENT CREDENTIALS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 13,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // 2. HERO INTERACTIVE 3D-TILT & 180° FLIPPABLE PASS
              // ==============================================================
              CandidatePassCard(
                record: _record,
                onTapAvatar: _openAvatarPicker,
                onEditField: _openEditRegistration,
                onShowToast: _showToast,
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // 3. CREDENTIAL EXPORT & SHARE QR ACTION ROW
              // ==============================================================
              Row(
                children: [
                  Expanded(
                    flex: 13,
                    child: AcedexBounceable(
                      onTap: _isExporting ? null : _handleExportCredential,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8A2BA3).withValues(alpha: 0.38),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isExporting
                            ? const AcedexDotsLoader(color: Colors.white, dotSize: 5, gap: 4)
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedDownload04,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Export Credential',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 10,
                    child: AcedexBounceable(
                      onTap: _openShareQr,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: lineColor),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedQrCode,
                              color: accentColor,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Share QR',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // 4. EUEE 2026 EXAM REGISTRATION DETAILS CARD
              // ==============================================================
              ExamRegistrationCard(
                record: _record,
                onEditRegistration: () => _openEditRegistration(null),
                onShowToast: _showToast,
              ),

              const SizedBox(height: 16),

              // ==============================================================
              // 5. OFFLINE STORAGE & ACCOUNT SECURITY CARD
              // ==============================================================
              StorageSecurityCard(onShowToast: _showToast),

              const SizedBox(height: 16),

              // ==============================================================
              // 6. THEME APPEARANCE CARD
              // ==============================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: lineColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Theme Appearance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const AcedexThemeToggle(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==============================================================
              // 7. SIGN OUT BUTTON
              // ==============================================================
              AcedexButton(
                label: 'Sign Out',
                variant: AcedexButtonVariant.outline,
                size: AcedexButtonSize.md,
                leadingIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedLogout01,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                  size: 18,
                ),
                isFullWidth: true,
                onPressed: widget.onSignOut,
              ),
            ],
          ),
        ),

        // Floating iOS Feedback Toast Banner
        Positioned(
          top: 12,
          left: 20,
          right: 20,
          child: SlideTransition(
            position: _toastSlide,
            child: FadeTransition(
              opacity: _toastFade,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: lineColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF4ADE80).withValues(alpha: 0.16)
                              : const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _toastMessage ?? '',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
