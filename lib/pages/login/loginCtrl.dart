import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/authentification.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/intro/appCtrl.dart';
import 'loginState.dart';

class LoginController extends StateNotifier<LoginState> {
  final UserNetworkService _networkService = getIt.get<UserNetworkService>();
  final UserLocalService _localService = getIt.get<UserLocalService>();
  final Ref ref;

  LoginController(this.ref) : super(const LoginState());


  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final auth = Authentication(email: email, password: password);
      final user = await _networkService.login(auth);

      if (user != null && user.token != null) {
        await _localService.saveUser(user);
        ref.read(appCtrlProvider.notifier).updateUser(user);

        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          error: "Identifiants invalides ou compte non reconnu.",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _localService.deleteUser();
    state = const LoginState();
  }
}

// Provider global
final loginControllerProvider = StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(ref);
});