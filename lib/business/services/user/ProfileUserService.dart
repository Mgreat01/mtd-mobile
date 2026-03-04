import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/appConfig.dart';
import '../../models/user/user.dart';

class ProfileUserService {
   String get baseUrl => AppConfig.apiUrl.endsWith('/') ? '${AppConfig.apiUrl}api' : '${AppConfig.apiUrl}/api';

  Future<User> getProfile(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return User.fromJson(data['data'] ?? data);
    } else {
      throw Exception('Erreur API (${res.statusCode})');
    }
  }
}