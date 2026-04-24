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
      final data = response.data as List<dynamic>;
      return data.map((json) => EstablecimientoModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar establecimientos');
    }
  }

  Future<EstablecimientoModel> getById(int id) async {
    final response = await _dio.get('/establecimientos/$id');
    if (response.statusCode == 200) {
      return EstablecimientoModel.fromJson(response.data);
    } else {
      throw Exception('Error al cargar establecimiento');
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
    final Map<String, dynamic> fields = {
      '_method': 'PUT',
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
    };

    if (logoPath != null && logoPath.isNotEmpty) {
      fields['logo'] = await MultipartFile.fromFile(logoPath);
    }

    final formData = FormData.fromMap(fields);

    final response =
        await _dio.post('/establecimiento-update/$id', data: formData);
    if (response.statusCode == 200) {
      return EstablecimientoModel.fromJson(response.data);
    } else {
      throw Exception('Error al actualizar establecimiento');
    }
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete('/establecimientos/$id');
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar establecimiento');
    }
  }
}
