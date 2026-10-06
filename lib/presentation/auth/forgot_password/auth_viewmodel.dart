import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgotPasswordViewModel(this._authRepository);

  /// Length of the code in Supabase's password-reset email.
  static const int otpLength = 6;

  /// Seconds before another code may be requested.
  static const int resendCooldown = 60;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String _otp = '';

  String get otp => _otp;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  int _resendSecondsLeft = 0;

  int get resendSecondsLeft => _resendSecondsLeft;

  bool get canResend => _resendSecondsLeft == 0 && !_isLoading;

  Timer? _cooldownTimer;
  bool _disposed = false;

  void setOtp(String value) {
    if (value.length <= otpLength) {
      _otp = value;
      notifyListeners();
    }
  }

  void appendOtp(String value) {
    if (_otp.length < otpLength) {
      _otp += value;
      _errorMessage = null;
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

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _resendSecondsLeft = resendCooldown;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) return timer.cancel();
      _resendSecondsLeft--;
      if (_resendSecondsLeft <= 0) {
        _resendSecondsLeft = 0;
        timer.cancel();
      }
      notifyListeners();
    });
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
      _startCooldown();
      return true;
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends a fresh code (after the cooldown) and clears the typed one.
  Future<bool> resendCode() async {
    if (!canResend) return false;
    _otp = '';
    return sendResetLink();
  }

  Future<bool> verifyOtp() async {
    if (_otp.length < otpLength) {
      _errorMessage = 'error_otp_incomplete';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.verifyOtp(emailController.text.trim(), _otp);
      return true;
    } catch (e) {
      final text = e.toString().toLowerCase();
      _errorMessage = text.contains('expired') || text.contains('invalid')
          ? 'error_otp_invalid'
          : errorKeyFor(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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

    if (password.length < 6) {
      _errorMessage = 'error_weak_password';
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
      // The code signed the user in; end that session so they log in with
      // the new password.
      await _authRepository.logout();
      return true;
    } catch (e) {
      final text = e.toString().toLowerCase();
      _errorMessage = text.contains('different from the old')
          ? 'error_same_password'
          : errorKeyFor(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cooldownTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
