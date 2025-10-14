import 'package:aplicativo_capachica/features/categoria/data/datasources/categoria_remote_data_source.dart';
import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/update_category.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_bloc.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFormPage extends StatefulWidget {
  // La categoría es opcional. Si es null, estamos creando.
  final CategoryEntity? category;

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final String _pageTitle;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.category != null;
    _pageTitle = _isEditing ? 'Editar Categoría' : 'Crear Categoría';

    // Inicialización de controladores con datos existentes si es edición
    _nameController = TextEditingController(text: widget.category?.nombre ?? '');
    _descriptionController = TextEditingController(text: widget.category?.descripcion ?? '');

  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final String? existingIconoUrl = widget.category?.iconoUrl;
      final CategoryDTO categoryDto = CategoryDTO(
        nombre: _nameController.text,
        descripcion: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,

        iconoUrl: existingIconoUrl,
      );

      if (_isEditing) {
        final int categoryId = widget.category!.id;
        context.read<CategoryBloc>().add(UpdateCategoryEvent(categoryId, categoryDto));
      } else {
        context.read<CategoryBloc>().add(CreateCategoryEvent(categoryDto));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Campo Nombre (Requerido)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej: Alojamiento, Alimentación',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo Descripción (Opcional)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  hintText: 'Detalles sobre esta categoría',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),



              const SizedBox(height: 30),

              // Botón de guardado inferior
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_isEditing ? 'Guardar Cambios' : 'Crear Categoría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}