import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get accidentesBaseUrl =>
      dotenv.env['ACCIDENTES_BASE_URL'] ?? '';

  static String get parqueaderoBaseUrl =>
      dotenv.env['PARQUEADERO_BASE_URL'] ?? '';
}
