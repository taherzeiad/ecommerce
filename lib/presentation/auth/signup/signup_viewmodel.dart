import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignupViewModel(this._authRepository);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _agreeToTerms = false;

  bool get agreeToTerms => _agreeToTerms;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void toggleTerms(bool? value) {
    _agreeToTerms = value ?? false;
    notifyListeners();
  }

  Future<bool> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _errorMessage = 'Please fill in all fields';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    if (!_agreeToTerms) {
      _errorMessage = 'Please agree to the terms';
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
      await _authRepository.signup(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('user already exists') ||
          errorStr.contains('already registered')) {
        _errorMessage = 'error_user_exists';
      } else if (errorStr.contains('weak password') ||
          errorStr.contains('password should be')) {
        _errorMessage = 'error_weak_password';
      } else if (errorStr.contains('network') ||
          errorStr.contains('failed to fetch') ||
          errorStr.contains('clientexception')) {
        _errorMessage = 'error_network';
      } else if (errorStr.contains('too many requests') ||
          errorStr.contains('429') ||
          errorStr.contains('rate limit') ||
          errorStr.contains('email_send_rate_limit')) {
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
