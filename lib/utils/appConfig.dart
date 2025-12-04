import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String apiUrl;

  // Initialisation asynchrone (à appeler une seule fois au démarrage)
  static Future<void> initialize() async {

    // Charger .env
    await dotenv.load(fileName: ".env");

    // Définir les valeurs avec fallback pour dev/test
    apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  }
}