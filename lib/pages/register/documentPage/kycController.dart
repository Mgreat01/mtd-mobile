import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart';
import 'kycState.dart';

class KycController extends StateNotifier<KycState> {
  final UserNetworkService _networkService = getIt.get<UserNetworkService>();
  final ImagePicker _picker = ImagePicker();

  KycController() : super(KycState());

  Future<void> pickDocument(String type) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (type == 'identity') state = state.copyWith(identityDoc: file);
      if (type == 'registration') state = state.copyWith(registrationCard: file);
      if (type == 'business') state = state.copyWith(businessLicense: file);
      if (type == 'selfie') state = state.copyWith(selfie: file);
    }
  }

  Future<bool> submitKyc(User tempUser) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdUser = await _networkService.registerUser(
        tempUser,
        profilePhoto: state.selfie,
        identityDoc: state.identityDoc,
        registrationCard: state.registrationCard,
        businessLicense: state.businessLicense,
      );

      state = state.copyWith(isLoading: false);
      return createdUser != null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  String _parseError(dynamic e) {
    try {
      final String errBody = e.toString();
      if (errBody.contains('{')) {
        final data = jsonDecode(errBody.substring(errBody.indexOf('{')));
        if (data['errors'] != null) {
          return (data['errors'] as Map).values.map((v) => (v as List).join()).join('\n');
        }
        return data['message'] ?? errBody;
      }
    } catch (_) {}
    return "Erreur de connexion au serveur";
  }
}

final kycControllerProvider = StateNotifierProvider<KycController, KycState>((ref) => KycController());