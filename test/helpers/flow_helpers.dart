import 'package:ecommerce/core/localization/translations.dart';
import 'package:ecommerce/presentation/main_wrapper/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

/// English text of a translation key, for finding widgets by label.
String t(String key) => AppTranslations.translations['en']![key]!;

/// Scrolls [finder] into view, taps it and lets the app react.
Future<void> tapOn(
  WidgetTester tester,
  Finder finder, {
  Duration wait = const Duration(milliseconds: 800),
}) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFor(tester, wait);
}

/// Taps the bottom navigation item at [index].
Future<void> tapTab(WidgetTester tester, int index) => tapOn(
  tester,
  find
      .descendant(
        of: find.byType(CustomBottomNav),
        matching: find.byType(InkWell),
      )
      .at(index),
);

/// Opens [route] like `Navigator.pushNamed` would.
Future<void> open(WidgetTester tester, String route, [Object? args]) async {
  rootNavigator(tester).pushNamed(route, arguments: args);
  await pumpFor(tester, const Duration(seconds: 1));
}
