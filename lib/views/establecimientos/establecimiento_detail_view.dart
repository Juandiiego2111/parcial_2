import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parcial_2/models/establecimiento_model.dart';
import 'package:parcial_2/services/establecimientos_service.dart';
import 'package:parcial_2/widgets/skeleton_card.dart';

class EstablecimientoDetailView extends StatefulWidget {
  final int id;

  const EstablecimientoDetailView({super.key, required this.id});

  @override
  State<EstablecimientoDetailView> createState() =>
      _EstablecimientoDetailViewState();
}

class _EstablecimientoDetailViewState extends State<EstablecimientoDetailView> {
  final EstablecimientosService _service = EstablecimientosService();
  late Future<EstablecimientoModel> _futureEstablecimiento;

  @override
  void initState() {
    super.initState();
    _futureEstablecimiento = _service.getById(widget.id);
  }

  Future<void> _eliminarEstablecimiento() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este establecimiento?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.delete(widget.id);
        if (!mounted) return;
        context.pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Establecimiento',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.teal,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, size: 28),
            onPressed: () async {
              final est = await _futureEstablecimiento;
              if (!mounted) return;
              context.push(
                '/establecimientos/${widget.id}/edit',
                extra: est,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 28, color: Colors.redAccent),
            onPressed: _eliminarEstablecimiento,
          ),
        ],
      ),
      body: FutureBuilder<EstablecimientoModel>(
        future: _futureEstablecimiento,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SkeletonCard(height: 400));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 80, color: Colors.red.shade300),
                  const SizedBox(height: 20),
                  Text(
                    'Error al cargar establecimiento',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _futureEstablecimiento = _service.getById(widget.id);
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }
          final est = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo grande circular
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.teal.shade100,
                      backgroundImage: est.logoUrl.startsWith('http')
                          ? NetworkImage(est.logoUrl)
                          : null,
                      child: !est.logoUrl.startsWith('http')
                          ? Icon(Icons.business,
                              size: 80, color: Colors.teal.shade700)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Información en cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _InfoCard(
                        icon: Icons.business,
                        label: 'Nombre',
                        value: est.nombre,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.tag,
                        label: 'NIT',
                        value: est.nit,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.place,
                        label: 'Dirección',
                        value: est.direccion,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.phone,
                        label: 'Teléfono',
                        value: est.telefono,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600),
        ),
        trailing: Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }
}
