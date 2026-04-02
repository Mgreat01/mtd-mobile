import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'BikerHistoryState.dart';

final BikerHistoryControllerProvider = StateNotifierProvider.autoDispose<BikerHistoryController, BikerHistoryState>((ref) {
  return BikerHistoryController();
});

class BikerHistoryController extends StateNotifier<BikerHistoryState> {
  final RaceService _raceService = getIt.get<RaceService>();
  final BikerService _bikerService = getIt.get<BikerService>();

  BikerHistoryController() : super(BikerHistoryState()) {
    fetchRaces();
  }

  List<Race> get activeRaces {
    return state.allRaces.where((r) =>
        ['pending', 'ongoing'].contains(r.status)
    ).toList();
  }

  List<Race> get historyRaces {
    return state.allRaces.where((r) =>
        ['completed', 'cancelled'].contains(r.status)
    ).toList();
  }

  Future<void> fetchRaces() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final races = await _bikerService.getCourses();
      state = state.copyWith(allRaces: races, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Erreur de chargement : $e");
    }
  }

  Future<void> changeStatus(int raceId, String newStatus) async {
    state = state.copyWith(isLoading: true);
    try {
      await _raceService.updateRaceStatus(raceId, {'status': newStatus});
      await fetchRaces();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Échec : $e");
    }
  }

  bool get isRaceActive {
    return state.allRaces.any((race) => race.status == 'ongoing');
  }
}