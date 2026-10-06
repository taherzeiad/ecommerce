/// Centralized keys for internal strings and shared preference keys.
/// User-facing strings have been moved to [AppTranslations].
class AppStrings {
  AppStrings._();

  static const String onboardingCompletedPrefKey = 'onboarding_completed';

  /// When `false` the session is ended on the next app start.
  static const String rememberMePrefKey = 'remember_me';
}
