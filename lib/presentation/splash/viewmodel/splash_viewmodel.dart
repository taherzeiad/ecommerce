import 'package:flutter/foundation.dart';
import '../../../data/repositories/onboarding_repository.dart';

/// Decides where the splash screen should navigate to next.
/// The View only listens to [destination] — it has zero business logic.
enum SplashDestination { loading, onboarding, login, home }

class SplashViewModel extends ChangeNotifier {
  SplashViewModel({OnboardingRepository? repository})
      : _repository = repository ?? OnboardingRepositoryImpl();

  final OnboardingRepository _repository;

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
    _destination =
        hasCompleted ? SplashDestination.login : SplashDestination.onboarding;
    notifyListeners();
  }
}
