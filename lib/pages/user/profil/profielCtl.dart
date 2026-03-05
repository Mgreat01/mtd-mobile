import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/user/profil/profilState.dart';

class ProfilCtrl extends StateNotifier<ProfilState> {
  final Ref ref;
  ProfilCtrl({required this.ref}) : super(ProfilState());
}