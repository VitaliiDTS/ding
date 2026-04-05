import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists a minimal session record so the app can allow offline access
/// after a previous successful login.
///
/// Only the email and display name are stored — never the password.
class SessionStorageService {
  static const _storage = FlutterSecureStorage();

  static const _hasSessionKey = 'has_session';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';

  Future<void> saveSession({
    required String email,
    required String name,
  }) async {
    await _storage.write(key: _hasSessionKey, value: 'true');
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userNameKey, value: name);
  }

  Future<bool> hasSession() async {
    final value = await _storage.read(key: _hasSessionKey);
    return value == 'true';
  }

  Future<String?> getUserEmail() async =>
      _storage.read(key: _userEmailKey);

  Future<String?> getUserName() async =>
      _storage.read(key: _userNameKey);

  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
