import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/theme/view_model/locale_view_model.dart';
import '../localization/translations.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key) {
    final locale = watch<LocaleViewModel>().locale.languageCode;
    return AppTranslations.translations[locale]?[key] ?? key;
  }
}
