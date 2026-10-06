import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/error_mapper.dart';
import '../../../data/repositories/auth_repository.dart';

/// Google / Facebook sign-in. The provider page opens in the browser; when
/// the user comes back through the deep link, [signedIn] turns true.
class SocialLoginViewModel extends ChangeNotifier {
  SocialLoginViewModel(this._authRepository) {
    _subscription = _authRepository.authStateChanges.listen((isSignedIn) {
      if (isSignedIn && _awaitingProvider && !_signedIn) {
        _signedIn = true;
        _awaitingProvider = false;
        _rememberSession();
        notifyListeners();
      }
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<bool> _subscription;

  SocialProvider? _busyProvider;

  /// The provider whose page is being opened right now.
  SocialProvider? get busyProvider => _busyProvider;

  bool _awaitingProvider = false;

  bool _signedIn = false;
  bool get signedIn => _signedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> signIn(SocialProvider provider) async {
    if (_busyProvider != null) return;
    _busyProvider = provider;
    _errorMessage = null;
    notifyListeners();
    try {
      _awaitingProvider = true;
      await _authRepository.signInWithProvider(provider);
    } catch (e) {
      _awaitingProvider = false;
      final text = e.toString().toLowerCase();
      _errorMessage =
          text.contains('provider is not enabled') ||
              text.contains('unsupported provider')
          ? 'error_provider_disabled'
          : errorKeyFor(e);
    } finally {
      _busyProvider = null;
      notifyListeners();
    }
  }

  Future<void> _rememberSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.rememberMePrefKey, true);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
