import 'dart:convert';
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
  Future<Race> createRace(Race race) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/races'),
      headers: _headers(tokens),
      body: jsonEncode(race.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Course créée avec succès : ${data['id']}");
      return Race.fromJson(data);
    } else {
      print("echec de la course : ${ response.body}");
      throw Exception(data['message'] ?? data['error'] ?? 'Erreur serveur (${response.statusCode})');
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
  Future<Race> updateRaceStatus(int id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/races/updateStatus/$id'),
      headers: _headers(tokens),
      body: jsonEncode(updates),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("Course mise à jour avec succès : ${data['id']}");
      return Race.fromJson(data);
    } else {
      print("Échec de la mise à jour : ${response.body}");
      throw Exception(data['message'] ?? data['error'] ?? 'Erreur serveur (${response.statusCode})');
    }
  }



}
