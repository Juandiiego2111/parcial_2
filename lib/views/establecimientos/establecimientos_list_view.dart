import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parcial_2/models/establecimiento_model.dart';
import 'package:parcial_2/services/establecimientos_service.dart';
import 'package:parcial_2/widgets/skeleton_card.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  State<EstablecimientosListView> createState() =>
      _EstablecimientosListViewState();
}

class _EstablecimientosListViewState extends State<EstablecimientosListView> {
  final EstablecimientosService _service = EstablecimientosService();
  List<EstablecimientoModel> _establecimientos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEstablecimientos();
  }

  Future<void> _cargarEstablecimientos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getAll();
      setState(() {
        _establecimientos = data;
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
      appBar: AppBar(
        title: const Text('Establecimientos'),
        backgroundColor: Colors.teal,
      ),
      body: _loading
          ? ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: 5,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: SkeletonCard(height: 100),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarEstablecimientos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarEstablecimientos,
                  child: ListView.builder(
                    itemCount: _establecimientos.length,
                    itemBuilder: (context, index) {
                      final est = _establecimientos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(est.logoUrl),
                            onBackgroundImageError: (_, __) {},
                            child: est.logo.isEmpty
                                ? const Icon(Icons.business)
                                : null,
                          ),
                          title: Text(est.nombre),
                          subtitle: Text('NIT: ${est.nit}\n${est.direccion}'),
                          trailing: Text(est.telefono),
                          onTap: () =>
                              context.push('/establecimientos/${est.id}'),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/establecimientos/create'),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
