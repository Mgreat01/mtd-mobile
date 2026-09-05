import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';

class RaceServiceImpl implements RaceService {
  String get baseUrl => AppConfig.apiUrl;
  String tokens = GetStorage().read('token');

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  @override
  Future<Race> completedRace(dynamic race) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/races/${race['id']}/complete'),
      headers: _headers(tokens),
      body: jsonEncode(race),
    );
    final data = jsonDecode(response.body);
    return Race.fromJson(data);
  }

  @override
  Future<Race> completeRace(int raceId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/races/$raceId/complete'),
      headers: _headers(tokens),
    );
    final data = jsonDecode(response.body);

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
    final response = await http.post(
      Uri.parse('$baseUrl/api/races'),
      headers: _headers(tokens),
      body: jsonEncode(race.toJson()),
    );
    debugPrint("bla bla ${response.body}");
    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Course créée avec succès : ${data['id']}");
      final bodyy = jsonDecode(response.body);

      final race = Race.fromJson(bodyy["race"]);

      return race;
    } else {
      print(
        "echec de la course : ${response.body} et la status ${response.statusCode}",
      );
      debugPrint(
        "echec de la course : ${response.body} et la status ${response.statusCode}",
      );
      throw Exception(
        data['message'] ??
            data['error'] ??
            'Erreur serveur (${response.statusCode})',
      );
    }
  }

  @override
  Future<int> deletedRace(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/races/$id'),
      headers: _headers(tokens),
    );
    return response.statusCode;
  }

  @override
  Future<Race> getRaceById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/races/$id'),
      headers: _headers(tokens),
    );
    final data = jsonDecode(response.body);
    return Race.fromJson(data);
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
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Race.fromJson(json)).toList();
  }

  @override
  Future<Race> updateRaceBiker(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bikers/validations/${id}'),
      headers: _headers(tokens),
      //body: jsonEncode(id),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print(
        "Course mise à jour avec succès : ${data['race']['id']} avec biker_id ${data['biker_id']}",
      );
      return Race.fromJson(data['race']); // on parse uniquement l'objet race
    } else {
      print("Échec de la mise à jour : ${response.body}");
      throw Exception(
        data['message'] ??
            data['error'] ??
            'Erreur serveur (${response.statusCode})',
      );
    }
  }

  @override
  Future<RaceRouteModel> getRaceRoute(int raceId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/races/$raceId/route'),

      headers: _headers(tokens),
    );

    if (response.statusCode == 200) {
      return RaceRouteModel.fromJson(jsonDecode(response.body));
    }
    debugPrint("pro récupérer la route " + response.body);
    throw Exception("Impossible de récupérer la route");
  }

  @override
  Future<RaceRouteModel> confirmPassenger(int raceId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/races/$raceId/confirmPassenger'),
      headers: _headers(tokens),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return RaceRouteModel.fromJson({
        'race_id': raceId,
        'route': data['route'],
      });
    }
    throw Exception(data['message'] ?? 'Impossible de confirmer la course');
  }
}
