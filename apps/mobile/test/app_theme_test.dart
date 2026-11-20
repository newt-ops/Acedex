import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/theme/app_colors.dart';
import 'package:acedex/core/theme/app_theme.dart';

void main() {
  group('Acedex AppTheme & AppColors Tests (Purple Palette)', () {
    test('Core Brand Swatches have exact Purple hex definitions', () {
      expect(AppColors.accentLight, const Color(0xFF8A2BA3));
      expect(AppColors.accentDark, const Color(0xFFB866CF));
      expect(AppColors.accentSoftLight, const Color(0xFFEFE1F2));
      expect(AppColors.accentSoftDark, const Color(0xFF271A2C));
      expect(AppColors.onAccentLight, const Color(0xFFFFFFFF));
      expect(AppColors.onAccentDark, const Color(0xFF0B0B0F));

      expect(AppColors.lightBackground, const Color(0xFFFFFFFF));
      expect(AppColors.darkBackground, const Color(0xFF0E0E11));
      expect(AppColors.lightSurface, const Color(0xFFF4F4F6));
      expect(AppColors.darkSurface, const Color(0xFF1B1B1F));
      expect(AppColors.lightRaised, const Color(0xFFFFFFFF));
      expect(AppColors.darkRaised, const Color(0xFF2B2B31));
      expect(AppColors.lightText, const Color(0xFF1C1C1E));
      expect(AppColors.darkText, const Color(0xFFF5F5F7));
      expect(AppColors.lightSecondaryText, const Color(0xFF6C6C72));
      expect(AppColors.darkSecondaryText, const Color(0xFF9A9AA2));
      expect(AppColors.lightLine, const Color(0xFFE4E4E8));
      expect(AppColors.darkLine, const Color(0xFF2B2B31));

      expect(AppColors.success, const Color(0xFF16A34A));
      expect(AppColors.darkSuccess, const Color(0xFF4ADE80));
      expect(AppColors.warning, const Color(0xFFD97706));
      expect(AppColors.darkWarning, const Color(0xFFFBBF24));
      expect(AppColors.error, const Color(0xFFDC2626));
      expect(AppColors.darkError, const Color(0xFFF87171));
    });

    test('Light Theme has correct Purple palette and Material 3 structure', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFF8A2BA3));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.primaryContainer, const Color(0xFFEFE1F2));
      expect(theme.colorScheme.tertiary, AppColors.lightAccent);
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(theme.cardTheme.color, const Color(0xFFF4F4F6));
      expect(theme.colorScheme.onSurface, const Color(0xFF1C1C1E));
    });

    test('Dark Theme has correct Purple palette and Material 3 structure', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFFB866CF));
      expect(theme.colorScheme.onPrimary, const Color(0xFF0B0B0F));
      expect(theme.colorScheme.primaryContainer, const Color(0xFF271A2C));
      expect(theme.colorScheme.tertiary, AppColors.darkAccent);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0E0E11));
      expect(theme.cardTheme.color, const Color(0xFF1B1B1F));
      expect(theme.colorScheme.onSurface, const Color(0xFFF5F5F7));
    });
  });
}
