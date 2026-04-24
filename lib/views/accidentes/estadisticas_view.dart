import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:parcial_2/isolates/accidentes_isolate.dart';
import 'package:parcial_2/services/accidentes_service.dart';
import 'package:parcial_2/widgets/skeleton_card.dart';

class EstadisticasView extends StatefulWidget {
  const EstadisticasView({super.key});

  @override
  State<EstadisticasView> createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  final AccidentesService _accidentesService = AccidentesService();
  Map<String, dynamic>? _estadisticas;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final accidentes = await _accidentesService.fetchAll();
      final rawList = accidentes.map((a) => a.toRawMap()).toList();
      final stats = await Isolate.run(() => calcularEstadisticas(rawList));
      setState(() {
        _estadisticas = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Estadísticas de Accidentes'),
            backgroundColor: Colors.teal,
            pinned: true,
          ),
          if (_loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SkeletonCard(height: 250),
                ),
                childCount: 4,
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _cargarEstadisticas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                _buildChartCard(
                  context,
                  'Distribución por Clase de Accidente',
                  PieChart(
                    PieChartData(
                      sections: _buildClaseAccidenteSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                _buildChartCard(
                  context,
                  'Distribución por Gravedad',
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _maxValor(
                          (_estadisticas!['gravedadAccidente'] as Map)
                              .cast<String, int>()),
                      barGroups: _buildGravedadGroups(),
                    ),
                  ),
                ),
                _buildChartCard(
                  context,
                  'Top 5 Barrios con Más Accidentes',
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _maxValorBarrios(),
                      barGroups: _buildTopBarriosGroups(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              final top = _estadisticas!['topBarrios'] as List;
                              if (index >= 0 && index < top.length) {
                                final barrio = top[index]['barrio'] as String;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    barrio.length > 10
                                        ? '${barrio.substring(0, 10)}..'
                                        : barrio,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildChartCard(
                  context,
                  'Accidentes por Día de la Semana',
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _maxValor((_estadisticas!['diaSemana'] as Map)
                          .cast<String, int>()),
                      barGroups: _buildDiaSemanaGroups(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildClaseAccidenteSections() {
    final data = (_estadisticas!['claseAccidente'] as Map).cast<String, int>();
    final total = data.values.fold<int>(0, (sum, v) => sum + v);
    final colors = [Colors.blue, Colors.orange, Colors.red, Colors.grey];
    int i = 0;
    return data.entries.map((e) {
      final value = e.value.toDouble();
      final percentage = total > 0 ? (value / total * 100) : 0.0;
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '${e.key}\n${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildGravedadGroups() {
    final data =
        (_estadisticas!['gravedadAccidente'] as Map).cast<String, int>();
    int i = 0;
    return data.entries.map((e) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            color: Colors.red,
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _buildTopBarriosGroups() {
    final top = _estadisticas!['topBarrios'] as List;
    return top.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (e.value['accidentes'] as num).toDouble(),
            color: Colors.blue,
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _buildDiaSemanaGroups() {
    final data = (_estadisticas!['diaSemana'] as Map).cast<String, int>();
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return dias.asMap().entries.map((e) {
      final dia = e.value;
      final valor = data[dia] ?? 0;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: valor.toDouble(),
            color: Colors.green,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  double _maxValor(Map<String, int> data) {
    if (data.isEmpty) return 10;
    return (data.values.fold<int>(0, (max, v) => v > max ? v : max) * 1.2)
        .toDouble();
  }

  double _maxValorBarrios() {
    final top = _estadisticas!['topBarrios'] as List;
    if (top.isEmpty) return 10;
    final max = top.fold<int>(0, (max, e) {
      final val = e['accidentes'] as num;
      return val.toInt() > max ? val.toInt() : max;
    });
    return (max * 1.2).toDouble();
  }
}
