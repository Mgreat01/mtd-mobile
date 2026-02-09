import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../business/models/user/user.dart';
import '../../business/services/user/userLocalService.dart';
import '../../main.dart';
import 'appState.dart';

class AppCtrl  extends StateNotifier<AppState>{
  var userLocalService=getIt<UserLocalService>();

AppCtrl() : super(AppState(isLoading: true)) {
    getUser();
  }

  void updateUser(User? user) {
    state = state.copyWith(user: user, error: null, isLoading: false);
  }

  Future<void> getUser() async {
    try {

      var user = await userLocalService.getUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> clearUser() async {
    try {
      state = state.copyWith(isLoading: true);
      await userLocalService.deleteUser();

      state = AppState(user: null, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }


}


final appCtrlProvider = StateNotifierProvider<AppCtrl, AppState>((ref) {
  ref.keepAlive();
  return AppCtrl();
});
