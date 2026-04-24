import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parcial_2/models/establecimiento_model.dart';
import 'package:parcial_2/services/establecimientos_service.dart';

class EstablecimientoFormView extends StatefulWidget {
  final int? id;
  final EstablecimientoModel? establecimiento;

  const EstablecimientoFormView({
    super.key,
    this.id,
    this.establecimiento,
  });

  @override
  State<EstablecimientoFormView> createState() =>
      _EstablecimientoFormViewState();
}

class _EstablecimientoFormViewState extends State<EstablecimientoFormView> {
  final _formKey = GlobalKey<FormState>();
  final EstablecimientosService _service = EstablecimientosService();

  final _nombreController = TextEditingController();
  final _nitController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();

  String? _logoPath;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.establecimiento != null) {
      _nombreController.text = widget.establecimiento!.nombre;
      _nitController.text = widget.establecimiento!.nit;
      _direccionController.text = widget.establecimiento!.direccion;
      _telefonoController.text = widget.establecimiento!.telefono;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nitController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (picked != null) {
      setState(() {
        _logoPath = picked.path;
      });
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (picked != null) {
      setState(() {
        _logoPath = picked.path;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.id == null && _logoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una imagen de logo')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      if (widget.id == null) {
        await _service.create(
          nombre: _nombreController.text,
          nit: _nitController.text,
          direccion: _direccionController.text,
          telefono: _telefonoController.text,
          logoPath: _logoPath!,
        );
      } else {
        await _service.update(
          id: widget.id!,
          nombre: _nombreController.text,
          nit: _nitController.text,
          direccion: _direccionController.text,
          telefono: _telefonoController.text,
          logoPath: _logoPath,
        );
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            esEdicion ? 'Editar Establecimiento' : 'Nuevo Establecimiento'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nitController,
                    decoration: const InputDecoration(
                      labelText: 'NIT',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Logo:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _seleccionarImagen,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _tomarFoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cámara'),
                        ),
                      ),
                    ],
                  ),
                  if (_logoPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Imagen seleccionada: $_logoPath'),
                    ),
                  if (esEdicion && _logoPath == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('Deje vacío para mantener la imagen actual'),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _submitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(esEdicion ? 'Actualizar' : 'Crear'),
                  ),
                ],
              ),
            ),
          ),
          if (_submitting) ...[
            const ModalBarrier(
              dismissible: false,
              color: Colors.black45,
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
