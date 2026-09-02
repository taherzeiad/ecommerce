import 'package:flutter/material.dart';

/// Centralized color palette extracted from the design screens.
/// Keeping colors here (instead of hardcoding hex values across widgets)
/// makes future theming / dark-mode support trivial.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF129883); // main teal (buttons, accents)
  static const Color primaryDark = Color(0xFF0E7A69); // splash background
  static const Color scaffoldBackground = Color(0xFFF4FBFA); // light mint background
  static const Color cardBackground = Color(0xFFE7F5F3); // illustration card background

  static const Color textPrimary = Color(0xFF1B1B29);
  static const Color textSecondary = Color(0xFF8A8FA3);
  static const Color white = Color(0xFFFFFFFF);

  static const Color indicatorActive = primary;
  static const Color indicatorInactive = Color(0xFFD8E6E3);
}
