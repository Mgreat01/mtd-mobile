import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../business/models/user/user.dart';
import '../../business/services/user/userLocalService.dart';
import '../../business/services/user/userNetworkService.dart';
import '../../main.dart';
import 'appState.dart';

class AppCtrl extends StateNotifier<AppState> {
  var userLocalService = getIt<UserLocalService>();
  var userNetworkService = getIt<UserNetworkService>();

  AppCtrl() : super(AppState(isLoading: true)) {
    getUser();
  }

  void updateUser(User? user) {
    state = state.copyWith(user: user, error: null, isLoading: false);
  }

  Future<void> getUser() async {
    try {
      var user = await userLocalService.getUser();
      final token = user?.token;
      if (user != null && token != null && token.isNotEmpty) {
        // Afficher immédiatement la session locale. La validation distante ne
        // doit jamais bloquer la reprise de l'application.
        state = AppState(user: user, isLoading: false);
        try {
          await userNetworkService.getUserProfile(token);
        } on SessionExpiredException {
          await userLocalService.deleteUser();
          user = null;
          state = AppState(user: null, isLoading: false);
        } catch (_) {
          // Une panne rÃ©seau ne doit pas dÃ©connecter une session locale valide.
        }
        return;
      } else if (user != null) {
        await userLocalService.deleteUser();
        user = null;
      }
      state = AppState(user: user, isLoading: false);
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

  void resetUserInMemory() {
    state = AppState(user: null, error: null, isLoading: false);
  }
}

final appCtrlProvider = StateNotifierProvider<AppCtrl, AppState>((ref) {
  ref.keepAlive();
  return AppCtrl();
});
