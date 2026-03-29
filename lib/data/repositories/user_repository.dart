import 'package:ding/data/models/user_model.dart';

abstract class UserRepository {
  Future<void> register(UserModel user);
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser();
  Future<void> logout();
}
