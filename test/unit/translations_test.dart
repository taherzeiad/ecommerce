import 'dart:io';

import 'package:ecommerce/core/localization/translations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = AppTranslations.translations['en']!;
  final ar = AppTranslations.translations['ar']!;

  test('English and Arabic define exactly the same keys', () {
    final onlyEn = en.keys.toSet().difference(ar.keys.toSet());
    final onlyAr = ar.keys.toSet().difference(en.keys.toSet());

    expect(onlyEn, isEmpty, reason: 'missing in ar');
    expect(onlyAr, isEmpty, reason: 'missing in en');
  });

  test('no translation is empty', () {
    for (final lang in ['en', 'ar']) {
      final empty = AppTranslations.translations[lang]!.entries
          .where((e) => e.value.trim().isEmpty)
          .map((e) => e.key);
      expect(empty, isEmpty, reason: 'empty values in $lang');
    }
  });

  test('every literal key passed to context.tr() exists', () {
    final keyPattern = RegExp(r"""\btr\(\s*'([a-z0-9_]+)'""");
    final missing = <String>{};
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      for (final m in keyPattern.allMatches(file.readAsStringSync())) {
        final key = m.group(1)!;
        if (!en.containsKey(key)) missing.add('$key (${file.path})');
      }
    }

    expect(missing, isEmpty);
  });

  test('error keys produced by the auth view models exist', () {
    const keys = [
      'error_invalid_credentials',
      'error_email_not_confirmed',
      'error_network',
      'error_too_many_requests',
      'error_unexpected',
      'error_user_exists',
      'error_weak_password',
    ];
    for (final k in keys) {
      expect(en, contains(k));
      expect(ar, contains(k));
    }
  });

  test('sort option keys built by the filter screen exist', () {
    const options = [
      'Popular',
      'Newest',
      'Price : Low To High',
      'Price : High To Low',
    ];
    for (final o in options) {
      final key = o
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(':', '')
          .replaceAll('__', '_');
      expect(en, contains(key));
    }
  });

  test('{count} placeholder is kept in both languages', () {
    expect(en['added_to_cart_count'], contains('{count}'));
    expect(ar['added_to_cart_count'], contains('{count}'));
  });
}
