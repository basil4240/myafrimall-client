import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage instance = AppStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // Writes must stay sequential. On web the backing store lazily generates an
  // AES key on first write; two concurrent writes each generate their own and
  // race to persist it, leaving whichever value lost the race encrypted under
  // a key that no longer exists, so reading it throws OperationError.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _read(_accessKey);
  Future<String?> getRefreshToken() => _read(_refreshKey);

  Future<bool> hasTokens() async {
    final token = await _read(_accessKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (_) {
      await _wipe();
    }
  }

  // On web the backing store is encrypted with a key held in localStorage. If
  // that pair ever desyncs, every read throws OperationError -- which would
  // otherwise escape into app startup and the Dio auth interceptor. Treat an
  // unreadable store as logged-out and discard it so the next login recovers.
  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      await _wipe();
      return null;
    }
  }

  Future<void> _wipe() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
