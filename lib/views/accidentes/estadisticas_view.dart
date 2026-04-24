import 'package:flutter/foundation.dart';
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
      final rawData = accidentes.map((e) => e.toJson()).toList();
      final result = await compute(calcularEstadisticas, rawData);
      setState(() {
        _estadisticas = result;
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
            expandedHeight: 160,
            backgroundColor: Colors.teal,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Estadísticas de Accidentes',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.teal.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.analytics, size: 60, color: Colors.white24),
                ),
              ),
            ),
          ),
          if (_loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SkeletonCard(height: 320),
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
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar estadísticas',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _cargarEstadisticas,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
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
                  _buildPieChart(),
                  freeHeight: true,
                ),
                _buildChartCard(
                  context,
                  'Distribución por Gravedad del Accidente',
                  _buildBarChartGravedad(),
                ),
                _buildChartCard(
                  context,
                  'Top 5 Barrios con Más Accidentes',
                  _buildHorizontalBarChartBarrios(),
                ),
                _buildChartCard(
                  context,
                  'Accidentes por Día de la Semana',
                  _buildBarChartDias(),
                ),
                const SizedBox(height: 24),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart, {double? chartHeight, bool freeHeight = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            if (freeHeight)
              chart
            else if (chartHeight != null)
              SizedBox(height: chartHeight, child: chart)
            else
              SizedBox(height: 280, child: chart),
          ],
        ),
      ),
    );
  }

  // ==================== PIE CHART ====================
  Widget _buildPieChart() {
    final data = (_estadisticas!['claseAccidente'] as Map).cast<String, int>();
    final total = data.values.fold<int>(0, (sum, v) => sum + v);
    final colorMap = {
      'Choque': const Color(0xFF00897B),
      'Atropello': const Color(0xFFFF7043),
      'Volcamiento': const Color(0xFF42A5F5),
      'Otros': const Color(0xFFBDBDBD),
    };
    final entries = data.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sections: entries.map((e) {
                final value = e.value.toDouble();
                final percentage = total > 0 ? (value / total * 100) : 0.0;
                final isBig = percentage >= 10;
                return PieChartSectionData(
                  color: colorMap[e.key] ?? Colors.grey,
                  value: value,
                  title: isBig ? '${percentage.toStringAsFixed(1)}%' : '',
                  radius: isBig ? 55 : 38,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  titlePositionPercentageOffset: 0.6,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 35,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Leyenda en grid 2x2 — nunca desborda
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 4.5,
          padding: EdgeInsets.zero,
          children: entries.map((e) {
            final pct = total > 0 ? (e.value / total * 100) : 0.0;
            return Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: colorMap[e.key],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${e.key}  ${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildDataTable(
            entries.map((e) => {'label': e.key, 'value': e.value}).toList()),
      ],
    );
  }

  // ==================== BAR CHART GRAVEDAD ====================
  Widget _buildBarChartGravedad() {
    final data =
        (_estadisticas!['gravedadAccidente'] as Map).cast<String, int>();
    final entries = data.entries.toList();
    final colors = [Colors.red, Colors.orange, Colors.green];

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _maxValor(data) * 1.15,
              barGroups: List.generate(entries.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entries[i].value.toDouble(),
                      color: colors[i % colors.length],
                      width: 36,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                          show: true, color: Colors.grey.shade200),
                    ),
                  ],
                );
              }),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _maxValor(data) / 5,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade300, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('');
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 70,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < entries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              entries[index].key,
                              style: const TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${entries[groupIndex].key}\n',
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: entries[groupIndex].value.toString(),
                          style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildDataTable(
            entries.map((e) => {'label': e.key, 'value': e.value}).toList()),
      ],
    );
  }

  // ==================== HORIZONTAL BAR CHART BARRIOS ====================
  Widget _buildHorizontalBarChartBarrios() {
    final top = _estadisticas!['topBarrios'] as List;
    if (top.isEmpty) {
      return const Center(child: Text('No hay datos de barrios'));
    }

    final maxVal = _maxValorBarrios() * 1.15;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal,
              barGroups: List.generate(top.length, (i) {
                final count = (top[i]['accidentes'] as num).toDouble();
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: count,
                      color: Colors.teal,
                      width: 24,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                          show: true, color: Colors.grey.shade200),
                    ),
                  ],
                );
              }),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxVal / 5,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade300, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 120,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < top.length) {
                        final barrio = top[index]['barrio'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            barrio.length > 6
                                ? '${barrio.substring(0, 6)}..'
                                : barrio,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 70,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < top.length) {
                        final count = (top[index]['accidentes'] as num).toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${top[groupIndex]['barrio']}\n',
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: '${top[groupIndex]['accidentes']}',
                          style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildDataTable(top
            .map((e) => {'label': e['barrio'], 'value': e['accidentes']})
            .toList()),
      ],
    );
  }

  // ==================== BAR CHART DÍAS ====================
  Widget _buildBarChartDias() {
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
    final diaAbbrevs = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final colors = [
      Colors.teal.shade400,
      Colors.teal.shade500,
      Colors.teal.shade600,
      Colors.teal.shade700,
      Colors.teal.shade800,
      Colors.green.shade600,
      Colors.green.shade700,
    ];

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _maxValor(data) * 1.15,
              barGroups: List.generate(dias.length, (i) {
                final valor = data[dias[i]] ?? 0;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: valor.toDouble(),
                      color: colors[i],
                      width: 22,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                          show: true, color: Colors.grey.shade200),
                    ),
                  ],
                );
              }),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _maxValor(data) / 5,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade300, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('');
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < diaAbbrevs.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            diaAbbrevs[index],
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${dias[groupIndex]}\n',
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: (data[dias[groupIndex]] ?? 0).toString(),
                          style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildDataTable(
            dias.map((d) => {'label': d, 'value': data[d] ?? 0}).toList()),
      ],
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> entries) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: entries.map((e) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${e['label']}: ',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '${e['value']}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  double _maxValor(Map<String, int> data) {
    if (data.isEmpty) return 10;
    return data.values.fold<int>(0, (max, v) => v > max ? v : max).toDouble();
  }

  double _maxValorBarrios() {
    final top = _estadisticas!['topBarrios'] as List;
    if (top.isEmpty) return 10;
    return top.fold<int>(0, (max, e) {
      final val = e['accidentes'] as num;
      return val.toInt() > max ? val.toInt() : max;
    }).toDouble();
  }
}