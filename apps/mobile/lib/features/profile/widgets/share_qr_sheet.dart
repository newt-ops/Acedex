import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/profile_models.dart';

/// Cupertino Bottom Sheet: Share Candidate QR Verification
class ShareQrSheet extends StatefulWidget {
  final ProfileCandidateRecord record;
  final ValueChanged<String> onShowToast;

  const ShareQrSheet({
    super.key,
    required this.record,
    required this.onShowToast,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfileCandidateRecord record,
    required ValueChanged<String> onShowToast,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => ShareQrSheet(
        record: record,
        onShowToast: onShowToast,
      ),
    );
  }

  @override
  State<ShareQrSheet> createState() => _ShareQrSheetState();
}

class _ShareQrSheetState extends State<ShareQrSheet> {
  bool _isCopiedLink = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _handleCopyLink() {
    _copyTimer?.cancel();
    final link = 'https://acedex.edu.et/verify/${widget.record.candidateId}';
    Clipboard.setData(ClipboardData(text: link));
    setState(() => _isCopiedLink = true);
    widget.onShowToast('Verification link copied');

    _copyTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _isCopiedLink = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final sheetBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle & Header
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INSTANT VERIFICATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            'Share Candidate QR',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      AcedexBounceable(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: lineColor),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: theme.colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  // High-Contrast QR Code Card
                  Container(
                    width: 152,
                    height: 152,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: lineColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: 'https://acedex.edu.et/verify/${widget.record.candidateId}',
                      version: QrVersions.auto,
                      size: 128,
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

                  const SizedBox(height: 14),

                  Text(
                    'Exam supervisors can scan this QR code to verify ${widget.record.candidateId} offline or online.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Copyable Verification Link Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: lineColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'acedex.edu.et/verify/${widget.record.candidateId}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AcedexBounceable(
                          onTap: _handleCopyLink,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isCopiedLink
                                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                                  : accentColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _isCopiedLink ? 'Copied ✓' : 'Copy Link',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
