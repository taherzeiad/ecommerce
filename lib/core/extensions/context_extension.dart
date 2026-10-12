import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/theme/view_model/locale_view_model.dart';
import '../localization/translations.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key, {bool listen = true}) {
    String languageCode = 'en';
    try {
      // Use listen = true by default for build methods to ensure reactivity
      // Set listen = false for non-build contexts like onGenerateTitle
      languageCode = Provider.of<LocaleViewModel>(this, listen: listen).locale.languageCode;
    } catch (e) {
      // Fallback to non-listening if listening fails (e.g. outside build)
      try {
        languageCode = Provider.of<LocaleViewModel>(this, listen: false).locale.languageCode;
      } catch (e) {
        // Final fallback
      }
    }
    
    final value = AppTranslations.translations[languageCode]?[key];
    if (value == null) {
      return AppTranslations.translations['en']?[key] ?? key;
    }
    return value;
  }
}

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isSmallPhone => screenWidth < 360;
  bool get isTablet => screenWidth >= 600;

  double get responsiveHorizontalPadding =>
      isSmallPhone ? 16.0 : (isTablet ? 32.0 : 24.0);
  EdgeInsets get responsivePadding => EdgeInsets.symmetric(
        horizontal: responsiveHorizontalPadding,
        vertical: isSmallPhone ? 16.0 : 24.0,
      );

  int get responsiveGridCount => isTablet ? 3 : 2;
  double get productCardAspectRatio =>
      isSmallPhone ? 0.63 : (isTablet ? 0.75 : 0.68);
}
