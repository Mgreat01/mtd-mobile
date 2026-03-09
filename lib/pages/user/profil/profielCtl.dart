import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/ProfileUserService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/user/profil/profileState.dart';

class ProfileCtrl extends StateNotifier<ProfileState>{
  final Ref ref;
  var profileService = getIt.get<ProfileUserService>();
  ProfileCtrl({required this.ref}) : super(ProfileState()){}

  Future<void> getUserProfil(String token) async{
    state = state.copyWith(isLoading : true);
    try{
      var userProfile = await profileService.getProfile(token);
      state = state.copyWith(user: userProfile,isLoading: false);
    }catch(e){
      state = state.copyWith(isLoading: false);
      print("Erreur : $e");
    }
  }
}

final ProfileCtrlProvider = StateNotifierProvider<ProfileCtrl,ProfileState>(
        (ref) => ProfileCtrl(ref: ref)
);