import '../../business/models/user/user.dart';

class RegisterState {
  final bool isLoading;
  final String? error;
  final User? user;

  const RegisterState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}