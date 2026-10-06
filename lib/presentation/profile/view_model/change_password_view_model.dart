import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../data/repositories/auth_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  ChangePasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submit() async {
    final current = currentController.text;
    final next = newController.text;
    final confirm = confirmController.text;

    String? problem;
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      problem = 'Please fill in all fields';
    } else if (next.length < 6) {
      problem = 'error_weak_password';
    } else if (next != confirm) {
      problem = 'Passwords do not match';
    } else if (next == current) {
      problem = 'error_same_password';
    }
    if (problem != null) {
      _errorMessage = problem;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.changePassword(current, next);
      return true;
    } catch (e) {
      final text = e.toString().toLowerCase();
      if (text.contains('invalid login credentials') ||
          text.contains('invalid_credentials')) {
        _errorMessage = 'error_wrong_current_password';
      } else if (text.contains('weak') || text.contains('password should')) {
        _errorMessage = 'error_weak_password';
      } else {
        _errorMessage = errorKeyFor(e);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}
