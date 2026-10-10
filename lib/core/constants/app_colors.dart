import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
/// Using named constants instead of hardcoded hex values ensures
/// consistency and makes future branding or theme changes trivial.
class AppColors {
  AppColors._();

  // Core Branding
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryExtraLight = Color(0xFFF8FAFC);

  // Dark Mode Specific
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF242424);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF333333);

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8FAFC);
  static const Color homeBackground = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color illustrationBackground = Color(0xFFEEF2FF);
  static const Color bannerTeal = Color(0xFF818CF8);

  // Text Colors
  static const Color textPrimary = Color(0xFF1B1B29); // Main titles, dark text
  static const Color textSecondary = Color(
    0xFF8A8FA3,
  ); // Subtitles, descriptive text
  static const Color textDark = Color(0xFF2C3E50); // Dark charcoal text
  static const Color textGrey = Color(0xFF616161); // Neutral grey text
  static const Color textLight = Color(0xFFBDBDBD); // Hint text, disabled text

  // Auth Specific Text
  static const Color authTextHeader = Color(0xFF4A5568);
  static const Color authTextBody = Color(0xFF718096);
  static const Color authHint = Color(0xFFCBD5E0);
  static const Color authLink = Color(0xFF6366F1);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderExtraLight = Color(0xFFF1F1F1);
  static const Color borderTeal = Color(0xFFC7D2FE);
  static const Color authBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color dividerExtraLight = Color(0xFFEDF2F7);

  // Status & Feedback
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF6366F1);
  static const Color warning = Color(0xFFFBC02D);

  // UI Components
  static const Color indicatorActive = primary;
  static const Color indicatorInactive = borderTeal;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
}
