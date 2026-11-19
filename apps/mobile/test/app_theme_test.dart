import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:acedex/core/theme/app_colors.dart';
import 'package:acedex/core/theme/app_theme.dart';

void main() {
  group('Acedex AppTheme & AppColors Tests', () {
    test('Core Brand Swatches have exact hex definitions', () {
      expect(AppColors.charcoal, const Color(0xFF2C2C2C));
      expect(AppColors.plum, const Color(0xFF853953));
      expect(AppColors.aubergine, const Color(0xFF612D53));
      expect(AppColors.mist, const Color(0xFFF3F4F4));
    });

    test('Light Theme has correct palette and Material 3 structure', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.lightPrimary);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(theme.cardTheme.color, AppColors.lightSurface);
      expect(theme.colorScheme.onSurface, AppColors.lightText);
    });

    test('Dark Theme has correct palette and Material 3 structure', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.darkPrimary);
      expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(theme.cardTheme.color, AppColors.darkSurface);
      expect(theme.colorScheme.onSurface, AppColors.darkText);
    });
  });
}
