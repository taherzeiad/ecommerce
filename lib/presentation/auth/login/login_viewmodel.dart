import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please fill in all fields';
      notifyListeners();
      return false;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid login credentials') || errorStr.contains('invalid_credentials')) {
        _errorMessage = 'error_invalid_credentials';
      } else if (errorStr.contains('email_not_confirmed') || errorStr.contains('not confirmed')) {
        _errorMessage = 'error_email_not_confirmed';
      } else if (errorStr.contains('network') || errorStr.contains('failed to fetch') || errorStr.contains('clientexception')) {
        _errorMessage = 'error_network';
      } else if (errorStr.contains('too many requests') || errorStr.contains('429')) {
        _errorMessage = 'error_too_many_requests';
      } else {
        _errorMessage = 'error_unexpected';
      }
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
