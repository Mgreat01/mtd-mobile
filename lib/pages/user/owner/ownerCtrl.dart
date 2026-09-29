import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/owner/ownerService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerState.dart';

class OwnerController extends StateNotifier<OwnerState> {
  final OwnerService _ownerService;

  OwnerController({OwnerService? service})
    : _ownerService = service ?? getIt.get<OwnerService>(),
      super(OwnerState()) {
    loadOwnerData();
  }

  Future<void> loadOwnerData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _ownerService.stat(),
        _ownerService.getByOwner(),
      ]);
      if (!mounted) return;

      state = state.copyWith(
        stats: results[0] as Map<String, dynamic>,
        bikes: results[1] as List<Bike>,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final ownerProvider = StateNotifierProvider.autoDispose<OwnerController, OwnerState>(
  (ref) => OwnerController(),
);
