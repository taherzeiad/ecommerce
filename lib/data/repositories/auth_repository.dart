enum SocialProvider { google, facebook }

/// Interface for all authentication-related data operations.
/// Follows the same pattern as OnboardingRepository for testability.
abstract class AuthRepository {
  Future<void> login(String email, String password);

  /// Returns `true` when the new account is signed in right away and `false`
  /// when the user has to confirm their email address first.
  Future<bool> signup(String name, String email, String password);

  /// Sends the password-reset email containing the verification code.
  Future<void> sendResetLink(String email);

  /// Checks the code from the reset email and signs the user in for it.
  Future<void> verifyOtp(String email, String otp);

  Future<void> resetPassword(String password);

  /// Checks [currentPassword] before setting [newPassword].
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Opens the provider's sign-in page; the result arrives through
  /// [authStateChanges] when the user comes back to the app.
  Future<void> signInWithProvider(SocialProvider provider);

  /// Emits `true` whenever a user signs in and `false` when they sign out.
  Stream<bool> get authStateChanges;

  Future<void> logout();

  String? getCurrentUserId();

  String? getCurrentUserEmail();

  String? getCurrentUserName();

  bool isUserLoggedIn();
}
