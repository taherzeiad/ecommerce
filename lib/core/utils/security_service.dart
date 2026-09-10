import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to handle sensitive data storage using platform-specific
/// secure storage (KeyChain on iOS, KeyStore on Android).
class SecurityService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
