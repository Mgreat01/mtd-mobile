import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../business/models/bike/bike.dart';
import '../../../business/services/bike/bikeService.dart';
import '../../../utils/appConfig.dart';

class BikeServiceImpl implements BikeService {
  String get baseUrl => AppConfig.apiUrl;
  String get tokens => GetStorage().read<String>('token') ?? '';

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  @override
  Future<List<Bike>> getAllBikes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikes'),
      headers: _headers(tokens),
    );

    final data = jsonDecode(response.body);
    return (data as List).map((e) => Bike.fromJson(e)).toList();
  }

  @override
  Future<Bike> createBike(Bike bike) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bikes'),
      headers: _headers(tokens),
      body: jsonEncode(bike.toJson()),
    );

    return Bike.fromJson(jsonDecode(response.body));
  }

  @override
  Future<Bike> updateBike(int id, Bike bike) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/bikes/$id'),
      headers: _headers(tokens),
      body: jsonEncode(bike.toJson()),
    );

    return Bike.fromJson(jsonDecode(response.body));
  }

  @override
  Future<void> deleteBike(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/api/bikes/$id'),
      headers: _headers(tokens),
    );
  }

  @override
  Future<Bike> getBikeById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikes/$id'),
      headers: _headers(tokens),
    );
    return Bike.fromJson(jsonDecode(response.body));
  }

  @override
  Future<List<Bike>> getBikesByOwner(int ownerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikes/owner/$ownerId'),
      headers: _headers(tokens),
    );

    final data = jsonDecode(response.body);
    return (data as List).map((e) => Bike.fromJson(e)).toList();
  }

  @override
  Future<List<Bike>> getBikesByBiker(int? bikerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bikes/biker/$bikerId'),
        headers: _headers(tokens),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // L'API retourne directement un tableau, pas besoin de accéder à data['data']
        final List<dynamic> jsonList = data is List ? data : [];


        return jsonList.map((json) => Bike.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Bike>> getAvailableBikes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikes/available'),
      headers: _headers(tokens),
    );

    final data = jsonDecode(response.body);
    return (data as List).map((e) => Bike.fromJson(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikes/stats'),
      headers: _headers(tokens),
    );
    return jsonDecode(response.body);
  }
}
