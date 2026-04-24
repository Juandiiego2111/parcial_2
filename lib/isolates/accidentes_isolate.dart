import 'package:parcial_2/models/accidente_model.dart';

Map<String, dynamic> calcularEstadisticas(List<Map<String, dynamic>> rawList) {
  final stopwatch = Stopwatch()..start();

  print('[Isolate] Iniciado — ${rawList.length} registros recibidos');

  final List<AccidenteModel> accidentes =
      rawList.map((json) => AccidenteModel.fromJson(json)).toList();

  final Map<String, int> claseAccidente = {
    'Choque': 0,
    'Atropello': 0,
    'Volcamiento': 0,
    'Otros': 0,
  };

  final Map<String, int> gravedadAccidente = {
    'Con muertos': 0,
    'Con heridos': 0,
    'Solo daños': 0,
  };

  final Map<String, int> barriosContador = {};

  final Map<String, int> diaSemana = {
    'Lunes': 0,
    'Martes': 0,
    'Miércoles': 0,
    'Jueves': 0,
    'Viernes': 0,
    'Sábado': 0,
    'Domingo': 0,
  };

  for (final acc in accidentes) {
    final clase = acc.claseDeAccidente.toLowerCase();
    if (clase.contains('choque')) {
      claseAccidente['Choque'] = (claseAccidente['Choque'] ?? 0) + 1;
    } else if (clase.contains('atropello')) {
      claseAccidente['Atropello'] = (claseAccidente['Atropello'] ?? 0) + 1;
    } else if (clase.contains('volcamiento')) {
      claseAccidente['Volcamiento'] = (claseAccidente['Volcamiento'] ?? 0) + 1;
    } else {
      claseAccidente['Otros'] = (claseAccidente['Otros'] ?? 0) + 1;
    }

    final gravedad = acc.gravedadDelAccidente.toLowerCase();
    String normalized;
    if (gravedad.contains('muerto') || gravedad.contains('muertos')) {
      normalized = 'Con muertos';
    } else if (gravedad.contains('herido') || gravedad.contains('heridos')) {
      normalized = 'Con heridos';
    } else if (gravedad.contains('da')) {
      normalized = 'Solo daños';
    } else {
      normalized = 'Solo daños';
    }
    gravedadAccidente[normalized] = (gravedadAccidente[normalized] ?? 0) + 1;

    final barrio = acc.barrioHecho.trim();
    final barrioNorm = barrio.toUpperCase();
    if (barrioNorm.isNotEmpty && barrioNorm != 'NO INFORMA') {
      barriosContador[barrioNorm] = (barriosContador[barrioNorm] ?? 0) + 1;
    }

    final diaRaw = acc.dia.toLowerCase().trim();
    String diaNorm = _normalizarDia(diaRaw);
    if (diaNorm.isNotEmpty) {
      diaSemana[diaNorm] = (diaSemana[diaNorm] ?? 0) + 1;
    }
  }

  final topBarrios = barriosContador.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top5Barrios = topBarrios.take(5).toList();

  stopwatch.stop();
  print('[Isolate] Completado en ${stopwatch.elapsedMilliseconds} ms');

  return {
    'claseAccidente': claseAccidente,
    'gravedadAccidente': gravedadAccidente,
    'topBarrios': top5Barrios
        .map((e) => {'barrio': e.key, 'accidentes': e.value})
        .toList(),
    'diaSemana': diaSemana,
  };
}

String _normalizarDia(String dia) {
  switch (dia) {
    case 'lunes':
      return 'Lunes';
    case 'martes':
      return 'Martes';
    case 'miercoles':
    case 'miércoles':
      return 'Miércoles';
    case 'jueves':
      return 'Jueves';
    case 'viernes':
      return 'Viernes';
    case 'sabado':
    case 'sábado':
      return 'Sábado';
    case 'domingo':
      return 'Domingo';
    default:
      return '';
  }
}
