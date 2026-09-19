import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabaseClient;

  SupabaseAuthRepository(this._supabaseClient);

  @override
  Future<void> login(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signup(String name, String email, String password) async {
    await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  @override
  Future<void> sendResetLink(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> verifyOtp(String otp) async {
    // Note: In Supabase, verifying OTP typically requires the email or phone number as well, or uses the token from a link.
    // This is a placeholder wrapper that assumes email OTP type verification via verifyOTP if context allows,
    // or can be customized depending on the exact workflow used in your UI.
    // For standard email OTP, we can use:
    // await _supabaseClient.auth.verifyOTP(token: otp, type: OtpType.signup);
    throw UnimplementedError('OTP verification requires email context or custom integration in Supabase.');
  }

  @override
  Future<void> resetPassword(String password) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: password),
    );
  }
}
