import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/student_avatar.dart';
import '../../models/user_profile.dart';
import '../../storage/auth_storage.dart';
import '../../theme/app_colors.dart';
import '../animations/bounceable.dart';
import '../avatars/student_avatar_widget.dart';
import '../progress/acedex_dots_loader.dart';

/// Apple iOS Frosted-Glass Profile Photo Modal
///
/// Implements live 88x88 avatar preview stage, device photo picker,
/// 5 Quick Studio Avatars presets, Reset, and Save Photo with 3-dots wave loader.
class ProfilePhotoModal extends StatefulWidget {
  final UserProfile? user;
  final VoidCallback? onAvatarUpdated;

  const ProfilePhotoModal({super.key, this.user, this.onAvatarUpdated});

  /// Displays the modal with an authentic Apple-style backdrop and spring transition
  static Future<void> show(
    BuildContext context, {
    UserProfile? user,
    VoidCallback? onAvatarUpdated,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Profile Photo Modal',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12 * animation.value,
            sigmaY: 12 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (context, _, _) {
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ProfilePhotoModal(
                user: user,
                onAvatarUpdated: onAvatarUpdated,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  State<ProfilePhotoModal> createState() => _ProfilePhotoModalState();
}

class _ProfilePhotoModalState extends State<ProfilePhotoModal> {
  late StudentAvatar _stagedAvatar;
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isUploading = false;
  String? _pickedFileName;

  final List<Map<String, String>> _presets = const [
    {'id': 'default', 'label': 'Default Silhouette'},
    {'id': 'monogram', 'label': 'Royal Monogram'},
    {'id': 'scholar', 'label': 'Scholar Graduation Cap'},
    {'id': 'atom', 'label': 'Science Atom Emblem'},
    {'id': 'crest', 'label': 'Gold Honor Crest'},
  ];

  @override
  void initState() {
    super.initState();
    _stagedAvatar = AuthStorage.instance.avatarNotifier.value;
  }

  String _getInitials() {
    final name = widget.user?.displayName.trim();
    if (name == null || name.isEmpty) return 'AM';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _pickPhotoFromDevice() async {
    if (_isSaving || _isUploading) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _isUploading = true;
          _pickedFileName = picked.name;
        });

        final bytes = await picked.readAsBytes();
        final base64Str = base64Encode(bytes);

        setState(() {
          _stagedAvatar = StudentAvatar.custom(dataBase64: base64Str);
        });

        // Auto-save picked photo with 3-dots loader
        await _saveStagedAvatar();
      }
    } catch (_) {
      // Handle error gracefully
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _saveStagedAvatar() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _isSaved = false;
    });

    // Simulate smooth processing wave loader hold
    await Future.delayed(const Duration(milliseconds: 750));

    await AuthStorage.instance.saveAvatar(_stagedAvatar);
    widget.onAvatarUpdated?.call();

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isUploading = false;
      _isSaved = true;
    });

    // Brief success hold before auto-closing
    await Future.delayed(const Duration(milliseconds: 550));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _resetToDefault() {
    if (_isSaving || _isUploading) return;
    setState(() {
      _stagedAvatar = StudentAvatar.defaultSilhouette;
      _pickedFileName = null;
      _isSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayName = widget.user?.displayName.isNotEmpty == true
        ? widget.user!.displayName
        : 'Newton';

    final surfaceColor = isDark
        ? const Color(0xFF1B1B1F).withValues(alpha: 0.94)
        : Colors.white.withValues(alpha: 0.95);
    final lineColor = isDark
        ? const Color(0xFF2B2B31)
        : const Color(0xFFE4E4E8);
    final subtextColor = isDark
        ? AppColors.darkSubtext
        : AppColors.lightSubtext;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: lineColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: AppColors.royalPurple.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Title, Name, Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Photo',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                AcedexBounceable(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF2B2B31)
                          : const Color(0xFFF4F4F6),
                      border: Border.all(color: lineColor),
                    ),
                    alignment: Alignment.center,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: subtextColor,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Live 88x88px Avatar Preview Stage + "Upload from Device" Pill
            Center(
              child: Column(
                children: [
                  AcedexBounceable(
                    onTap: _pickPhotoFromDevice,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Royal Purple Gradient Ring
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF8A2BA3),
                                Color(0xFFD077E8),
                                Color(0xFF8A2BA3),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.royalPurple.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1B1B1F)
                                    : Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: StudentAvatarWidget(
                              avatar: _stagedAvatar,
                              size: 76,
                              initials: _getInitials(),
                            ),
                          ),
                        ),

                        // Camera Pill Micro-Badge
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.royalPurple,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1B1B1F)
                                    : Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedCamera01,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // "Upload from Device" Pill Button
                  AcedexBounceable(
                    onTap: _pickPhotoFromDevice,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _isUploading
                            ? const Color(0xFF16A34A).withValues(alpha: 0.14)
                            : (isDark
                                  ? const Color(0xFF271A2C)
                                  : const Color(0xFFEFE1F2)),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _isUploading
                              ? const Color(0xFF16A34A)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isUploading)
                            const AcedexDotsLoader(
                              color: Color(0xFF16A34A),
                              dotSize: 4.5,
                            )
                          else ...[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedUpload01,
                              color: isDark
                                  ? const Color(0xFFB866CF)
                                  : AppColors.royalPurple,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Upload from Device',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFFB866CF)
                                    : AppColors.royalPurple,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Studio Avatars Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'QUICK STUDIO AVATARS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pickedFileName != null &&
                            _stagedAvatar.type == StudentAvatarType.custom
                        ? (_pickedFileName!.length > 18
                            ? '${_pickedFileName!.substring(0, 15)}...'
                            : _pickedFileName!)
                        : _stagedAvatar.label,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFB866CF)
                          : AppColors.royalPurple,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 5 Preset Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presets.map((preset) {
                final isSelected =
                    _stagedAvatar.type == StudentAvatarType.preset &&
                    _stagedAvatar.presetId == preset['id'];

                return AcedexBounceable(
                  onTap: () {
                    if (_isSaving || _isUploading) return;
                    setState(() {
                      _stagedAvatar = StudentAvatar.preset(preset['id']!);
                      _pickedFileName = null;
                      _isSaved = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.royalPurple : lineColor,
                        width: isSelected ? 2.2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.royalPurple.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipOval(
                      child: StudentAvatarWidget(
                        avatar: StudentAvatar.preset(preset['id']!),
                        size: 40,
                        initials: _getInitials(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),
            Container(height: 1, color: lineColor),
            const SizedBox(height: 14),

            // Footer Actions: "Reset" & "Save Photo"
            Row(
              children: [
                // Reset Button
                AcedexBounceable(
                  onTap: _resetToDefault,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF271A2C)
                          : const Color(0xFFF4F4F6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: lineColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Save Photo Button
                Expanded(
                  child: AcedexBounceable(
                    onTap: _saveStagedAvatar,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isSaved
                            ? const Color(0xFF16A34A)
                            : AppColors.royalPurple,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isSaved
                                        ? const Color(0xFF16A34A)
                                        : AppColors.royalPurple)
                                    .withValues(alpha: 0.38),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _isSaving
                          ? const AcedexDotsLoader(
                              color: Colors.white,
                              dotSize: 5.5,
                            )
                          : _isSaved
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Updated',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Save Photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                                color: Colors.white,
                              ),
                            ),
                    ),
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
