import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage instance = AppStorage._();

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // flutter_secure_storage on web encrypts with crypto.subtle, which browsers
  // only expose on HTTPS or localhost. Over plain HTTP it throws, so web uses
  // shared_preferences (localStorage) instead. Web storage offers no real
  // secrecy from page scripts either way.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _write(_accessKey, accessToken);
    await _write(_refreshKey, refreshToken);
  }

  Future<String?> getAccessToken() => _read(_accessKey);
  Future<String?> getRefreshToken() => _read(_refreshKey);

  Future<bool> hasTokens() async {
    final token = await _read(_accessKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_accessKey);
        await prefs.remove(_refreshKey);
      } else {
        await _secure.delete(key: _accessKey);
        await _secure.delete(key: _refreshKey);
      }
    } catch (_) {}
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secure.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      }
      return await _secure.read(key: key);
    } catch (_) {
      return null;
    }
  }
}
