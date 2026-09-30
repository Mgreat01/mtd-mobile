import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/verifyOtp.dart';
import '../../business/models/user/user.dart';
import '../../business/services/user/userNetworkService.dart';
import 'registerState.dart';
import '../../../main.dart';

class RegisterControl extends StateNotifier<RegisterState> {
  final UserNetworkService _networkService = getIt.get<UserNetworkService>();
  RegisterControl() : super(const RegisterState());

  void storeTempUser(User user) => state = state.copyWith(user: user, error: null);
  void setPassword(String password) {
    final user = state.user;
    if (user != null) state = state.copyWith(user: user.copyWith(password: password), error: null);
  }

  Future<bool> register(User userRequest) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final createdUser = await _networkService.registerUser(userRequest);
      state = state.copyWith(isLoading: false, user: userRequest.copyWith(token: createdUser?.token));
      return createdUser != null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<User?> verifyAccount(VerifyOtp verifyOtp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _networkService.verifyOtp(verifyOtp);
      if (user != null) state = state.copyWith(isLoading: false, user: user);
      else state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      rethrow;
    }
  }

  Future<bool> linkAgent({String? numericCode, int? agentId, String? agentCode, String? qrToken}) async {
    final token = state.user?.token;
    if (token == null || token.isEmpty) {
      state = state.copyWith(error: 'Session d’inscription expirée. Vérifiez à nouveau votre e-mail.');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _networkService.linkAgent(token: token, numericCode: numericCode, agentId: agentId, agentCode: agentCode, qrToken: qrToken);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  String _parseError(dynamic e) {
    try {
      final raw = e.toString();
      final start = raw.indexOf('{');
      if (start != -1) {
        final parsed = jsonDecode(raw.substring(start));
        if (parsed['errors'] is Map) {
          return (parsed['errors'] as Map).values.expand((v) => v is List ? v : [v]).join('\n');
        }
        return parsed['message']?.toString() ?? raw;
      }
    } catch (_) {}
    return e.toString().replaceAll('Exception: ', '');
  }
}

final registerControlProvider = StateNotifierProvider<RegisterControl, RegisterState>((ref) {
  ref.keepAlive();
  return RegisterControl();
});
