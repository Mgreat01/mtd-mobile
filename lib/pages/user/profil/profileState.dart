
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
class ProfileState {
  final bool loading;
  final User? user;
  final String? error;

  ProfileState({this.loading = false, this.user, this.error});

  ProfileState copyWith({bool? loading, User? user, String? error}) {
    return ProfileState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}