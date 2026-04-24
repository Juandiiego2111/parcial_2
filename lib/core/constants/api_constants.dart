import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get accidentesBaseUrl =>
      dotenv.env['ACCIDENTES_BASE_URL'] ??
      'https://www.datos.gov.co/resource/ezt8-5wyj.json';

  static String get parqueaderoBaseUrl =>
      dotenv.env['PARQUEADERO_BASE_URL'] ??
      'https://parking.visiontic.com.co/api';
}
