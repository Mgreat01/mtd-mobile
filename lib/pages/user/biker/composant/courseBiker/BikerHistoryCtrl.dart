import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/composant_controller.dart';
import 'BikerHistoryState.dart';

final BikerHistoryControllerProvider =
    StateNotifierProvider.autoDispose<
      BikerHistoryController,
      BikerHistoryState
    >((ref) {
      return BikerHistoryController(ref);
    });

class BikerHistoryController extends StateNotifier<BikerHistoryState> {
  final RaceService _raceService = getIt.get<RaceService>();
  final BikerService _bikerService = getIt.get<BikerService>();
  final Ref ref;

  BikerHistoryController(this.ref) : super(BikerHistoryState()) {
    fetchRaces();
  }

  List<Race> get activeRaces {
    return state.allRaces
        .where((r) => ['pending', 'ongoing'].contains(r.status))
        .toList();
  }

  List<Race> get historyRaces {
    return state.allRaces
        .where((r) => ['completed', 'cancelled'].contains(r.status))
        .toList();
  }

  Future<void> fetchRaces() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _bikerService.getCourses(),
        _bikerService.getBikerRaces(),
      ]);
      final racesById = <int, Race>{};
      for (final result in results) {
        for (final race in result) {
          racesById[race.id] = race;
        }
      }
      final races = racesById.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(allRaces: races, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Erreur de chargement : $e",
      );
    }
  }

  Future<void> changeStatus(int raceId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedRace = await _raceService.updateRaceBiker(raceId);

      final updatedRaces = state.allRaces.map((r) {
        return r.id == updatedRace.id ? updatedRace : r;
      }).toList();

      state = state.copyWith(allRaces: updatedRaces, isLoading: false);
      await ref
          .read(bikerControllerProvider.notifier)
          .applyRaceUpdate(updatedRace);
      if (updatedRace.status == 'ongoing') {
        ref.read(navigationIndexProvider.notifier).setIndex(0);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "Échec : $e");
    }
  }

  bool get isRaceActive {
    return state.allRaces.any((race) => race.status == 'ongoing');
  }
}
