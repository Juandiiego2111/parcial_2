import 'package:parcial_2/core/constants/api_constants.dart';

class EstablecimientoModel {
  final int id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String logo;

  EstablecimientoModel({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    required this.logo,
  });

  String get logoUrl {
    if (logo.startsWith('http')) {
      return logo;
    }
    final base = ApiConstants.parqueaderoBaseUrl;
    if (base.isEmpty) return logo;
    if (logo.startsWith('/')) {
      return '$base$logo';
    }
    return '$base/$logo';
  }

  factory EstablecimientoModel.fromJson(Map<String, dynamic> json) {
    return EstablecimientoModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      nit: json['nit']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      'logo': logo,
    };
  }
}
