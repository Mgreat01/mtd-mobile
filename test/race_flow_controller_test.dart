import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userNetworkServiceImpl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

void main() {
  test(
    'une annulation refusée conserve la course et affiche une erreur',
    () async {
      final service = _RaceServiceFake(_race());
      final controller = _controller(service);
      await _book(controller);

      service.cancelFails = true;
      expect(await controller.cancelRace(), isFalse);
      expect(controller.state.currentRace?.id, 42);
      expect(controller.state.step, UserStep.waitingForBiker);
      expect(controller.state.errorMessage, contains('refusée'));
      controller.dispose();
    },
  );

  test('une course créée reste visible même si Mapbox échoue', () async {
    final service = _RaceServiceFake(_race())..routeFails = true;
    final controller = _controller(service);

    expect(await _book(controller), isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.currentRace?.id, 42);
    expect(controller.state.step, UserStep.waitingForBiker);
    controller.dispose();
  });

  test(
    'une confirmation enregistrée est récupérée après une réponse perdue',
    () async {
      final service = _RaceServiceFake(_race(bikerId: 7));
      final controller = _controller(service);
      await _book(controller);

      service.confirmResponseFails = true;
      await controller.confirmAcceptedBiker();
      expect(controller.state.currentRace?.status, 'ongoing');
      expect(controller.state.step, UserStep.inRace);
      expect(controller.state.errorMessage, isNull);
      controller.dispose();
    },
  );

  test('une fin enregistrée est récupérée après une réponse perdue', () async {
    final service = _RaceServiceFake(_race(bikerId: 7));
    final controller = _controller(service);
    await _book(controller);
    await controller.confirmAcceptedBiker();

    service.completeResponseFails = true;
    expect(await controller.completeActiveRace(), isTrue);
    expect(controller.state.currentRace, isNull);
    expect(controller.state.step, UserStep.searching);
    controller.dispose();
  });
}

UserHomeController _controller(_RaceServiceFake service) => UserHomeController(
  service,
  _BikerServiceFake(),
  UserNetworkServiceImpl(),
  initialize: false,
);

Future<bool> _book(UserHomeController controller) async {
  controller.selectSearchResult(
    SearchResult(
      location: const LatLng(-4.31, 15.31),
      displayName: 'Destination',
    ),
  );
  return controller.confirmBooking(
    destinationName: 'Destination',
    priceListId: 1,
  );
}

Race _race({int? bikerId}) => Race.fromJson({
  'id': 42,
  'name': 'Course de test',
  'date': '2026-09-30',
  'starting_point': 'Départ',
  'destination': 'Destination',
  'lat_start': -4.32,
  'lng_start': 15.30,
  'lat_end': -4.31,
  'lng_end': 15.31,
  'status': 'pending',
  'biker_id': bikerId,
  'client_id': 2,
  'price_list_id': 1,
  'created_at': '2026-09-30T10:00:00Z',
  'updated_at': '2026-09-30T10:00:00Z',
});

RaceRouteModel _route() => RaceRouteModel.fromJson({
  'race_id': 42,
  'route': {
    'geometry': {
      'type': 'LineString',
      'coordinates': [
        [15.30, -4.32],
        [15.31, -4.31],
      ],
    },
    'distance': 1500,
    'duration': 420,
  },
});

class _RaceServiceFake implements RaceService {
  _RaceServiceFake(this.race);
  Race race;
  bool cancelFails = false;
  bool routeFails = false;
  bool confirmResponseFails = false;
  bool completeResponseFails = false;

  @override
  Future<Race> createRace(Race _) async => race;

  @override
  Future<Race> getRaceById(int _) async => race;

  @override
  Future<List<Race>> showForCurrentUser() async => [race];

  @override
  Future<RaceRouteModel> getRaceRoute(int _) async {
    if (routeFails) throw Exception('Mapbox indisponible');
    return _route();
  }

  @override
  Future<int> deletedRace(int _) async {
    if (cancelFails) throw Exception('Annulation refusée');
    return 200;
  }

  @override
  Future<RaceRouteModel> confirmPassenger(int _) async {
    race = Race.fromJson({...race.toJson(), 'status': 'ongoing'});
    if (confirmResponseFails) throw Exception('Réponse perdue');
    return _route();
  }

  @override
  Future<Race> completeRace(int _) async {
    race = Race.fromJson({...race.toJson(), 'status': 'completed'});
    if (completeResponseFails) throw Exception('Réponse perdue');
    return race;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BikerServiceFake implements BikerService {
  @override
  Future<List<BikerMarkerData>> getActiveBikers() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
