import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/authentification.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/intro/appCtrl.dart';
import 'loginState.dart';

class LoginController extends StateNotifier<LoginState> {
  final UserNetworkService _networkService = getIt.get<UserNetworkService>();
  final UserLocalService _localService = getIt.get<UserLocalService>();
  final Ref ref;

  LoginController(this.ref) : super(const LoginState()){
    _initializeUser(); // Charge l'utilisateur au démarrage
  }


  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final auth = Authentication(email: email, password: password);
      final user = await _networkService.login(auth);

      if (user != null && user.token != null) {
        await _localService.saveUser(user);
        ref.read(appCtrlProvider.notifier).updateUser(user);
        state = state.copyWith(isLoading: false, isSuccess: true,user: user);
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

  Future<void> _initializeUser() async {
    try {
      final user = await _localService.getUser();
      if (user != null) {
        state = state.copyWith(user: user);
        print("Utilisateur chargé depuis le stockage local: ${user.email}");
      } else {
        print("Aucun utilisateur connecté");
      }
    } catch (e) {
      print("Erreur lors du chargement de l'utilisateur: $e");
    }
  }

  Future<void> logout() async {
    await _localService.deleteUser();
    state = const LoginState();
  }

  Future<void> getLocalUser() async {
    try {
      final user = await _localService.getUser();
      state = state.copyWith(user: user);
    } catch (e) {
      print("Erreur lors du chargement de l'utilisateur local: $e");
    }
  }

  Future<void> clearUser() async {
    try {
      state = state.copyWith(isLoading: true);
      await _localService.deleteUser();

      state = const LoginState(user: null, error: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// Provider global
final loginControllerProvider = StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(ref);
});