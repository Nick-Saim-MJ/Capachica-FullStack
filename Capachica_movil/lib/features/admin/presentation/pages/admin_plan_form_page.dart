import 'dart:io';
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/admin_plan_model.dart';
import '../bloc/admin_plans_bloc.dart';
import '../bloc/admin_plans_event.dart';

class AdminPlanFormPage extends StatefulWidget {
  final AdminPlanModel? initialPlan;

  const AdminPlanFormPage({super.key, this.initialPlan});

  @override
  State<AdminPlanFormPage> createState() => _AdminPlanFormPageState();
}

class _AdminPlanFormPageState extends State<AdminPlanFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _capacidadController;
  bool _isActive = true;

  File? _imagenPrincipalFile;

  bool get _isEditing => widget.initialPlan != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialPlan?.title);
    _descriptionController = TextEditingController(text: widget.initialPlan?.description);
    _priceController = TextEditingController(text: widget.initialPlan?.price.toString());
    _durationController = TextEditingController(text: widget.initialPlan?.duration.toString());
    _capacidadController = TextEditingController(text: widget.initialPlan?.capacidad.toString() ?? '10');
    _isActive = widget.initialPlan?.isActive ?? true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _imagenPrincipalFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final plan = AdminPlanModel(
        id: widget.initialPlan?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        duration: int.tryParse(_durationController.text) ?? 0,
        isActive: _isActive,
        capacidad: int.tryParse(_capacidadController.text) ?? 1,
      );

      if (_isEditing) {
        context.read<AdminPlansBloc>().add(UpdatePlan(plan, _imagenPrincipalFile));
      } else {
        context.read<AdminPlansBloc>().add(AddPlan(plan, _imagenPrincipalFile));
      }

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(true);
      }
    }
  }

  // >>>>>>>>>>>>> 1. MÉTODO AUXILIAR AÑADIDO <<<<<<<<<<<<<<<
  /// Construye el widget de la imagen, manejando todos los casos.
  // En _AdminPlanFormPageState

  Widget _buildImageWidget() {
    // Prioridad 1: Mostrar la nueva imagen seleccionada localmente
    if (_imagenPrincipalFile != null) {
      return Image.file(_imagenPrincipalFile!, fit: BoxFit.cover);
    }

    // Prioridad 2: Mostrar la imagen de la red si existe
    final imageUrl = widget.initialPlan?.imagenPrincipalUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      var _baseUrl=BackendConfig.baseUrlnoApi;

      // Construye la URL completa. La variable 'imageUrl' ya debería traer '/storage/...'
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '$_baseUrl$imageUrl'; // <-- CORRECCIÓN: Se elimina el '/storage' de aquí

      print('Cargando imagen desde: $fullUrl'); // Print para depurar

      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error al cargar imagen de red: $error, URL: $fullUrl');
          return const Center(
            child: Tooltip(
              message: 'No se pudo cargar la imagen. Verifica la URL y la conexión.',
              child: Icon(Icons.broken_image, color: Colors.red, size: 40),
            ),
          );
        },
      );
    }

    // Prioridad 3: Mostrar el placeholder por defecto
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('Toca para seleccionar una imagen'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Plan' : 'Crear Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ... (Tus TextFormFields para Título y Descripción se quedan igual)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título del Plan', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
                validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingresa un título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingresa una descripción' : null,
              ),
              const SizedBox(height: 16),

              Text('Imagen Principal', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // >>>>>>>>>>>> 2. SE LLAMA AL NUEVO MÉTODO AUXILIAR <<<<<<<<<<<<<<<
                    child: _buildImageWidget(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ... (El resto de tus TextFormFields y el Switch se quedan igual)
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio Total', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, ingresa un precio';
                  if (double.tryParse(value) == null) return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duración (en días)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, ingresa la duración';
                  if (int.tryParse(value) == null) return 'Ingresa un número entero válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacidadController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad (Nº de personas)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people_outline),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa la capacidad';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Ingresa un número válido (mínimo 1)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('¿Plan Activo?'),
                subtitle: const Text('Los planes inactivos no serán visibles para los usuarios.'),
                value: _isActive,
                onChanged: (bool value) => setState(() => _isActive = value),
                secondary: Icon(_isActive ? Icons.visibility : Icons.visibility_off),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Guardar Cambios' : 'Crear Plan'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}