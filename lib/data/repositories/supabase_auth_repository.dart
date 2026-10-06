import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabaseClient;

  SupabaseAuthRepository(this._supabaseClient);

  /// Deep link the browser returns to after Google / Facebook sign-in.
  /// Must also be listed under Authentication -> URL Configuration ->
  /// Redirect URLs in the Supabase dashboard.
  static const oauthRedirectUrl = 'io.supabase.ecommerce://login-callback/';

  GoTrueClient get _auth => _supabaseClient.auth;

  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> signup(String name, String email, String password) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    // In newer Supabase projects (User Enumeration Protection), signing up an existing user
    // returns a successful response but with an empty identities list instead of throwing an error.
    if (response.user != null &&
        response.user!.identities != null &&
        response.user!.identities!.isEmpty) {
      throw const AuthException('User already exists');
    }

    // Without a session the user must confirm their email first; the
    // database trigger creates the profile row in that case.
    if (response.session == null) return false;

    await _supabaseClient.from('profiles').upsert({
      'id': response.user!.id,
      'name': name,
      'email': email,
    });
    return true;
  }

  @override
  Future<void> sendResetLink(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    // Needs the "Reset Password" email template to contain {{ .Token }}.
    await _auth.verifyOTP(email: email, token: otp, type: OtpType.recovery);
  }

  @override
  Future<void> resetPassword(String password) async {
    await _auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final email = _auth.currentUser?.email;
    if (email == null) throw const AuthException('not_authenticated');
    // Signing in again proves the current password is right.
    await _auth.signInWithPassword(email: email, password: currentPassword);
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> signInWithProvider(SocialProvider provider) async {
    await _auth.signInWithOAuth(
      switch (provider) {
        SocialProvider.google => OAuthProvider.google,
        SocialProvider.facebook => OAuthProvider.facebook,
      },
      redirectTo: oauthRedirectUrl,
    );
  }

  @override
  Stream<bool> get authStateChanges =>
      _auth.onAuthStateChange.map((state) => state.session != null);

  @override
  bool isUserLoggedIn() {
    final session = _auth.currentSession;
    return session != null && !session.isExpired;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  String? getCurrentUserId() => _auth.currentUser?.id;

  @override
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  @override
  String? getCurrentUserName() {
    final user = _auth.currentUser;
    return user?.userMetadata?['name'] as String? ??
        user?.userMetadata?['full_name'] as String?;
  }
}
