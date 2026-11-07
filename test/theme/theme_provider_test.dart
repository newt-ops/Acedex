import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:acedex/core/theme/theme_provider.dart';

void main() {
  group('ThemeModeNotifier Tests', () {
    test('Default mode is system', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, ThemeMode.system);
    });

    test('Can switch to light and dark and persist', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);
      expect(prefs.getString('acedex_theme_mode'), 'dark');

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);
      expect(prefs.getString('acedex_theme_mode'), 'light');
    });

    test('Toggle between light and dark works accurately', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      // Starting from light
      await notifier.setThemeMode(ThemeMode.light);
      await notifier.toggleLightDark(Brightness.light);
      expect(notifier.state, ThemeMode.dark);

      // Toggle back to light
      await notifier.toggleLightDark(Brightness.dark);
      expect(notifier.state, ThemeMode.light);
    });

    test('Handles boolean in SharedPreferences without type error', () async {
      SharedPreferences.setMockInitialValues({'acedex_theme_mode': true});
      final prefs = await SharedPreferences.getInstance();
      final notifier = ThemeModeNotifier(prefs);

      expect(notifier.state, ThemeMode.dark);
    });
  });
}

