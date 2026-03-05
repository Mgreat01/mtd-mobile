import 'package:flutter/foundation.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';

@immutable
class LoginState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final User? user;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    User? user
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      user: user ?? this.user
    );
  }
}