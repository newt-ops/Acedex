import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.onPrimary,
    required this.onDanger,
    required this.primarySoft,
  });

  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color onPrimary;
  final Color onDanger;
  final Color primarySoft;

  Color statusTint(Color baseStatus) => baseStatus.withValues(alpha: 0.12);
  Color statusBorder(Color baseStatus) => baseStatus.withValues(alpha: 0.35);

  /// Card and container border color token (maps to standard border)
  Color get cardBorder => border;

  static const light = AppColors(
    primary: Color(0xFF8A2BA3),
    secondary: Color(0xFF0A7F70),
    success: Color(0xFF1F8A3B),
    warning: Color(0xFFB26A00),
    danger: Color(0xFFD92D20),
    info: Color(0xFF0A6BD6),
    background: Color(0xFFF6F3F6),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDE8ED),
    border: Color(0xFFE1DAE2),
    textPrimary: Color(0xFF1D151E),
    textSecondary: Color(0xFF665969),
    onPrimary: Color(0xFFFFFFFF),
    onDanger: Color(0xFFFFFFFF),
    primarySoft: Color(0x248A2BA3),
  );

  static const dark = AppColors(
    primary: Color(0xFFD58CF0),
    secondary: Color(0xFF34D3BE),
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    danger: Color(0xFFFF5A4F),
    info: Color(0xFF4DA3FF),
    background: Color(0xFF0E0B0E),
    surface: Color(0xFF1B171C),
    surfaceAlt: Color(0xFF282329),
    border: Color(0xFF383239),
    textPrimary: Color(0xFFF3F1F4),
    textSecondary: Color(0xFFA79EA9),
    onPrimary: Color(0xFF0B0C0E),
    onDanger: Color(0xFF0B0C0E),
    primarySoft: Color(0x24D58CF0),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? onPrimary,
    Color? onDanger,
    Color? primarySoft,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      onPrimary: onPrimary ?? this.onPrimary,
      onDanger: onDanger ?? this.onDanger,
      primarySoft: primarySoft ?? this.primarySoft,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      info: Color.lerp(info, other.info, t) ?? info,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      border: Color.lerp(border, other.border, t) ?? border,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      onDanger: Color.lerp(onDanger, other.onDanger, t) ?? onDanger,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t) ?? primarySoft,
    );
  }
}

extension AppColorsContextExtension on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
