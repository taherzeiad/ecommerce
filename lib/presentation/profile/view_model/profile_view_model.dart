import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ProfileViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _userName = _authRepository.getCurrentUserName() ?? '';
    _userEmail = _authRepository.getCurrentUserEmail() ?? '';
  }

  String _userName = '';
  String get userName => _userName;

  String _userEmail = '';
  String get userEmail => _userEmail;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> updateName(String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.updateProfileName(name);
      _userName = name;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    _userName = _authRepository.getCurrentUserName() ?? '';
    _userEmail = _authRepository.getCurrentUserEmail() ?? '';
    notifyListeners();
  }
}
