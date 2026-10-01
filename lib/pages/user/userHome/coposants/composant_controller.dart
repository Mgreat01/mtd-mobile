import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/framework/notification/realtimeNotificationService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginCtrl.dart';

class ComposantController extends StateNotifier<int> {
  ComposantController(this.ref) : super(0);

  final Ref ref;

  void setIndex(int index) {
    state = index;
  }

  Future<void> logout() async {
    unawaited(getIt.get<RealtimeNotificationService>().disconnect());
    state = 0;
    await ref.read(loginControllerProvider.notifier).logout();
  }
}

final navigationIndexProvider =
    StateNotifierProvider.autoDispose<ComposantController, int>((ref) {
      return ComposantController(ref);
    });
