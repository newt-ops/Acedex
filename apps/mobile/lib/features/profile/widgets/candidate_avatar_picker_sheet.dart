import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/student_avatar.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';

/// Cupertino Bottom Sheet: Candidate Avatar Picker (Device Upload + 5 Studio Presets)
class CandidateAvatarPickerSheet extends StatefulWidget {
  final String studentName;
  final ValueChanged<String> onShowToast;

  const CandidateAvatarPickerSheet({
    super.key,
    required this.studentName,
    required this.onShowToast,
  });

  static Future<void> show(
    BuildContext context, {
    required String studentName,
    required ValueChanged<String> onShowToast,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => CandidateAvatarPickerSheet(
        studentName: studentName,
        onShowToast: onShowToast,
      ),
    );
  }

  @override
  State<CandidateAvatarPickerSheet> createState() => _CandidateAvatarPickerSheetState();
}

class _CandidateAvatarPickerSheetState extends State<CandidateAvatarPickerSheet> {
  late StudentAvatar _stagedAvatar;
  bool _isSaving = false;

  final List<(String id, String label, dynamic icon)> _presets = const [
    ('default', 'Student', HugeIcons.strokeRoundedUser),
    ('monogram', 'AM Crest', null),
    ('scholar', 'Grad Cap', HugeIcons.strokeRoundedMortarboard02),
    ('atom', 'Science', HugeIcons.strokeRoundedAtom01),
    ('crest', 'Honor', HugeIcons.strokeRoundedShield02),
  ];

  @override
  void initState() {
    super.initState();
    _stagedAvatar = AuthStorage.instance.avatarNotifier.value;
  }

  Future<void> _pickDeviceImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          _stagedAvatar = StudentAvatar.custom(dataBase64: base64Str);
        });
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> _saveAvatar() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 620));
    await AuthStorage.instance.saveAvatar(_stagedAvatar);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      widget.onShowToast('Candidate photo updated');
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
                            'CANDIDATE PHOTO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            'Update Profile Avatar',
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
                    // Staged Preview Stage
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: accentSoftColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: accentColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8A2BA3).withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: StudentAvatarWidget(
                                avatar: _stagedAvatar,
                                size: 80,
                                initials: widget.studentName,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Appears on Official Candidate Pass',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Upload from Device Button
                    AcedexBounceable(
                      onTap: _pickDeviceImage,
                      child: Container(
                        height: 42,
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
                              icon: HugeIcons.strokeRoundedUpload01,
                              color: accentColor,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Upload Photo from Device',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5 Studio Presets
                    Text(
                      'STUDIO STUDENT PRESETS',
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
                        for (final p in _presets) ...[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: AcedexBounceable(
                                onTap: () {
                                  setState(() {
                                    _stagedAvatar = StudentAvatar.preset(p.$1);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: (_stagedAvatar.type == StudentAvatarType.preset &&
                                            _stagedAvatar.presetId == p.$1)
                                        ? accentSoftColor
                                        : surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: (_stagedAvatar.type == StudentAvatarType.preset &&
                                              _stagedAvatar.presetId == p.$1)
                                          ? accentColor
                                          : lineColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        child: p.$3 != null
                                            ? HugeIcon(
                                                icon: p.$3,
                                                color: (_stagedAvatar.type == StudentAvatarType.preset &&
                                                        _stagedAvatar.presetId == p.$1)
                                                    ? accentColor
                                                    : subtextColor,
                                                size: 20,
                                              )
                                            : Text(
                                                'AM',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: (_stagedAvatar.type == StudentAvatarType.preset &&
                                                          _stagedAvatar.presetId == p.$1)
                                                      ? accentColor
                                                      : subtextColor,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        p.$2,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: (_stagedAvatar.type == StudentAvatarType.preset &&
                                                  _stagedAvatar.presetId == p.$1)
                                              ? accentColor
                                              : subtextColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Save Photo CTA
                    AcedexBounceable(
                      onTap: _isSaving ? null : _saveAvatar,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8A2BA3).withValues(alpha: 0.38),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isSaving
                            ? const AcedexDotsLoader(color: Colors.white, dotSize: 5, gap: 4)
                            : const Text(
                                'Save Photo',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
