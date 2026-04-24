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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
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
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Establecimiento'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final est = await _futureEstablecimiento;
              if (!mounted) return;
              final router = GoRouterState.of(context);
              context.push(
                '/establecimientos/${widget.id}/edit',
                extra: est,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
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
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureEstablecimiento = _service.getById(widget.id);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final est = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(est.logoUrl),
                    onBackgroundImageError: (_, __) {},
                    child: est.logo.isEmpty
                        ? const Icon(Icons.business, size: 60)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Nombre', est.nombre),
                _buildInfoRow('NIT', est.nit),
                _buildInfoRow('Dirección', est.direccion),
                _buildInfoRow('Teléfono', est.telefono),
                _buildInfoRow('Logo URL', est.logo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
