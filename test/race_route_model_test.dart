import 'package:flutter_test/flutter_test.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';

void main() {
  test('parse les coordonnées Laravel et la route GeoJSON Mapbox', () {
    final race = Race.fromJson({
      'id': 57,
      'name': 'Course',
      'date': '2026-08-12',
      'starting_point': 'Départ',
      'destination': 'Arrivée',
      'lat_start': '-4.42344900',
      'lng_start': '15.30945800',
      'lat_end': '-4.32500000',
      'lng_end': '15.31300000',
      'status': 'ongoing',
      'client_id': 6,
      'created_at': '2026-08-12T10:00:00Z',
      'updated_at': '2026-08-12T10:00:00Z',
    });

    final route = RaceRouteModel.fromJson({
      'race_id': 57,
      'route_to_passenger': {
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            [15.309458, -4.423449],
            [15.313, -4.325],
          ],
        },
        'distance': 1250,
        'duration': 420,
        'polyline': '',
      },
    });

    expect(race.startLat, -4.423449);
    expect(race.startLng, 15.309458);
    expect(route.route.geometry.coordinates, hasLength(2));
    expect(route.route.distance, 1250);
  });
}
