
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../business/models/user/user.dart';
import '../../business/services/user/userLocalService.dart';
import '../../main.dart';
import 'appState.dart';

class AppCtrl  extends StateNotifier<AppState>{
  var userLocalService=getIt<UserLocalService>();

  AppCtrl() : super(AppState());

  Future<void> getUser() async {
    try {
      var user = await userLocalService.getUser();
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearUser() async {
    try {
      await userLocalService.deleteUser(); // supprime aussi localement
      state = state.copyWith(user: null, error: null); // remet l’état utilisateur à null
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }


}


final appCtrlProvider = StateNotifierProvider<AppCtrl, AppState>((ref) {
  ref.keepAlive();
  return AppCtrl();
});
