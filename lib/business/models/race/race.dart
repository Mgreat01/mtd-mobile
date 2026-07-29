class Race {
  final int id;
  final String name;
  final String date;
  final String startingPoint;
  final String destination;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  final String status;
  final String? pinCode;
  final int? bikerId;
  final int clientId;
  final int? priceListId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Race({
    required this.id,
    required this.name,
    required this.date,
    required this.startingPoint,
    required this.destination,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    required this.status,
    this.pinCode,
    this.bikerId,
    required this.clientId,
    this.priceListId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    int parseRequiredInt(String key) {
      final value = int.tryParse(json[key]?.toString() ?? '');
      if (value == null) {
        throw FormatException("Champ '$key' invalide dans la course");
      }
      return value;
    }

    DateTime parseDate(String key) {
      return DateTime.tryParse(json[key]?.toString() ?? '') ?? DateTime.now();
    }

    return Race(
      id: parseRequiredInt('id'),
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      startingPoint: json['starting_point'] ?? '',
      destination: json['destination'] ?? '',
      startLat: json['start_lat'] != null
          ? double.parse(json['start_lat'].toString())
          : null,
      startLng: json['start_lng'] != null
          ? double.parse(json['start_lng'].toString())
          : null,
      endLat: json['end_lat'] != null
          ? double.parse(json['end_lat'].toString())
          : null,
      endLng: json['end_lng'] != null
          ? double.parse(json['end_lng'].toString())
          : null,

      status: json['status'] ?? 'pending',
      pinCode: json['pin_code']?.toString(),
      bikerId: int.tryParse(json['biker_id']?.toString() ?? ''),
      clientId: parseRequiredInt('client_id'),
      priceListId: int.tryParse(json['price_list_id']?.toString() ?? ''),
      createdAt: parseDate('created_at'),
      updatedAt: parseDate('updated_at'),
      deletedAt: DateTime.tryParse(json['deleted_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'starting_point': startingPoint,
      'destination': destination,
      'start_lat': startLat,
      'start_lng': startLng,
      'end_lat': endLat,
      'end_lng': endLng,
      'status': status,
      'pin_code': pinCode,
      'biker_id': bikerId,
      'client_id': clientId,
      'price_list_id': priceListId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

class RaceRouteModel {
  final int raceId;
  final RouteData route;

  RaceRouteModel({required this.raceId, required this.route});

  factory RaceRouteModel.fromJson(Map<String, dynamic> json) {
    final routeJson = json['route_to_passenger'] ?? json['route'];
    if (routeJson is! Map<String, dynamic>) {
      throw const FormatException(
        "Données d'itinéraire absentes de la réponse",
      );
    }

    return RaceRouteModel(
      raceId: int.parse(json['race_id'].toString()),
      route: RouteData.fromJson(routeJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {'race_id': raceId, 'route': route.toJson()};
  }
}

class RouteData {
  final Geometry geometry;
  final double distance;
  final double duration;
  final String polyline;

  RouteData({
    required this.geometry,
    required this.distance,
    required this.duration,
    required this.polyline,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      geometry: Geometry.fromJson(json['geometry']),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      polyline: json['polyline']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geometry': geometry.toJson(),
      'distance': distance,
      'duration': duration,
      'polyline': polyline,
    };
  }
}

class Geometry {
  final String type;
  final List<List<double>> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'],
      coordinates: (json['coordinates'] as List)
          .map(
            (coord) =>
                (coord as List).map((c) => (c as num).toDouble()).toList(),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }
}
