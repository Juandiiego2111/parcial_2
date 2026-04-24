import 'package:dio/dio.dart';
import 'package:parcial_2/core/constants/api_constants.dart';
import 'package:parcial_2/models/establecimiento_model.dart';

class EstablecimientosService {
  final Dio _dio;

  EstablecimientosService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.parqueaderoBaseUrl,
              ),
            );

  Future<List<EstablecimientoModel>> getAll() async {
    final response = await _dio.get('/establecimientos');
    if (response.statusCode == 200) {
      final List data = response.data is List
          ? response.data
          : (response.data['data'] ?? []) as List;
      return data
          .map((json) =>
              EstablecimientoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Error al cargar establecimientos');
    }
  }

  Future<EstablecimientoModel> getById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.parqueaderoBaseUrl}/establecimientos/$id',
      );
      dynamic raw = response.data;
      if (raw is Map && raw.containsKey('data')) {
        raw = raw['data'];
      }
      return EstablecimientoModel.fromJson(Map<String, dynamic>.from(raw));
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data ?? e.message}');
    }
  }

  Future<EstablecimientoModel> create({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    required String logoPath,
  }) async {
    final formData = FormData.fromMap({
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      'logo': await MultipartFile.fromFile(logoPath),
    });

    final response = await _dio.post('/establecimientos', data: formData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return EstablecimientoModel.fromJson(response.data);
    } else {
      throw Exception('Error al crear establecimiento');
    }
  }

  Future<EstablecimientoModel> update({
    required int id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    try {
      final Map<String, dynamic> fields = {
        'nombre': nombre,
        'nit': nit,
        'direccion': direccion,
        'telefono': telefono,
      };
      if (logoPath != null) {
        fields['logo'] =
            await MultipartFile.fromFile(logoPath, filename: 'logo.jpg');
      }
      final formData = FormData.fromMap(fields);
      final response = await _dio.post(
        '/establecimiento-update/$id',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception('Error del servidor: ${response.data}');
      }
      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return EstablecimientoModel.fromJson(Map<String, dynamic>.from(raw));
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete(
      '/establecimientos/$id',
      options: Options(validateStatus: (status) => status! < 500),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar establecimiento');
    }
  }
}
