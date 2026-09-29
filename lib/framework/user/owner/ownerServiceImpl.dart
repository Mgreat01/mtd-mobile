import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/owner/ownerService.dart';
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';

class OwnerServiceImpl implements OwnerService {
  String get baseUrl => AppConfig.apiUrl;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer ${GetStorage().read<String>('token') ?? ''}',
  };

  Future<dynamic> _get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/$endpoint'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger les motos (${response.statusCode})',
      );
    }
    return jsonDecode(response.body);
  }

  List<Bike> _bikesFromJson(dynamic data) {
    final items = data is List
        ? data
        : data is Map
        ? data['data']
        : null;
    if (items is! List) {
      throw const FormatException('Liste de motos absente de la réponse');
    }
    return items
        .whereType<Map>()
        .map((item) => Bike.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<Bike>> getAssignatedBike() async =>
      (await getByOwner()).where((bike) => bike.bikerId != null).toList();

  @override
  Future<List<Bike>> getAvailableBike() async =>
      _bikesFromJson(await _get('bikes/available'));

  @override
  Future<List<Bike>> getByOwner() async =>
      _bikesFromJson(await _get('bikes/owners'));

  @override
  Future<Map<String, dynamic>> stat() async {
    final data = await _get('bikes/stats');
    if (data is! Map) {
      throw const FormatException('Statistiques des motos invalides');
    }
    return Map<String, dynamic>.from(data);
  }
}
