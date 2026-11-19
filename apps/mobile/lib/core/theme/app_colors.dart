import 'package:flutter/material.dart';

/// Acedex Canonical Design Palette
///
/// Core Brand Hex Colors:
/// - Charcoal: #2C2C2C (Deep, refined neutral)
/// - Plum: #853953 (Vibrant cranberry / rich plum primary)
/// - Aubergine: #612D53 (Deep velvety wine secondary)
/// - Mist: #F3F4F4 (Soft, glare-free off-white canvas)
abstract class AppColors {
  // --- Core Brand Swatches ---
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color plum = Color(0xFF853953);
  static const Color aubergine = Color(0xFF612D53);
  static const Color mist = Color(0xFFF3F4F4);

  // --- Light Mode Tokens ---
  static const Color lightBackground = Color(0xFFF3F4F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF853953);
  static const Color lightPrimaryHover = Color(0xFF612D53);
  static const Color lightSecondary = Color(0xFF612D53);
  static const Color lightSecondaryContainer = Color(0xFFF8EEF2);
  static const Color lightText = Color(0xFF2C2C2C);
  static const Color lightSubtext = Color(0xFF665C62);
  static const Color lightBorder = Color(0xFFE2D9DE);

  // --- Dark Mode Tokens ---
  static const Color darkBackground = Color(0xFF191417);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkSurfaceElevated = Color(0xFF383135);
  static const Color darkPrimary = Color(0xFF9E4663);
  static const Color darkPrimaryHover = Color(0xFF853953);
  static const Color darkSecondary = Color(0xFF612D53);
  static const Color darkSecondaryContainer = Color(0xFF382531);
  static const Color darkText = Color(0xFFF3F4F4);
  static const Color darkSubtext = Color(0xFFA89FA4);
  static const Color darkBorder = Color(0xFF3F373B);

  // --- Semantic Feedback Tokens ---
  static const Color success = Color(0xFF1B7A43);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color darkSuccess = Color(0xFF34D399);

  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFFFBEB);
  static const Color darkWarning = Color(0xFFFBBF24);

  static const Color error = Color(0xFFBE123C);
  static const Color errorContainer = Color(0xFFFFF1F2);
  static const Color darkError = Color(0xFFF87171);

  static const Color info = Color(0xFF6366F1);
  static const Color infoContainer = Color(0xFFEEF2FF);
  static const Color darkInfo = Color(0xFF818CF8);
}
