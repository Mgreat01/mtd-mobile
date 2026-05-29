import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxConfig {

  static String get accessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  static String get navigationStyle =>
      dotenv.env['MAPBOX_STYLE'] ?? '';

}