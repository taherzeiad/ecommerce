import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/theme/view_model/locale_view_model.dart';
import '../localization/translations.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key) {
    try {
      final localeViewModel = watch<LocaleViewModel>();
      final languageCode = localeViewModel.locale.languageCode;
      
      final value = AppTranslations.translations[languageCode]?[key];
      if (value == null) {
        return AppTranslations.translations['en']?[key] ?? key;
      }
      return value;
    } catch (e) {
      // Fallback for cases where watch is called outside build
      return AppTranslations.translations['en']?[key] ?? key;
    }
  }
}
