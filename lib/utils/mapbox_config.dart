import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxConfig {
  static String get accessToken => dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim() ?? '';

  static String get navigationStyle =>
      dotenv.env['MAPBOX_STYLE']?.trim().isNotEmpty == true
          ? dotenv.env['MAPBOX_STYLE']!.trim()
          : 'mapbox://styles/mapbox/navigation-day-v1';
}
