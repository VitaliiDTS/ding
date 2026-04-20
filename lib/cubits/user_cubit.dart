import 'package:ding/cubits/user_state.dart';
import 'package:ding/data/models/user_model.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._repo) : super(const UserState());

  final UserRepository _repo;

  void setUser(UserModel? user) => emit(state.copyWith(user: user));

  Future<void> loadUser() async {
    final user = await _repo.getCurrentUser();
    emit(state.copyWith(user: user));
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _repo.login(email, password);
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> register(UserModel user) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _repo.register(user);
      final current = await _repo.getCurrentUser();
      emit(state.copyWith(user: current, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateProfile(UserModel updated, String oldPassword) async {
    emit(state.copyWith(isLoading: true));
    try {
      if (updated.password.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: updated.email,
          password: oldPassword,
        );
        await FirebaseAuth.instance.currentUser
            ?.reauthenticateWithCredential(credential);
      }
      await _repo.updateUser(updated);
      final current = await _repo.getCurrentUser();
      emit(state.copyWith(user: current, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const UserState());
  }

  Future<void> deleteAccount() async {
    try {
      await _repo.deleteUser();
      emit(const UserState());
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
