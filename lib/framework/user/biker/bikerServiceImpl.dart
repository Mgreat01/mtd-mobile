import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/notification/appNotification.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/biker/biker.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/framework/cache/appCacheStore.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import '../../../utils/appConfig.dart';

class BikerServiceImpl implements BikerService {
  final AppCacheStore _cache = AppCacheStore();

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
    return _loadRacesWithCache(
      cacheKey: 'biker_races',
      endpoint: '/api/bikers/races',
      ttl: const Duration(minutes: 5),
      missingMessage: "Historique absent de la réponse",
    );
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallets/balance'),
        headers: _headers(_token),
      );
      if (response.statusCode != 200) {
        throw Exception('Solde indisponible (${response.statusCode})');
      }
      final data = jsonDecode(response.body);
      await _cache.writeJson(
        'wallet_balance',
        data,
        ttl: const Duration(minutes: 2),
      );
      return data['balance'];
    } catch (_) {
      final cached = _cache.readJson('wallet_balance', allowExpired: true);
      if (cached is Map) return cached['balance'];
      rethrow;
    }
  }

  @override
  Future<List<Race>> getCourses() async {
    return _loadRacesWithCache(
      cacheKey: 'available_races',
      endpoint: '/api/bikers/new-races',
      ttl: const Duration(seconds: 45),
      missingMessage: "Liste de courses absente de la réponse",
    );
  }

  @override
  Future getPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/price-lists'),
        headers: _headers(_token),
      );
      if (response.statusCode != 200) {
        throw Exception('Tarifs indisponibles (${response.statusCode})');
      }
      final data = jsonDecode(response.body);
      final prices = data is Map ? data['price_lists'] : null;
      if (prices is! List) {
        throw const FormatException('Liste de tarifs absente de la réponse');
      }
      await _cache.writeJson(
        'price_lists',
        prices,
        ttl: const Duration(hours: 1),
      );
      return prices;
    } catch (_) {
      final cached = _cache.readJson('price_lists', allowExpired: true);
      if (cached is List) return cached;
      rethrow;
    }
  }

  @override
  Future<void> updateLocation({
    required double lat,
    required double lng,
    required bool isActive,
    double? accuracyMeters,
    double? speedKmh,
    double? headingDegrees,
    DateTime? capturedAt,
    String? sessionId,
    int? sequence,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/biker/update-location'),
        headers: _headers(_token),
        body: jsonEncode({
          'latitude': lat,
          'longitude': lng,
          'is_active': isActive,
          if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
          if (speedKmh != null) 'speed_kmh': speedKmh,
          if (headingDegrees != null) 'heading_degrees': headingDegrees,
          if (capturedAt != null)
            'captured_at': capturedAt.toUtc().toIso8601String(),
          if (sessionId != null) 'session_id': sessionId,
          if (sequence != null) 'sequence': sequence,
        }),
      );

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        final message = body is Map ? body['message'] ?? body['error'] : null;
        throw Exception(
          message ?? 'Mise à jour de position refusée (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint("Erreur réseau updateLocation: $e");
      rethrow;
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/biker/notifications'),
        headers: _headers(_token),
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur notifications (${response.statusCode})');
      }
      final data = jsonDecode(response.body);
      final notifications = data['notifications'];
      if (notifications is! List) {
        throw const FormatException('Notifications absentes de la réponse');
      }
      await _cache.writeJson(
        'biker_notifications',
        notifications,
        ttl: const Duration(minutes: 10),
      );
      return _notificationsFromJson(notifications);
    } catch (_) {
      final cached = _cache.readJson('biker_notifications', allowExpired: true);
      if (cached is List) return _notificationsFromJson(cached);
      rethrow;
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
    await _cache.remove('biker_notifications');
  }

  Future<List<Race>> _loadRacesWithCache({
    required String cacheKey,
    required String endpoint,
    required Duration ttl,
    required String missingMessage,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers(_token),
      );
      if (response.statusCode != 200) {
        // Le backend hÃ©bergÃ© renvoie 404 pour les anciens comptes ayant le
        // rÃ´le biker sans enregistrement dans `bikers`. Ces comptes ne peuvent
        // pas avoir de course qui leur est attribuÃ©e : pour l'interface, cela
        // correspond Ã  une liste vide et non Ã  une erreur de chargement.
        if (response.statusCode == 404 && _isMissingBikerProfile(response)) {
          await _cache.writeJson(cacheKey, const [], ttl: ttl);
          return const [];
        }
        final message = _responseMessage(response);
        throw Exception(
          message ??
              'Impossible de charger les courses (${response.statusCode})',
        );
      }
      final data = jsonDecode(response.body);
      final raceData = _raceList(data);
      if (raceData == null) throw FormatException(missingMessage);
      await _cache.writeJson(cacheKey, raceData, ttl: ttl);
      return _racesFromJson(raceData);
    } catch (_) {
      final cached = _cache.readJson(cacheKey, allowExpired: true);
      if (cached is List) return _racesFromJson(cached);
      rethrow;
    }
  }

  List<dynamic>? _raceList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final races = data['races'] ?? data['data'];
      return races is List ? races : null;
    }
    return null;
  }

  List<Race> _racesFromJson(List<dynamic> data) => data
      .whereType<Map>()
      .map((item) => Race.fromJson(Map<String, dynamic>.from(item)))
      .toList();

  List<AppNotification> _notificationsFromJson(List<dynamic> data) => data
      .whereType<Map>()
      .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item)))
      .toList();

  String? _responseMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final message = body['message'] ?? body['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // Some reverse proxies return a non-JSON error page. The status code is
      // then the only safe diagnostic to expose to the caller.
    }
    return null;
  }

  bool _isMissingBikerProfile(http.Response response) {
    final message = _responseMessage(response)?.toLowerCase();
    return message != null &&
        (message.contains('biker profile') ||
            message.contains('profil biker') ||
            message.contains('profil chauffeur'));
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
