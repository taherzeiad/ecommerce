import 'package:ecommerce/core/constants/app_strings.dart';
import 'package:ecommerce/presentation/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:ecommerce/presentation/splash/viewmodel/splash_viewmodel.dart';
import 'package:ecommerce/presentation/theme/view_model/locale_view_model.dart';
import 'package:ecommerce/presentation/theme/view_model/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fakes.dart';

void main() {
  group('SplashViewModel', () {
    Future<SplashDestination> run(
      WidgetTester tester, {
      required bool onboarded,
      required bool loggedIn,
      FakeAuthRepository? auth,
    }) async {
      final vm = SplashViewModel(
        repository: FakeOnboardingRepository(completed: onboarded),
        authRepository: auth ?? (FakeAuthRepository()..loggedIn = loggedIn),
      );
      vm.init();
      expect(vm.destination, SplashDestination.loading);
      await tester.pump(const Duration(seconds: 2));
      return vm.destination;
    }

    testWidgets('first launch goes to onboarding', (tester) async {
      expect(
        await run(tester, onboarded: false, loggedIn: true),
        SplashDestination.onboarding,
      );
    });

    testWidgets('returning signed-out user goes to login', (tester) async {
      expect(
        await run(tester, onboarded: true, loggedIn: false),
        SplashDestination.login,
      );
    });

    testWidgets('returning signed-in user goes straight home', (tester) async {
      SharedPreferences.setMockInitialValues({});
      expect(
        await run(tester, onboarded: true, loggedIn: true),
        SplashDestination.home,
      );
    });

    testWidgets('without "remember me" the user is signed out on restart', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        AppStrings.rememberMePrefKey: false,
      });
      final auth = FakeAuthRepository()..loggedIn = true;

      expect(
        await run(tester, onboarded: true, loggedIn: true, auth: auth),
        SplashDestination.login,
      );
      expect(auth.logoutCount, 1);
    });
  });

  group('OnboardingViewModel', () {
    test('has three pages and only the last one says start', () {
      final vm = OnboardingViewModel(repository: FakeOnboardingRepository());

      expect(vm.pages, hasLength(3));
      expect(vm.pages.last.buttonLabel, 'start');
      expect(vm.isLastPage, isFalse);

      vm.onPageChanged(2);
      expect(vm.isLastPage, isTrue);
      vm.dispose();
    });

    test('skip and finishing both persist completion', () async {
      final repo = FakeOnboardingRepository();
      final vm = OnboardingViewModel(repository: repo);

      await vm.skip();
      expect(vm.completed, isTrue);
      expect(repo.completed, isTrue);

      final repo2 = FakeOnboardingRepository();
      final vm2 = OnboardingViewModel(repository: repo2)..onPageChanged(2);
      await vm2.nextPage();
      expect(repo2.completed, isTrue);

      vm.dispose();
      vm2.dispose();
    });
  });

  group('Theme and locale persistence', () {
    test('theme defaults to light and survives a restart', () async {
      SharedPreferences.setMockInitialValues({});
      final vm = ThemeViewModel();
      await Future<void>.delayed(Duration.zero);
      expect(vm.themeMode, ThemeMode.light);

      await vm.toggleTheme();
      expect(vm.themeMode, ThemeMode.dark);

      final restarted = ThemeViewModel();
      await Future<void>.delayed(Duration.zero);
      expect(restarted.isDarkMode, isTrue);
    });

    test(
      'locale defaults to English, persists, and ignores unsupported',
      () async {
        SharedPreferences.setMockInitialValues({});
        final vm = LocaleViewModel();
        await Future<void>.delayed(Duration.zero);
        expect(vm.locale.languageCode, 'en');

        await vm.setLocale(const Locale('ar'));
        await vm.setLocale(const Locale('fr'));
        expect(vm.locale.languageCode, 'ar');

        final restarted = LocaleViewModel();
        await Future<void>.delayed(Duration.zero);
        expect(restarted.locale.languageCode, 'ar');
      },
    );
  });
}
