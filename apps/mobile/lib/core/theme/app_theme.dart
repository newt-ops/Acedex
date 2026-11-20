import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Central Material 3 Theme Configuration for Acedex Mobile (Purple System)
abstract class AppTheme {
  /// --- Light Theme ---
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnAccent,
      primaryContainer: AppColors.lightAccentSoft,
      onPrimaryContainer: AppColors.lightPrimary,
      secondary: AppColors.lightSecondaryText,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightAccentSoft,
      onSecondaryContainer: AppColors.lightPrimary,
      tertiary: AppColors.lightAccent,
      onTertiary: AppColors.lightOnAccent,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: AppColors.lightRaised,
      onSurfaceVariant: AppColors.lightSecondaryText,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      outline: AppColors.lightLine,
      outlineVariant: AppColors.lightLine.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightLine, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnAccent,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightLine, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightLine, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.lightSecondaryText, fontSize: 14),
        hintStyle: TextStyle(color: AppColors.lightSecondaryText.withValues(alpha: 0.7), fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        indicatorColor: AppColors.lightAccentSoft,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.lightPrimary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: AppColors.lightSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightPrimary, size: 24);
          }
          return const IconThemeData(color: AppColors.lightSecondaryText, size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightLine,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// --- Dark Theme ---
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnAccent,
      primaryContainer: AppColors.darkAccentSoft,
      onPrimaryContainer: AppColors.darkPrimary,
      secondary: AppColors.darkSecondaryText,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: AppColors.darkAccentSoft,
      onSecondaryContainer: AppColors.darkPrimary,
      tertiary: AppColors.darkAccent,
      onTertiary: AppColors.darkOnAccent,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkRaised,
      onSurfaceVariant: AppColors.darkSecondaryText,
      error: AppColors.darkError,
      onError: AppColors.darkOnAccent,
      errorContainer: AppColors.darkAccentSoft,
      onErrorContainer: AppColors.darkError,
      outline: AppColors.darkLine,
      outlineVariant: AppColors.darkLine.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkLine, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnAccent,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkLine, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkLine, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.darkSecondaryText, fontSize: 14),
        hintStyle: TextStyle(color: AppColors.darkSecondaryText.withValues(alpha: 0.7), fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        indicatorColor: AppColors.darkAccentSoft,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPrimary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: AppColors.darkSecondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkPrimary, size: 24);
          }
          return const IconThemeData(color: AppColors.darkSecondaryText, size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkLine,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
