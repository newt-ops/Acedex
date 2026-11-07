import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/theme/app_colors.dart';
import 'package:acedex/core/theme/app_theme.dart';

void main() {
  group('AppColors & Theme Tests', () {
    test('Light theme color tokens match specification', () {
      const colors = AppColors.light;
      expect(colors.primary, const Color(0xFF8A2BA3));
      expect(colors.secondary, const Color(0xFF0A7F70));
      expect(colors.success, const Color(0xFF1F8A3B));
      expect(colors.warning, const Color(0xFFB26A00));
      expect(colors.danger, const Color(0xFFD92D20));
      expect(colors.info, const Color(0xFF0A6BD6));
      expect(colors.background, const Color(0xFFF6F3F6));
      expect(colors.surface, const Color(0xFFFFFFFF));
      expect(colors.surfaceAlt, const Color(0xFFEDE8ED));
      expect(colors.border, const Color(0xFFE1DAE2));
      expect(colors.textPrimary, const Color(0xFF1D151E));
      expect(colors.textSecondary, const Color(0xFF665969));
    });

    test('Dark theme color tokens match specification', () {
      const colors = AppColors.dark;
      expect(colors.primary, const Color(0xFFD58CF0));
      expect(colors.secondary, const Color(0xFF34D3BE));
      expect(colors.success, const Color(0xFF30D158));
      expect(colors.warning, const Color(0xFFFF9F0A));
      expect(colors.danger, const Color(0xFFFF5A4F));
      expect(colors.info, const Color(0xFF4DA3FF));
      expect(colors.background, const Color(0xFF0E0B0E));
      expect(colors.surface, const Color(0xFF1B171C));
      expect(colors.surfaceAlt, const Color(0xFF282329));
      expect(colors.border, const Color(0xFF383239));
      expect(colors.textPrimary, const Color(0xFFF3F1F4));
      expect(colors.textSecondary, const Color(0xFFA79EA9));
    });

    test('AppTheme creates valid ThemeData with AppColors extension', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);

      final lightExt = lightTheme.extension<AppColors>();
      final darkExt = darkTheme.extension<AppColors>();

      expect(lightExt, isNotNull);
      expect(darkExt, isNotNull);
      expect(lightExt!.primary, AppColors.light.primary);
      expect(darkExt!.primary, AppColors.dark.primary);
    });
  });
}

