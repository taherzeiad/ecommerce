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
