import 'dart:convert';
import 'package:moto_taxi_digital_mobile/business/models/user/authentification.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/verifyOtp.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:http/http.dart' as http;
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';

class UserNetworkServiceImpl implements UserNetworkService {

  String get baseUrl => AppConfig.apiUrl;


  @override
  Future<User?> login(Authentication authentication) async {
    try {
      var url = Uri.parse('$baseUrl/login');
      var data = jsonEncode(authentication.toJson());

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: data,
      );

      print("Requête envoyée à : $url");
      print("Status code : ${response.statusCode}");
      print("Réponse brute : ${response.body}");

      switch (response.statusCode) {
        case 200:
          final json = jsonDecode(response.body);
          return User.fromJson(json);

        case 400:
          throw Exception("Requête invalide.");

        case 401:
          throw Exception("Email ou mot de passe incorrect.");

        case 403:
          throw Exception("Accès refusé.");

        case 404:
          throw Exception("Endpoint introuvable.");

        case 500:
          throw Exception("Erreur interne du serveur.");

        default:
          throw Exception("Erreur inattendue (${response.statusCode}).");
      }
    } on http.ClientException catch (e) {
      throw Exception("Problème réseau : $e");

    } on FormatException catch (e) {
      throw Exception("Réponse du serveur invalide.");

    } catch (e) {
      /// ❗ Ici on ne remplace pas le message de l’erreur !
      throw Exception(e.toString());
    }
  }



  @override
  Future<bool> verifyOtp(VerifyOtp verifyOtp) {
    // TODO: implement verifyOtp
    throw UnimplementedError();
  }
}