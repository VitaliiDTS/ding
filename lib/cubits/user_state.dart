import 'package:ding/data/models/user_model.dart';

class UserState {
  const UserState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) =>
      UserState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}
