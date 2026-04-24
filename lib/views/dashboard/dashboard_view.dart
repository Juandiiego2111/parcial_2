import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parcial_2/services/accidentes_service.dart';
import 'package:parcial_2/services/establecimientos_service.dart';
import 'package:parcial_2/widgets/skeleton_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final AccidentesService _accidentesService = AccidentesService();
  final EstablecimientosService _establecimientosService =
      EstablecimientosService();

  int? _totalAccidentes;
  int? _totalEstablecimientos;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarTotales();
  }

  Future<void> _cargarTotales() async {
    setState(() => _loading = true);
    try {
      // Cargar AMBOS en paralelo
      final results = await Future.wait([
        _accidentesService.fetchAll(),
        _establecimientosService.getAll(),
      ]);
      setState(() {
        _totalAccidentes = (results[0] as List).length;
        _totalEstablecimientos = (results[1] as List).length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Parcial Flutter'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Accidentes',
                          icon: Icons.warning_rounded,
                          value: _loading ? null : _totalAccidentes,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Establecimientos',
                          icon: Icons.business,
                          value: _loading ? null : _totalEstablecimientos,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Módulos',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ModuleCard(
                          title: 'Estadísticas de Accidentes',
                          icon: Icons.bar_chart,
                          onTap: () => context.push('/estadisticas'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ModuleCard(
                          title: 'Gestionar Establecimientos',
                          icon: Icons.location_city,
                          onTap: () => context.push('/establecimientos'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? value;

  const _StatCard({
    required this.title,
    required this.icon,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (value != null)
              Text(
                value.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            else
              const SkeletonCard(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
