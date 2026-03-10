import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/intro/appCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginCtrl.dart';

class ComposantController extends StateNotifier<int> {
  final Ref ref;
  final UserLocalService _localService = getIt.get<UserLocalService>();

  ComposantController(this.ref) : super(0);

  void setIndex(int index) {
    state = index;
  }

  Future<void> logout() async {
    try {
      await _localService.deleteUser();

      ref.read(appCtrlProvider.notifier).clearUser();
      ref.read(loginControllerProvider.notifier).clearUser();

      state = 0;

    } catch (e) {
      print("Erreur de déconnexion: $e");
    }
  }
}

final navigationIndexProvider = StateNotifierProvider.autoDispose<ComposantController, int>((ref) {
  return ComposantController(ref);
});