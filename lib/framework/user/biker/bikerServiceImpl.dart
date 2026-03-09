import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/biker/biker.dart';
import 'package:moto_taxi_digital_mobile/business/models/wallet/wallet.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/biker/bikerService.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import '../../../utils/appConfig.dart';

class BikerServiceImpl implements BikerService {

  String get baseUrl => AppConfig.apiUrl;
  String tokens = GetStorage().read('token');

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  @override
  Future<List<Biker>> getAllBikers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers'),
    );

    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((e) => Biker.fromJson(e))
        .toList();
  }

  @override
  Future<Biker> getBikerById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/$id'),
    );

    return Biker.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> deleteBiker(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/api/bikers/$id'),
      headers:  _headers(tokens),
    );
  }

  @override
  Future<List<dynamic>> getBikerRaces(int bikerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/$bikerId/races'),
      headers:  _headers(tokens),
    );

    final data = jsonDecode(response.body);
    print(data['races']);
    return data['races'];
  }

  @override
  Future<List<Biker>> getAvailableBikers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/available'),
      headers:  _headers(tokens),
    );

    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((e) => Biker.fromJson(e))
        .toList();
  }

  @override
  Future<dynamic> getBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/wallets/balance'),
      headers: _headers(tokens),
    );
    final data = jsonDecode(response.body);
    return (data['balance']);
  }

  @override
  Future<List<Race>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikers/races'),
      headers: _headers(tokens),
    );
    final data = jsonDecode(response.body);
    final raceData = data['races'];
    print("ls courses sont de ces cotes la ${raceData}");
    return (raceData as List)
        .map((e) => Race.fromJson(e))
        .toList();
  }

  @override
  Future getPrices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/price-lists'),
      headers: _headers(tokens),
    );
    final data = jsonDecode(response.body);
    print(data);
    final reponse = data['price_lists'];
    debugPrint("voila les prix ${reponse}");
    return reponse;

  }

  @override
  Future<void> updateLocation({required double lat, required double lng, required bool isActive}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/biker/update-location'),
        headers: _headers(tokens),
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
      headers: _headers(tokens),
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
}
