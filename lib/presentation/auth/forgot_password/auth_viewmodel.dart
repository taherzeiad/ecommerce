import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgotPasswordViewModel(this._authRepository);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String _otp = '';
  String get otp => _otp;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setOtp(String value) {
    if (value.length <= 4) {
      _otp = value;
      notifyListeners();
    }
  }

  void appendOtp(String value) {
    if (_otp.length < 4) {
      _otp += value;
      notifyListeners();
    }
  }

  void removeLastOtp() {
    if (_otp.isNotEmpty) {
      _otp = _otp.substring(0, _otp.length - 1);
      notifyListeners();
    }
  }

  void clearOtp() {
    _otp = '';
    notifyListeners();
  }

  Future<bool> sendResetLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendResetLink(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    if (_otp.length < 4) {
      _errorMessage = 'Please enter the 4-digit code';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.verifyOtp(_otp);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Please fill in all fields';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
