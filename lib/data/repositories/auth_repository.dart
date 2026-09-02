/// Interface for all authentication-related data operations.
/// Follows the same pattern as OnboardingRepository for testability.
abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> signup(String name, String email, String password);
  Future<void> sendResetLink(String email);
  Future<void> verifyOtp(String otp);
  Future<void> resetPassword(String password);
}

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<void> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> sendResetLink(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Future<void> resetPassword(String password) async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}
