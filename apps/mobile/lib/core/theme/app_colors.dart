import 'package:flutter/material.dart';

/// Acedex Canonical Design Palette
///
/// Core Brand Hex Colors:
/// - Tech Blue (Accent & Primary): #005A9C (High-credibility engineering & tech blue)
/// - Charcoal: #2C2C2C (Deep, refined neutral)
/// - Mist: #F3F4F4 (Soft, glare-free off-white canvas)
abstract class AppColors {
  // --- Core Brand Swatches ---
  static const Color techBlue = Color(0xFF005A9C);
  static const Color techBlueHover = Color(0xFF004578);
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color mist = Color(0xFFF3F4F4);

  // Backward-compatible swatches
  static const Color plum = Color(0xFF853953);
  static const Color aubergine = Color(0xFF612D53);

  // --- Light Mode Tokens ---
  static const Color lightBackground = Color(0xFFF3F4F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF005A9C);
  static const Color lightPrimaryHover = Color(0xFF004578);
  static const Color lightSecondary = Color(0xFF0F3D63);
  static const Color lightSecondaryContainer = Color(0xFFEBF3FA);
  static const Color lightAccent = Color(0xFF005A9C);
  static const Color lightText = Color(0xFF2C2C2C);
  static const Color lightSubtext = Color(0xFF4B5563);
  static const Color lightBorder = Color(0xFFD1D5DB);

  // --- Dark Mode Tokens ---
  static const Color darkBackground = Color(0xFF11161B);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkSurfaceElevated = Color(0xFF383838);
  static const Color darkPrimary = Color(0xFF2B82C9);
  static const Color darkPrimaryHover = Color(0xFF005A9C);
  static const Color darkSecondary = Color(0xFF1F2937);
  static const Color darkSecondaryContainer = Color(0xFF1A2A38);
  static const Color darkAccent = Color(0xFF3B92DE);
  static const Color darkText = Color(0xFFF3F4F4);
  static const Color darkSubtext = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF3A3A3A);

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

  static const Color info = Color(0xFF005A9C);
  static const Color infoContainer = Color(0xFFEBF3FA);
  static const Color darkInfo = Color(0xFF38BDF8);
}
