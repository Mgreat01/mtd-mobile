import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/verifyOtp.dart';
import '../../business/models/user/user.dart';
import '../../business/services/user/userLocalService.dart';
import '../../business/services/user/userNetworkService.dart';
import 'registerState.dart';
import '../../../main.dart';

class RegisterControl extends StateNotifier<RegisterState> {
  final UserNetworkService _networkService = getIt.get<UserNetworkService>();
  final UserLocalService _localService = getIt.get<UserLocalService>();

  RegisterControl() : super(const RegisterState());

  void storeTempUser(User user) {
    state = state.copyWith(user: user, error: null);
  }

  Future<bool> register(User userRequest) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final createdUser = await _networkService.registerUser(userRequest);
      if (createdUser != null) {
        state = state.copyWith(isLoading: false, user: createdUser);
        return true;
      }
      state = state.copyWith(isLoading: false, error: "Échec de l'inscription");
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  String _parseError(dynamic e) {
    try {
     final rawString = e.toString();
      final jsonStart = rawString.indexOf('{');
      if (jsonStart != -1) {
        final jsonPart = rawString.substring(jsonStart);
        final Map<String, dynamic> parsed = jsonDecode(jsonPart);

        if (parsed.containsKey('errors')) {
          final errors = parsed['errors'] as Map<String, dynamic>;
          return errors.values.expand((v) => v is List ? v : [v]).join('\n');
        }
        return parsed['message'] ?? rawString;
      }
    } catch (err) {
      print("Erreur de parsing des erreurs: $err");
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  Future<bool> verifyAccount(VerifyOtp verifyOtp) async {
    try {
      return await _networkService.verifyOtp(verifyOtp);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}


final registerControlProvider = StateNotifierProvider<RegisterControl, RegisterState>((ref) {
  ref.keepAlive();
  return RegisterControl();
});