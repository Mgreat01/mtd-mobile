import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

class UserNetworkServiceImpl implements UserNetworkService {
  String get baseUrl => AppConfig.apiUrl;
  String get tokens => GetStorage().read<String>('token') ?? '';

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

      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: data)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(_responseMessage(response));
      }

      // La réponse de connexion contient un jeton : ne pas l'imprimer.

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
    } on TimeoutException {
      throw Exception('Le serveur met trop de temps Ã  rÃ©pondre. RÃ©essayez.');
    } on http.ClientException catch (e) {
      throw Exception("Problème réseau : $e");
    } on FormatException {
      throw Exception("Réponse du serveur invalide.");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    if (tokens.isEmpty) return;
    final response = await http
        .post(Uri.parse('$baseUrl/api/logout'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200 && response.statusCode != 401) {
      throw Exception(_responseMessage(response));
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/forgot-password'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_responseMessage(response));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/reset-password'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'token': token,
            'password': password,
            'password_confirmation': password,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_responseMessage(response));
    }
  }

  String _responseMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final errors = body['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty)
              return value.first.toString();
          }
        }
        final message = body['message'] ?? body['error'];
        if (message != null) return message.toString();
      }
    } catch (_) {
      // Réponse non JSON : utiliser le message HTTP générique ci-dessous.
    }
    return 'Impossible de traiter la demande (${response.statusCode}).';
  }

  @override
  Future<bool> verifyOtp(VerifyOtp verifyOtp) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/verify-otp'),
            headers: _headers,
            body: jsonEncode(verifyOtp.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) return true;

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? "Code incorrect ou expiré.");
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendOtp(String email) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/resend-otp'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email.trim().toLowerCase()}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_responseMessage(response));
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

      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      final fields = user.toMultipartFields();
      fields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      File? fileToUpload;
      if (profilePhoto != null && await profilePhoto.exists()) {
        fileToUpload = profilePhoto;
      } else if (user.photo != null) {
        final photoFile = File(user.photo!);
        if (await photoFile.exists()) fileToUpload = photoFile;
      }

      if (fileToUpload != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', fileToUpload.path),
        );
      }

      Future<void> addFileIfValid(String key, File? file) async {
        if (file != null && await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(key, file.path));
        }
      }

      await addFileIfValid('identity_document', identityDoc);
      await addFileIfValid('registration_card', registrationCard);
      await addFileIfValid('business_license', businessLicense);

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 40),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? "Erreur serveur (${response.statusCode})",
        );
      }
    } on SocketException {
      throw Exception(
        "Impossible de joindre le serveur. Vérifiez votre connexion ou l'URL.",
      );
    } on http.ClientException catch (e) {
      throw Exception("Erreur HTTP : $e");
    }
  }

  @override
  Future<User?> getUserProfile(String token) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/profile'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const SessionExpiredException();
    }
    if (response.statusCode != 200) {
      throw Exception(_responseMessage(response));
    }
    final body = jsonDecode(response.body);
    final data = body is Map ? body['data'] : null;
    if (data is! Map) {
      throw const FormatException('Profil utilisateur absent de la réponse');
    }
    return User.fromJson(Map<String, dynamic>.from(data));
  }

  Future<String> getAddressFromLatLng(double lat, double lon) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json",
    );
    final response = await http.get(
      url,
      headers: {"User-Agent": "moto_taxi_digital_mobile"},
    );

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

    final encoded = Uri.encodeQueryComponent(query);

    final left = 15.2;
    final right = 15.4;
    final bottom = -4.4;
    final top = -4.2;

    String url =
        "https://nominatim.openstreetmap.org/search"
        "?q=$encoded"
        "&format=json"
        "&limit=15"
        "&addressdetails=1"
        "&viewbox=$left,$top,$right,$bottom"
        "&bounded=1";

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {"User-Agent": "moto_taxi_app (ephraimmonga5@gmail.com)"},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isEmpty) return [];

        final Distance distance = Distance();

        List<SearchResult> results = data
            .map((item) {
              final lat = double.tryParse(item['lat'].toString());
              final lon = double.tryParse(item['lon'].toString());

              if (lat == null || lon == null) return null;

              double? dist;
              if (userLocation != null) {
                dist = distance(userLocation, LatLng(lat, lon));
              }

              return SearchResult(
                location: LatLng(lat, lon),
                displayName: item['display_name'] ?? "Lieu inconnu",
                distanceFromUser: dist,
              );
            })
            .whereType<SearchResult>()
            .toList();

        if (userLocation != null) {
          results.sort(
            (a, b) => (a.distanceFromUser ?? double.infinity).compareTo(
              b.distanceFromUser ?? double.infinity,
            ),
          );
        }

        return results;
      } else {
        print("Erreur Nominatim: ${response.statusCode}");
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
        throw Exception(
          "Impossible de récupérer le solde (${response.statusCode})",
        );
      }
    } catch (e) {
      throw Exception("Erreur Wallet: $e");
    }
  }
}
