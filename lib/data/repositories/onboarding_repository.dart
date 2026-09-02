import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';

/// Abstraction over "has the user finished onboarding before?".
/// ViewModels depend on this interface, not on SharedPreferences directly —
/// makes it trivial to mock in unit tests and to swap storage later.
abstract class OnboardingRepository {
  Future<bool> hasCompletedOnboarding();
  Future<void> setOnboardingCompleted();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppStrings.onboardingCompletedPrefKey) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.onboardingCompletedPrefKey, true);
  }
}
