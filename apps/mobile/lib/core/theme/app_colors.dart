import 'package:flutter/material.dart';

/// Acedex Canonical Design Palette (Teal Theme System)
///
/// Palette Tokens:
/// - Accent: #0F766E (Light), #2DD4BF (Dark)
/// - Accent Soft: #DDECEB (Light 14% tint), #122A29 (Dark)
/// - On Accent: #FFFFFF (Light), #0B0B0F (Dark)
/// - Background: #FFFFFF (Light), #0E0E11 (Dark)
/// - Surface: #F4F4F6 (Light), #1B1B1F (Dark)
/// - Raised: #FFFFFF (Light), #2B2B31 (Dark)
/// - Text: #1C1C1E (Light), #F5F5F7 (Dark)
/// - Secondary Text: #6C6C72 (Light), #9A9AA2 (Dark)
/// - Line: #E4E4E8 (Light), #2B2B31 (Dark)
///
/// State Tokens:
/// - Success: #16A34A (Light), #4ADE80 (Dark)
/// - Warning: #D97706 (Light), #FBBF24 (Dark)
/// - Error: #DC2626 (Light), #F87171 (Dark)
abstract class AppColors {
  // --- Core Brand Swatches ---
  static const Color accentLight = Color(0xFF0F766E);
  static const Color accentDark = Color(0xFF2DD4BF);
  static const Color accentSoftLight = Color(0xFFDDECEB);
  static const Color accentSoftDark = Color(0xFF122A29);
  static const Color onAccentLight = Color(0xFFFFFFFF);
  static const Color onAccentDark = Color(0xFF0B0B0F);

  // Common aliases
  static const Color teal = Color(0xFF0F766E);
  static const Color tealLight = Color(0xFF2DD4BF);

  // --- Light Mode Tokens ---
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF4F4F6);
  static const Color lightRaised = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF0F766E);
  static const Color lightPrimaryHover = Color(0xFF0D655E);
  static const Color lightAccent = Color(0xFF0F766E);
  static const Color lightAccentSoft = Color(0xFFDDECEB);
  static const Color lightOnAccent = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1C1C1E);
  static const Color lightSecondaryText = Color(0xFF6C6C72);
  static const Color lightSubtext = Color(0xFF6C6C72);
  static const Color lightLine = Color(0xFFE4E4E8);
  static const Color lightBorder = Color(0xFFE4E4E8);

  // --- Dark Mode Tokens ---
  static const Color darkBackground = Color(0xFF0E0E11);
  static const Color darkSurface = Color(0xFF1B1B1F);
  static const Color darkRaised = Color(0xFF2B2B31);
  static const Color darkPrimary = Color(0xFF2DD4BF);
  static const Color darkPrimaryHover = Color(0xFF14B8A6);
  static const Color darkAccent = Color(0xFF2DD4BF);
  static const Color darkAccentSoft = Color(0xFF122A29);
  static const Color darkOnAccent = Color(0xFF0B0B0F);
  static const Color darkText = Color(0xFFF5F5F7);
  static const Color darkSecondaryText = Color(0xFF9A9AA2);
  static const Color darkSubtext = Color(0xFF9A9AA2);
  static const Color darkLine = Color(0xFF2B2B31);
  static const Color darkBorder = Color(0xFF2B2B31);

  // --- Semantic State Feedback Tokens ---
  static const Color success = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color darkSuccess = Color(0xFF4ADE80);

  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color darkWarning = Color(0xFFFBBF24);

  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color darkError = Color(0xFFF87171);

  static const Color info = Color(0xFF0F766E);
  static const Color infoContainer = Color(0xFFDDECEB);
  static const Color darkInfo = Color(0xFF2DD4BF);
}
