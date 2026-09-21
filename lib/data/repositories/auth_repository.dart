/// Interface for all authentication-related data operations.
/// Follows the same pattern as OnboardingRepository for testability.
abstract class AuthRepository {
  Future<void> login(String email, String password);

  Future<void> signup(String name, String email, String password);

  Future<void> sendResetLink(String email);

  Future<void> verifyOtp(String otp);

  Future<void> resetPassword(String password);

  Future<void> logout();

  String? getCurrentUserEmail();

  String? getCurrentUserName();

  bool isUserLoggedIn();

  Future<void> updateProfileName(String name);
}
