import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification preferences, remembered between launches.
class SettingsViewModel extends ChangeNotifier {
  static const _notificationsKey = 'settings_notifications';
  static const _soundKey = 'settings_notification_sound';
  static const _vibrationKey = 'settings_vibration';

  SettingsViewModel() {
    _load();
  }

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  bool _vibrationEnabled = false;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    _vibrationEnabled = prefs.getBool(_vibrationKey) ?? false;
    notifyListeners();
  }

  Future<void> _save(String key, bool value) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    return _save(_notificationsKey, value);
  }

  Future<void> setSoundEnabled(bool value) {
    _soundEnabled = value;
    return _save(_soundKey, value);
  }

  Future<void> setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    return _save(_vibrationKey, value);
  }
}
