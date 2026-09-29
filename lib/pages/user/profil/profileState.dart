
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
class ProfileState {
  final bool isLoading;
  final User? user;
  final String? error;

  ProfileState({this.isLoading = false, this.user, this.error});

  ProfileState copyWith({bool? isLoading, User? user, String? error}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}