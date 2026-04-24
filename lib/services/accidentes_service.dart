import 'package:dio/dio.dart';
import 'package:parcial_2/core/constants/api_constants.dart';
import 'package:parcial_2/models/accidente_model.dart';

class AccidentesService {
  final Dio _dio;

  AccidentesService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.accidentesBaseUrl,
              ),
            );

  Future<List<AccidenteModel>> fetchAll() async {
    final response = await _dio.get('', queryParameters: {
      '\$limit': 100000,
    });

    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data.map((json) => AccidenteModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar accidentes');
    }
  }
}
