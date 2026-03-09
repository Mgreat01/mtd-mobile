import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/framework/race/raceServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/framework/user/biker/bikerServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import 'dart:async';

class UserHomeController extends StateNotifier<UserHomeState> {
  final RaceService _raceService;
  final BikerService _bikerService;
  Timer? _refreshTimer;

  UserHomeController(this._raceService, this._bikerService)
      : super(UserHomeState(myLocation: LatLng(-4.322447, 15.307045))) {
    refreshBikers();
    _startTimer();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      refreshBikers();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshBikers() async {
    try {
      final bikers = await _bikerService.getActiveBikers();
      state = state.copyWith(nearbyBikers: bikers);
      print("Positions des motards mises à jour : ${bikers.length} trouvés");
    } catch (e, stackTrace) {

    }
  }

  void selectBiker(BikerMarkerData biker) {
    state = state.copyWith(selectedBiker: biker);
  }

  void cancelRace() async {
    if (state.currentRace != null) {
      try {

        await _raceService.deletedRace(state.currentRace!.id);

        state = state.copyWith(
            currentRace: null,
            selectedBiker: null,
            step: UserStep.searching
        );
      } catch (e) {
        print("Erreur lors de l'annulation: $e");
      }
    }
  }

  Future<void> confirmBooking({
    required String destinationName,
    required int priceListId,
  }) async {
    if (state.selectedBiker == null) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final newRace = Race(
        id: 0,
        name: "Course vers $destinationName",
        date: DateTime.now().toIso8601String(),
        startingPoint: "${state.myLocation.latitude},${state.myLocation.longitude}",
        destination: destinationName,
        status: 'pending',
        bikerId: state.selectedBiker!.id,
        clientId: 0,
        priceListId: priceListId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdRace = await _raceService.createRace(newRace);
      state = state.copyWith(currentRace: createdRace, step: UserStep.inRace, isLoading: false);

    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Erreur : $e");
    }
  }
}

final userHomeControllerProvider = StateNotifierProvider<UserHomeController, UserHomeState>((ref) {
  return UserHomeController(RaceServiceImpl(), BikerServiceImpl());
});