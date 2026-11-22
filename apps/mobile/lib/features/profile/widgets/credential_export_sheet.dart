import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/profile_models.dart';

/// Cupertino Bottom Sheet: Credential Export
class CredentialExportSheet extends StatefulWidget {
  final ProfileCandidateRecord record;
  final ValueChanged<String> onShowToast;

  const CredentialExportSheet({
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
      builder: (ctx) => CredentialExportSheet(
        record: record,
        onShowToast: onShowToast,
      ),
    );
  }

  @override
  State<CredentialExportSheet> createState() => _CredentialExportSheetState();
}

class _CredentialExportSheetState extends State<CredentialExportSheet> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 760));
    if (mounted) {
      setState(() => _isDownloading = false);
      Navigator.of(context).pop();
      widget.onShowToast('Candidate ${_selectedFormat.label} exported & saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final sheetBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

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
                            'OFFICIAL EXPORT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            'Export Credential',
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
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Format Selector Pills
                    Text(
                      'SELECT EXPORT FORMAT',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        for (final fmt in ExportFormat.values) ...[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: AcedexBounceable(
                                onTap: () => setState(() => _selectedFormat = fmt),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: _selectedFormat == fmt ? accentSoftColor : surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _selectedFormat == fmt ? accentColor : lineColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    fmt.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _selectedFormat == fmt ? accentColor : subtextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Live Preview Summary Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: passGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: lineColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedFormat.badge,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: accentColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _selectedFormat.size,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.record.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.record.grade} • ${widget.record.stream} • ${widget.record.gender}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 1, color: lineColor),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ID: ${widget.record.candidateId}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor,
                                ),
                              ),
                              Text(
                                'Adm: ${widget.record.admissionNo}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Download & Save Button
                    AcedexBounceable(
                      onTap: _isDownloading ? null : _handleDownload,
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
                        child: _isDownloading
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
                                    'Download & Save',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
