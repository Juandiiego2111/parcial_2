class AccidenteModel {
  final String claseDeAccidente;
  final String gravedadDelAccidente;
  final String barrioHecho;
  final String dia;
  final String hora;
  final String area;
  final String claseDeVehiculo;

  AccidenteModel({
    required this.claseDeAccidente,
    required this.gravedadDelAccidente,
    required this.barrioHecho,
    required this.dia,
    required this.hora,
    required this.area,
    required this.claseDeVehiculo,
  });

  factory AccidenteModel.fromJson(Map<String, dynamic> json) {
    return AccidenteModel(
      claseDeAccidente: json['clase_de_accidente']?.toString() ?? '',
      gravedadDelAccidente: json['gravedad_del_accidente']?.toString() ?? '',
      barrioHecho: json['barrio_hecho']?.toString() ?? '',
      dia: json['dia']?.toString() ?? '',
      hora: json['hora']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      claseDeVehiculo: json['clase_de_vehiculo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clase_de_accidente': claseDeAccidente,
      'gravedad_del_accidente': gravedadDelAccidente,
      'barrio_hecho': barrioHecho,
      'dia': dia,
      'hora': hora,
      'area': area,
      'clase_de_vehiculo': claseDeVehiculo,
    };
  }

  Map<String, dynamic> toRawMap() {
    return {
      'clase_de_accidente': claseDeAccidente,
      'gravedad_del_accidente': gravedadDelAccidente,
      'barrio_hecho': barrioHecho,
      'dia': dia,
      'hora': hora,
      'area': area,
      'clase_de_vehiculo': claseDeVehiculo,
    };
  }
}
