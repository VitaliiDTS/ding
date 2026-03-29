import 'package:ding/data/models/user_model.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/data/services/storage_service.dart';

class LocalUserRepository implements UserRepository {
  final StorageService _storage;

  static const String _currentUserKey = 'current_user_email';
  static const String _userPrefix = 'user_';

  const LocalUserRepository({required StorageService storage})
      : _storage = storage;

  String _userKey(String email) => '$_userPrefix$email';

  @override
  Future<void> register(UserModel user) async {
    await _storage.write(_userKey(user.email), user.toJsonString());
    await _storage.write(_currentUserKey, user.email);
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    final jsonString = await _storage.read(_userKey(email));
    if (jsonString == null) return null;

    final user = UserModel.fromJsonString(jsonString);
    if (user.password != password) return null;

    await _storage.write(_currentUserKey, email);
    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final email = await _storage.read(_currentUserKey);
    if (email == null) return null;

    final jsonString = await _storage.read(_userKey(email));
    if (jsonString == null) return null;

    return UserModel.fromJsonString(jsonString);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final currentEmail = await _storage.read(_currentUserKey);
    if (currentEmail != null && currentEmail != user.email) {
      await _storage.delete(_userKey(currentEmail));
    }
    await _storage.write(_userKey(user.email), user.toJsonString());
    await _storage.write(_currentUserKey, user.email);
  }

  @override
  Future<void> deleteUser() async {
    final email = await _storage.read(_currentUserKey);
    if (email != null) {
      await _storage.delete(_userKey(email));
    }
    await _storage.delete(_currentUserKey);
  }

  @override
  Future<void> logout() async {
    await _storage.delete(_currentUserKey);
  }
}
