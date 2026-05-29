import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/authentification.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/verifyOtp.dart';
import 'package:moto_taxi_digital_mobile/business/models/wallet/wallet.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:http/http.dart' as http;
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';

class UserNetworkServiceImpl implements UserNetworkService {

  String get baseUrl => AppConfig.apiUrl;
  String tokens = GetStorage().read('token')??'';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $tokens',
  };


  @override
  Future<User?> login(Authentication authentication) async {
    try {
      var url = Uri.parse('$baseUrl/api/login');
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
          final responseData = jsonDecode(response.body);
          if (responseData['data'] != null) {
            return User.fromJson(responseData['data']);
          }
          throw Exception("Format de données utilisateur inconnu.");

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
      throw Exception(e.toString());
    }
  }



  @override
  Future<bool> verifyOtp(VerifyOtp verifyOtp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otpMobile'),
        headers: _headers,
        body: jsonEncode(verifyOtp.toJson()),
      );

      if (response.statusCode == 200) return true;

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? "Code incorrect ou expiré.");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> registerUser(
      User user, {
        File? profilePhoto,
        File? identityDoc,
        File? registrationCard,
        File? businessLicense,
      }) async {
    try {
      final url = Uri.parse('$baseUrl/api/register');
      print(" Tentative d'envoi à : $url");

      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      final fields = user.toMultipartFields();
      fields.forEach((key, value) {
         request.fields[key] = value?.toString() ?? "";
      });

     File? fileToUpload;
      if (profilePhoto != null && await profilePhoto.exists()) {
        fileToUpload = profilePhoto;
      } else if (user.photo != null) {
        final photoFile = File(user.photo!);
        if (await photoFile.exists()) fileToUpload = photoFile;
      }

      if (fileToUpload != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', fileToUpload.path));
        print(" Photo de profil ajoutée : ${fileToUpload.path}");
      }

      Future<void> addFileIfValid(String key, File? file) async {
        if (file != null && await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
          print("Fichier ajouté [$key] : ${file.path}");
        }
      }

      await addFileIfValid('identity_document', identityDoc);
      await addFileIfValid('registration_card', registrationCard);
      await addFileIfValid('business_license', businessLicense);

      print(" Envoi de la requête en cours...");
      var streamedResponse = await request.send().timeout(const Duration(seconds: 40));
      var response = await http.Response.fromStream(streamedResponse);

      print("Statut Serveur : ${response.statusCode}");
      print(" Réponse Serveur : ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Erreur serveur (${response.statusCode})");
      }
    } on SocketException {
      throw Exception("Impossible de joindre le serveur. Vérifiez votre connexion ou l'URL.");
    } on http.ClientException catch (e) {
      throw Exception("Erreur HTTP : $e");
    } catch (e) {
      print(" Erreur critique dans registerUser : $e");
      rethrow;
    }
  }



  void _handleError(http.Response response) {
    final body = jsonDecode(response.body);
    final message = body['message'] ?? "Une erreur est survenue";

    switch (response.statusCode) {
      case 400: throw Exception("Requête malformée.");
      case 422:
        final errors = body['errors'];
        throw Exception(errors != null ? errors.toString() : message);
      case 500: throw Exception("Erreur serveur.");
      default: throw Exception(message);
    }
  }
  
  @override
  Future<User?> getUserProfile(String token) {
    // TODO: implement getUserProfile
    throw UnimplementedError();
  }

  Future<String> getAddressFromLatLng(double lat, double lon) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json");
    final response = await http.get(url, headers: {
      "User-Agent": "moto_taxi_digital_mobile"
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["display_name"] ?? "Adresse inconnue";
    } else {
      return "Erreur lors du reverse geocoding";
    }
  }

  @override
  Future<List<SearchResult>> searchAddresses(
      String query, {
        LatLng? userLocation,
      }) async {

    if (query.trim().length < 3) return [];

    final encoded =
    Uri.encodeQueryComponent(query);

    String url =
        "https://nominatim.openstreetmap.org/search"
        "?q=$encoded"
        "&format=json"
        "&limit=15"
        "&addressdetails=1";

    // =========================
    // PRIORITÉ VISUELLE AUX LIEUX PROCHES
    // =========================

    // IMPORTANT :
    // on utilise seulement "viewbox"
    // SANS bounded=1
    // afin d'obtenir TOUS les résultats

    if (userLocation != null) {

      final lat = userLocation.latitude;
      final lon = userLocation.longitude;

      final left = lon - 0.08;
      final right = lon + 0.08;
      final top = lat + 0.08;
      final bottom = lat - 0.08;

      url +=
      "&viewbox=$left,$top,$right,$bottom";
    }

    try {

      final response = await http.get(

        Uri.parse(url),

        headers: {
          "User-Agent":
          "moto_taxi_app (ephraimmonga5@gmail.com)"
        },

      ).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {

        final List data =
        json.decode(response.body);

        if (data.isEmpty) return [];

        final Distance distance = Distance();

        List<SearchResult> results = data.map((item) {

          final lat =
          double.tryParse(item['lat'].toString());

          final lon =
          double.tryParse(item['lon'].toString());

          if (lat == null || lon == null) {
            return null;
          }

          double? dist;

          if (userLocation != null) {

            dist = distance(

              userLocation,

              LatLng(lat, lon),
            );
          }

          return SearchResult(

            location: LatLng(lat, lon),

            displayName:
            item['display_name'] ??
                "Lieu inconnu",

            distanceFromUser: dist,
          );

        }).whereType<SearchResult>().toList();

        // =========================
        // TRI PAR DISTANCE
        // =========================

        if (userLocation != null) {

          results.sort(

                (a, b) =>

                (a.distanceFromUser ??
                    double.infinity)

                    .compareTo(

                  b.distanceFromUser ??
                      double.infinity,
                ),
          );
        }

        return results;

      } else {

        print(
            "Erreur Nominatim: "
                "${response.statusCode}"
        );
      }

    } catch (e) {

      print("Erreur réseau search: $e");
    }

    return [];
  }


  @override
  Future<Wallet> getWallet() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallets/balance'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Réponse Wallet : $data");
        return Wallet.fromJson(data);
      } else {
        throw Exception("Impossible de récupérer le solde (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Erreur Wallet: $e");
    }
  }
}