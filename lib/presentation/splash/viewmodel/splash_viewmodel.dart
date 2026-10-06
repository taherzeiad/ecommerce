import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/di/service_locator.dart';

/// Decides where the splash screen should navigate to next.
/// The View only listens to [destination] — it has zero business logic.
enum SplashDestination { loading, onboarding, login, home }

class SplashViewModel extends ChangeNotifier {
  SplashViewModel({OnboardingRepository? repository, AuthRepository? authRepository})
      : _repository = repository ?? OnboardingRepositoryImpl(),
        _authRepository = authRepository ?? sl<AuthRepository>();

  final OnboardingRepository _repository;
  final AuthRepository _authRepository;

  SplashDestination _destination = SplashDestination.loading;
  SplashDestination get destination => _destination;

  /// Simulates a minimal splash delay (branding) then checks whether
  /// the user has already completed onboarding before.
  Future<void> init() async {
    final results = await Future.wait([
      _repository.hasCompletedOnboarding(),
      Future.delayed(const Duration(milliseconds: 1600)),
    ]);

    final hasCompleted = results.first as bool;

    if (!hasCompleted) {
      _destination = SplashDestination.onboarding;
    } else if (_authRepository.isUserLoggedIn() && await _shouldRemember()) {
      _destination = SplashDestination.home;
    } else {
      _destination = SplashDestination.login;
    }
    notifyListeners();
  }

  /// A user who unticked "Remember me" is signed out on the next launch.
  Future<bool> _shouldRemember() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(AppStrings.rememberMePrefKey) ?? true) return true;
    try {
      await _authRepository.logout();
    } catch (_) {
      // Offline: the local session is still dropped on the next start.
    }
    return false;
  }
}
