import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/framework/race/raceServiceImpl.dart';
import 'confirmRaceState.dart';

final confirmRaceControllerProvider = StateNotifierProvider.family<ConfirmRaceController, ConfirmRaceState, ConfirmRaceState>((ref, initialState) {
  return ConfirmRaceController(initialState);
});

class ConfirmRaceController extends StateNotifier<ConfirmRaceState> {
  final RaceServiceImpl _raceService = RaceServiceImpl();

  ConfirmRaceController(ConfirmRaceState state) : super(state);

  Future<Race?> confirmAndCreate() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final newRace = Race(
        id: 0,
        name: "Course vers ${state.destinationName}",
        date: DateTime.now().toIso8601String().split('T')[0],
        startingPoint: state.startAddress,
        destination: state.destinationName,
        status: 'pending',
        bikerId: state.selectedBiker.id,
        clientId: 0,
        priceListId: state.priceListId ?? 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdRace = await _raceService.createRace(newRace);

      state = state.copyWith(isLoading: false);
      return createdRace;
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return null;
    }
  }
}