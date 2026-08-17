import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/notification/appNotification.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/biker/biker.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import '../../../utils/appConfig.dart';

class BikerServiceImpl implements BikerService {
  String get baseUrl => AppConfig.apiUrl;
  String get _token => GetStorage().read<String>('token') ?? '';

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  @override
  Future<List<Biker>> getAllBikers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/bikers'));

    final data = jsonDecode(response.body);
    return (data['data'] as List).map((e) => Biker.fromJson(e)).toList();
  }

  @override
  Future<Biker> getBikerById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/bikers/$id'));

    return Biker.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> deleteBiker(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/api/bikers/$id'),
      headers: _headers(_token),
    );
  }

  @override
  Future<List<Race>> getBikerRaces() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/races'),
      headers: _headers(_token),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Impossible de charger l'historique (${response.statusCode})",
      );
    }
    final data = jsonDecode(response.body);
    final dynamic raceData = data is List
        ? data
        : data['races'] ?? data['data'];
    if (raceData is! List) {
      throw const FormatException("Historique absent de la réponse");
    }
    return raceData
        .whereType<Map<String, dynamic>>()
        .map(Race.fromJson)
        .toList();
  }

  @override
  Future<List<Biker>> getAvailableBikers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/available'),
      headers: _headers(_token),
    );

    final data = jsonDecode(response.body);
    return (data['data'] as List).map((e) => Biker.fromJson(e)).toList();
  }

  @override
  Future<dynamic> getBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/wallets/balance'),
      headers: _headers(_token),
    );
    final data = jsonDecode(response.body);
    return (data['balance']);
  }

  @override
  Future<List<Race>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/new-races'),
      headers: _headers(_token),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les courses (${response.statusCode})',
      );
    }
    final data = jsonDecode(response.body);
    final dynamic raceData = data is List
        ? data
        : data['races'] ?? data['data'];
    if (raceData is! List) {
      throw const FormatException("Liste de courses absente de la réponse");
    }
    return raceData
        .whereType<Map<String, dynamic>>()
        .map(Race.fromJson)
        .toList();
  }

  @override
  Future getPrices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/price-lists'),
      headers: _headers(_token),
    );
    final data = jsonDecode(response.body);
    print(data);
    final reponse = data['price_lists'];
    debugPrint("voila les prix ${reponse}");
    return reponse;
  }

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    required bool isActive,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/biker/update-location'),
        headers: _headers(_token),
        body: jsonEncode({
          'latitude': lat,
          'longitude': lng,
          'is_active': isActive,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Erreur mise à jour position: ${response.body}");
      }
    } catch (e) {
      debugPrint("Erreur réseau updateLocation: $e");
    }
  }

  @override
  Future<List<BikerMarkerData>> getActiveBikers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/active'),
      headers: _headers(_token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) {
        // --- CORRECTION ICI ---
        // On convertit en String puis on parse en double pour éviter l'erreur de type
        final double lat = double.parse(json['latitude'].toString());
        final double lng = double.parse(json['longitude'].toString());
        debugPrint("Body: ${response.body}");

        return BikerMarkerData(
          id: json['id'],
          name: json['name'] ?? 'Biker',
          position: LatLng(lat, lng),
        );
      }).toList();
    } else {
      throw Exception('Failed to load bikers');
    }
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/biker/notifications'),
      headers: _headers(_token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.statusCode);
      print(response.body);
      final list = data['notifications'];

      print("RAW LIST: $list");
      print("LENGTH: ${list.length}");
      print("status code pour notification ${response.statusCode}");

      return (data['notifications'] as List)
          .map((e) => AppNotification.fromJson(e))
          .toList();
    } else {
      debugPrint("Erreur notifications: ${response.body}");
      debugPrint("Status code: ${response.statusCode}");
      throw Exception("Erreur notifications");
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/biker/notifications/read-all'),
      headers: _headers(_token),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('Erreur lecture notifications: ${response.body}');
      throw Exception('Impossible de marquer les notifications comme lues');
    }
  }

  Future<RaceRouteModel?> getBikerPassengerTrack({
    required int raceId,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/biker/bikerPassengerTrack'),
        headers: _headers(_token),
        body: jsonEncode({
          'race_id': raceId,
          'latitude': lat,
          'longitude': lng,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Réponse track : ${response.body}');
        final data = jsonDecode(response.body);
        final routeData =
            data is Map<String, dynamic> && data['data'] is Map<String, dynamic>
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        return RaceRouteModel.fromJson(routeData);
      }

      final body = jsonDecode(response.body);
      final message = body is Map<String, dynamic>
          ? body['message'] ?? body['error']
          : null;
      throw BikerRouteException(
        message?.toString() ?? 'Erreur itinéraire (${response.statusCode})',
        response.statusCode,
      );
    } on FormatException catch (e) {
      throw Exception('Réponse itinéraire invalide : ${e.message}');
    } catch (e) {
      debugPrint("Erreur getBikerPassengerTrack: $e");
      rethrow;
    }
  }
}

class BikerRouteException implements Exception {
  final String message;
  final int? statusCode;

  const BikerRouteException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
