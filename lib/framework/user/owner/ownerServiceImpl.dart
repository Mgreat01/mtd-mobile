import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/owner/ownerService.dart';
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';

class OwnerServiceImpl implements OwnerService {

  String get baseUrl => AppConfig.apiUrl;
  String tokens = GetStorage().read('token');

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  @override
  Future<Bike> getAssignatedBike() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bikes/assigned'),
      headers: _headers(tokens)
    );

    final data = jsonDecode(response.body);
    return data;
  }

  @override
  Future<List<Bike>> getAvailableBike() async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/bikes/available'),
        headers: _headers(tokens)
    );

    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((e) => Bike.fromJson(e))
        .toList();
  }

  @override
  Future<List<Bike>> getByOwner() async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/bikes/owners'),
        headers: _headers(tokens)
    );

    final data = jsonDecode(response.body);
    print(data);
    return (data as List)
        .map((e) => Bike.fromJson(e))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> stat() async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/bikes/stats'),
        headers: _headers(tokens)
    );

    final data = jsonDecode(response.body);
    print(data);
    return data as Map<String, dynamic>;
  }
  
  
}