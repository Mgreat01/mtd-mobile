import 'dart:async';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';

class RaceServiceImpl implements RaceService {
  String get baseUrl => AppConfig.apiUrl;
  String get tokens => GetStorage().read<String>('token') ?? '';

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  @override
  Future<Race> completedRace(dynamic race) async {
    final raceId = int.tryParse(race['id']?.toString() ?? '');
    if (raceId == null) throw const FormatException('Course invalide');
    return completeRace(raceId);
  }

  @override
  Future<Race> completeRace(int raceId) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/races/$raceId/complete'),
          headers: _headers(tokens),
        )
        .timeout(const Duration(seconds: 15));
    final data = _tryJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final race = data is Map ? data['race'] : null;
      if (race is Map) return Race.fromJson(Map<String, dynamic>.from(race));
      throw const FormatException('Course terminée absente de la réponse');
    }

    throw Exception(
      data is Map
          ? data['message'] ??
                data['error'] ??
                'Impossible de terminer la course'
          : 'Impossible de terminer la course',
    );
  }

  @override
  Future<Race> createRace(Race race) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/races'),
          headers: _headers(tokens),
          body: jsonEncode(race.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    final data = _tryJson(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final createdRace = data is Map ? data['race'] : null;
      if (createdRace is Map) {
        return Race.fromJson(Map<String, dynamic>.from(createdRace));
      }
      throw const FormatException('Course créée absente de la réponse');
    } else {
      throw Exception(
        data is Map
            ? data['message'] ??
                  data['error'] ??
                  'Erreur serveur (${response.statusCode})'
            : 'Erreur serveur (${response.statusCode})',
      );
    }
  }

  @override
  Future<int> deletedRace(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/api/races/$id'), headers: _headers(tokens))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response, 'Annulation refusée'));
    }
    // Certaines versions du serveur répondent 200 avec un message d'échec.
    if (response.body.trim().isNotEmpty && response.body.trim() != 'null') {
      final body = _tryJson(response.body);
      if (body is Map) {
        final message = body['message']?.toString().toLowerCase() ?? '';
        if (body['error'] != null ||
            body['success'] == false ||
            message.contains('only admin') ||
            message.contains('unauthorized') ||
            message.contains('refus') ||
            message.contains('impossible')) {
          throw Exception(_errorMessage(response, 'Annulation refusée'));
        }
      }
    }
    return response.statusCode;
  }

  @override
  Future<Race> getRaceById(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/races/$id'), headers: _headers(tokens))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception(
        _errorMessage(response, 'Impossible de charger la course'),
      );
    }
    final data = jsonDecode(response.body);
    if (data is! Map) throw const FormatException('Course invalide');
    return Race.fromJson(Map<String, dynamic>.from(data));
  }

  dynamic _tryJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _errorMessage(http.Response response, String fallback) {
    final data = _tryJson(response.body);
    final message = data is Map ? data['message'] ?? data['error'] : null;
    return message?.toString() ?? '$fallback (${response.statusCode})';
  }

  @override
  Future<List<Race>> getRaces() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/races'),
      headers: _headers(tokens),
    );
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Race.fromJson(json)).toList();
  }

  @override
  Future<List<Race>> showForCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/races/for-current-user'),
      headers: _headers(tokens),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger votre historique (${response.statusCode})',
      );
    }
    final data = jsonDecode(response.body);
    if (data is! List) {
      throw const FormatException('Historique des courses invalide');
    }
    return data.map((json) => Race.fromJson(json)).toList();
  }

  @override
  Future<Race> updateRaceBiker(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bikers/validations/$id'),
      headers: _headers(tokens),
      //body: jsonEncode(id),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Race.fromJson(data['race']); // on parse uniquement l'objet race
    } else {
      throw Exception(
        data['message'] ??
            data['error'] ??
            'Erreur serveur (${response.statusCode})',
      );
    }
  }

  @override
  Future<RaceRouteModel> getRaceRoute(int raceId) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/races/$raceId/route'),
          headers: _headers(tokens),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return RaceRouteModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
      _errorMessage(response, 'Impossible de récupérer la route'),
    );
  }

  @override
  Future<RaceRouteModel> confirmPassenger(int raceId) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/races/$raceId/confirmPassenger'),
          headers: _headers(tokens),
        )
        .timeout(const Duration(seconds: 20));
    final data = _tryJson(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return RaceRouteModel.fromJson({
        'race_id': raceId,
        'route': data is Map ? data['route'] : null,
      });
    }
    throw Exception(
      data is Map
          ? data['message'] ??
                data['error'] ??
                'Impossible de confirmer la course'
          : 'Impossible de confirmer la course',
    );
  }
}
