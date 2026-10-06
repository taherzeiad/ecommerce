import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  ProfileViewModel({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository {
    _readSession();
  }

  String _userName = '';
  String get userName => _userName;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _phone = '';
  String get phone => _phone;

  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploadingAvatar = false;
  bool get isUploadingAvatar => _isUploadingAvatar;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _readSession() {
    _userName = _authRepository.getCurrentUserName() ?? '';
    _userEmail = _authRepository.getCurrentUserEmail() ?? '';
  }

  /// Shows the signed-in user immediately, then loads the full profile
  /// (phone, photo) from the server.
  Future<void> refresh() async {
    _readSession();
    _phone = '';
    _avatarUrl = null;
    notifyListeners();
    try {
      final profile = await _profileRepository.getProfile();
      if (profile != null) {
        if (profile.name.isNotEmpty) _userName = profile.name;
        if (profile.email.isNotEmpty) _userEmail = profile.email;
        _phone = profile.phone ?? '';
        _avatarUrl = profile.avatarUrl;
      }
    } catch (e) {
      // Keep what the session already told us.
    }
    notifyListeners();
  }

  Future<bool> updateProfile({required String name, String phone = ''}) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty) {
      _errorMessage = 'error_name_required';
      notifyListeners();
      return false;
    }
    if (trimmedPhone.isNotEmpty &&
        !RegExp(r'^\+?[0-9 ]{7,15}$').hasMatch(trimmedPhone)) {
      _errorMessage = 'error_invalid_phone';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _profileRepository.updateProfile(
        name: trimmedName,
        phone: trimmedPhone.isEmpty ? null : trimmedPhone,
      );
      _userName = trimmedName;
      _phone = trimmedPhone;
      return true;
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar(Uint8List bytes, String fileExtension) async {
    _isUploadingAvatar = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _avatarUrl = await _profileRepository.uploadAvatar(bytes, fileExtension);
      return true;
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      return false;
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }
}
