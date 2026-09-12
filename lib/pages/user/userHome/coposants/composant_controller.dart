import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/intro/appCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginCtrl.dart';
import 'package:moto_taxi_digital_mobile/framework/notification/realtimeNotificationService.dart';

class ComposantController extends StateNotifier<int> {
  final Ref ref;
  final UserLocalService _localService = getIt.get<UserLocalService>();

  ComposantController(this.ref) : super(0);

  void setIndex(int index) {
    state = index;
  }

  Future<void> logout() async {
    // La sortie de l'espace connecté ne dépend pas du réseau ni du cache.
    // Les états sont d'abord remis à zéro pour permettre la navigation.
    unawaited(getIt.get<RealtimeNotificationService>().disconnect());
    state = 0;
    ref.read(appCtrlProvider.notifier).resetUserInMemory();
    ref.read(loginControllerProvider.notifier).resetUserInMemory();
    unawaited(_clearPersistedSession());
  }

  Future<void> _clearPersistedSession() async {
    try {
      await _localService.deleteUser();
    } catch (error) {
      // La prochaine connexion remplacera la session restante si le stockage
      // local est momentanément indisponible.
      print("Nettoyage local de déconnexion impossible: $error");
    }
  }
}

final navigationIndexProvider =
    StateNotifierProvider.autoDispose<ComposantController, int>((ref) {
      return ComposantController(ref);
    });
