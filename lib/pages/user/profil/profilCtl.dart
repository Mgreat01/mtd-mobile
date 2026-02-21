import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/ProfileUserService.dart';
import 'package:moto_taxi_digital_mobile/pages/user/profil/profilState.dart';

final profileProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final apiService = ProfileUserService();
  return ProfileController(apiService);
});

class ProfileController extends StateNotifier<ProfileState> {
  final ProfileUserService _api;

  ProfileController(this._api) : super(ProfileState());

  Future<void> loadProfile(String token) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _api.getProfile(token);
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  void clear() {
    state = ProfileState();
  }
}