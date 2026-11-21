import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../models/student_avatar.dart';
import '../../theme/app_colors.dart';

/// Reusable Apple-Style Student Avatar Component
///
/// Renders preset avatars ('default', 'monogram', 'scholar', 'atom', 'crest')
/// or custom user photos from base64/file.
class StudentAvatarWidget extends StatelessWidget {
  final StudentAvatar avatar;
  final double size;
  final String? initials;
  final BoxBorder? border;

  const StudentAvatarWidget({
    super.key,
    required this.avatar,
    this.size = 44,
    this.initials,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: ClipOval(child: _buildAvatarContent(context, isDark)),
    );
  }

  Widget _buildAvatarContent(BuildContext context, bool isDark) {
    if (avatar.type == StudentAvatarType.custom) {
      if (avatar.dataBase64 != null && avatar.dataBase64!.isNotEmpty) {
        try {
          // Handle both raw base64 and data URL ("data:image/...;base64,....")
          String cleanBase64 = avatar.dataBase64!;
          if (cleanBase64.contains(',')) {
            cleanBase64 = cleanBase64.split(',').last;
          }
          final bytes = base64Decode(cleanBase64);
          return Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallback(isDark),
          );
        } catch (_) {
          return _buildFallback(isDark);
        }
      } else if (avatar.filePath != null && avatar.filePath!.isNotEmpty) {
        try {
          return Image.file(
            File(avatar.filePath!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallback(isDark),
          );
        } catch (_) {
          return _buildFallback(isDark);
        }
      }
      return _buildFallback(isDark);
    }

    switch (avatar.presetId) {
      case 'monogram':
        final effectiveInitials =
            (initials != null && initials!.trim().isNotEmpty)
            ? initials!.trim().toUpperCase()
            : 'AM';
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8A2BA3), // Royal Purple
                Color(0xFF611B75), // Deep Regal Purple
              ],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            effectiveInitials.length > 2
                ? effectiveInitials.substring(0, 2)
                : effectiveInitials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.38,
              letterSpacing: -0.5,
            ),
          ),
        );

      case 'scholar':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF2B1C33), Color(0xFF3D2149)]
                  : const [Color(0xFFEFE1F2), Color(0xFFDFC3E8)],
            ),
          ),
          alignment: Alignment.center,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedMortarboard01,
            color: const Color(0xFF8A2BA3),
            size: size * 0.52,
          ),
        );

      case 'atom':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF271A2C), Color(0xFF442352)],
            ),
          ),
          alignment: Alignment.center,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedAtom01,
            color: const Color(0xFFE6AEF7),
            size: size * 0.54,
          ),
        );

      case 'crest':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            ),
          ),
          alignment: Alignment.center,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedShield01,
            color: const Color(0xFFD97706),
            size: size * 0.52,
          ),
        );

      case 'default':
      default:
        return Container(
          width: size,
          height: size,
          color: isDark ? const Color(0xFF271A2C) : const Color(0xFFEFE1F2),
          alignment: Alignment.center,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedUser,
            color: isDark ? const Color(0xFFB866CF) : AppColors.royalPurple,
            size: size * 0.52,
          ),
        );
    }
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      width: size,
      height: size,
      color: isDark ? const Color(0xFF271A2C) : const Color(0xFFEFE1F2),
      alignment: Alignment.center,
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedUser,
        color: AppColors.royalPurple,
        size: size * 0.5,
      ),
    );
  }
}
