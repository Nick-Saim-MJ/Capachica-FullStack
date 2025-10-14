import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_bloc.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_event.dart';
import 'package:aplicativo_capachica/features/categoria/presentation/bloc/category_state.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_bloc.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_event.dart';
import 'package:aplicativo_capachica/features/emprendedores/presentation/bloc/emprendedor_state.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_bloc.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_event.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/widgets/horarios_field_widget.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/widgets/ubicacion_mapa_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicioForm extends StatefulWidget {
  final ServiceEntity? servicio;
  final bool isAdmin;
  final bool isEmprendedor;
  final bool isMod;

  const ServicioForm({
    super.key,
    this.servicio,
    required this.isAdmin,
    required this.isEmprendedor,
    required this.isMod,
  });

  @override
  State<ServicioForm> createState() => _ServicioFormState();
}

class _ServicioFormState extends State<ServicioForm> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ServicioHorariosFieldState> _horariosKey = GlobalKey<ServicioHorariosFieldState>();
  final isEditing = false;

  // Controladores para los campos de texto
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;
  late final TextEditingController _capacidadController;
  late final TextEditingController _ubicacionController;

  late double _latitud;
  late double _longitud;

  // Estado para el toggle 'activo'
  late bool _estadoActivo;

  // Listas para manejar las relaciones seleccionadas
  // Nota: Deberías usar Set o Map para gestionar estas relaciones de forma eficiente
  List<CategoryEntity> _selectedCategorias = [];
  List<HorarioCapachica> _currentHorarios = [];
  List<CategoryEntity> _categoriasDisponibles = [];
  List<EmprendedorEntity> _emprendedoresDisponibles = [];
  int? _selectedEmprendedorId;
  Set<int> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    final isEditing = widget.servicio != null;
    final servicio = widget.servicio;
    if (servicio != null) {
      _selectedCategoryIds = servicio.categorias
          .map((c) => c.id) // Asegura que 'c.id' sea int
          .whereType<int>()
          .toSet();
      print('Categorías iniciales cargadas: $_selectedCategoryIds');
      _currentHorarios = List.from(widget.servicio!.horarios);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(LoadCategories());
      context.read<EmprendedorBloc>().add(LoadEmprendedores());
    });

    // Inicialización de controladores
    _nombreController = TextEditingController(text: servicio?.nombre ?? '');
    _descripcionController = TextEditingController(text: servicio?.descripcion ?? '');
    _precioController = TextEditingController(text: servicio?.precioReferencial ?? '');
    _capacidadController = TextEditingController(text: servicio?.capacidad.toString() ?? '');
    _ubicacionController = TextEditingController(text: servicio?.ubicacionReferencia ?? '');

    // Inicialización de estado y relaciones
    _estadoActivo = servicio?.estado ?? true;

    _latitud = double.tryParse(widget.servicio?.latitud ?? '0.0') ?? 0.0;
    _longitud = double.tryParse(widget.servicio?.longitud ?? '0.0') ?? 0.0;

    if (isEditing) {
      // Clonar las listas si estamos editando para no mutar la entidad original
      _selectedCategorias = List.from(servicio!.categorias);
      _currentHorarios = List.from(servicio.horarios);
    }
    _selectedEmprendedorId = widget.servicio?.emprendedorId;
  }

  void _updateCoordinates(double lat, double lng) {
    setState(() {
      _latitud = lat;
      _longitud = lng;
    });
  }

  bool isSelectedCategoria(int categoryId) {
    return _selectedCategoryIds.contains(categoryId);
  }

  void toggleCategoria(int categoryId, bool isSelected) {
    print('Toggle: ID $categoryId, IsSelected: $isSelected. Set ANTES: $_selectedCategoryIds');
    setState(() {
      if (isSelected) {
        _selectedCategoryIds.add(categoryId);
      } else {
        _selectedCategoryIds.remove(categoryId);
      }
    });
    print('Toggle: Set DESPUÉS: $_selectedCategoryIds');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _capacidadController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_selectedEmprendedorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un Emprendedor para el servicio.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!ServicioHorariosField.isValid(_horariosKey)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error en Horarios: La hora de fin debe ser posterior a la hora de inicio.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final List<CategoryEntity> categoriasParaEnviar = _selectedCategoryIds
        .map((id) => CategoryEntity(id: id, nombre: '', descripcion: ''))
        .toList();

    final isEditing = widget.servicio != null;
    final baseService = widget.servicio;
    final ServiceEntity serviceToSend;

    if (isEditing && baseService != null) {
      serviceToSend = baseService.copyWith(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precioReferencial: _precioController.text,
        capacidad: int.parse(_capacidadController.text),
        ubicacionReferencia: _ubicacionController.text,
        estado: _estadoActivo,
        emprendedorId: _selectedEmprendedorId!,
        categorias: categoriasParaEnviar,
        horarios: _currentHorarios,
        latitud: _latitud.toString(),
        longitud: _longitud.toString(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    } else {
      final defaultEmprendedor = EmprendedorEntity(
        id: _selectedEmprendedorId!,
        nombre: 'Emprendedor Autenticado',
        tipoServicio: "", descripcion: '', ubicacion: '', telefono: '',
        email: '', paginaWeb: '', horarioAtencion: '',
        precioRango: '', metodosPago: const [], capacidadAforo: 0,
        numeroPersonasAtiende: 0, comentariosResenas: '',
        imagenes: const [], categoria: '', certificaciones: const [],
        idiomasHablados: const [], opcionesAcceso: const [],
        facilidadesDiscapacidad: true, estado: true,
        asociacionId: 0,
      );

      serviceToSend = ServiceEntity(
        id: 0,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        precioReferencial: _precioController.text,
        capacidad: int.parse(_capacidadController.text),
        ubicacionReferencia: _ubicacionController.text,
        estado: _estadoActivo,
        emprendedorId: _selectedEmprendedorId!,
        latitud: _latitud.toString(),
        longitud: _longitud.toString(),
        emprendedor: defaultEmprendedor,
        categorias: categoriasParaEnviar,
        horarios: _currentHorarios,
        sliders: const [],

        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
    if (!isEditing) {
      context.read<ServicioBloc>().add(CreateServicioEvent(serviceToSend));
    } else {
      context.read<ServicioBloc>().add(UpdateServicioEvent(serviceToSend));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.amber[800]!;
    final backgroundColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
    final inputColor = isDark ? const Color(0xFF374151) : Colors.white;
    final isEditingMode = widget.servicio != null;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    if (!widget.isAdmin) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            isEditingMode ? 'Editar Servicio' : 'Crear Nuevo Servicio',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            'No tienes permisos para acceder a este formulario.',
            style: TextStyle(color: secondaryTextColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          isEditingMode ? 'Editar Servicio' : 'Crear Nuevo Servicio',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [

        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // ------------------------------------------------------------------
              // SECCIÓN: INFORMACIÓN DEL SERVICIO
              // ------------------------------------------------------------------
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Servicio',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: 3.6,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildTextField(
                            context,
                            controller: _nombreController,
                            label: 'Nombre del Servicio',
                            isDark: isDark,
                            span: 2, // Ocupa las 2 columnas en el grid
                          ),

                          _buildPriceField(
                            context,
                            controller: _precioController,
                            label: 'Precio Referencial',
                            isDark: isDark,
                          ),

                          _buildTextField(
                            context,
                            controller: _capacidadController,
                            label: 'Capacidad',
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),



                        ],
                      ),

                      BlocSelector<EmprendedorBloc, EmprendedorState, List<EmprendedorEntity>>(
                        selector: (state) {
                          if (state is EmprendedorLoaded) {
                            _emprendedoresDisponibles = state.emprendedores; // Actualiza la lista local
                            return state.emprendedores;
                          }
                          return [];
                        },
                        builder: (context, emprendedores) {
                          if (emprendedores.isEmpty) {
                            return const Center(child: Text('Cargando emprendedores...'));
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDropdownEmprendedor(
                                context,
                                value: _selectedEmprendedorId,
                                items: emprendedores,
                                onChanged: (value) {
                                  setState(() => _selectedEmprendedorId = value);
                                },
                                isDark: isDark,
                                span: 2,
                              ),
                              const SizedBox(height: 16.0),
                            ],
                          );
                        },
                      ),


                      _buildSwitchTile(
                        context,
                        title: 'Servicio activo',
                        value: _estadoActivo,
                        onChanged: (value) => setState(() => _estadoActivo = value),
                        isDark: isDark,
                        span: 2,
                      ),

                      const SizedBox(height: 16),
                      _buildDescriptionField(
                        context,
                        controller: _descripcionController,
                        label: 'Descripción',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------------------
              // SECCIÓN: UBICACIÓN GEOGRÁFICA (Solo un ejemplo, se necesita un widget Mapa real)
              // ------------------------------------------------------------------
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubicación Geográfica',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                      ),
                      Text('Seleccione la ubicación donde se ofrece el servicio.', style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: 3.5,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Latitud
                          _buildTextField(
                            context,
                            controller: TextEditingController(text: widget.servicio?.latitud ?? '0.0'),
                            label: 'Latitud',
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                          // Longitud
                          _buildTextField(
                            context,
                            controller: TextEditingController(text: widget.servicio?.longitud ?? '0.0'),
                            label: 'Longitud',
                            keyboardType: TextInputType.number,
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Referencia de ubicación (Full width)
                      _buildTextField(
                        context,
                        controller: _ubicacionController,
                        label: 'Referencia de ubicación',
                        placeholder: 'Ej: A 200m del muelle principal de Llachón',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      // Aquí iría el componente de mapa
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: UbicacionMapaWidget(
                            initialLat: _latitud,
                            initialLng: _longitud,
                            // Pasar la función de callback
                            onLocationChanged: _updateCoordinates,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------------------
              // SECCIÓN: CATEGORÍAS (Usando Checkbox)
              // ------------------------------------------------------------------
              Card(
                color: cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categorías',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                      ),
                      const SizedBox(height: 16),
                    BlocSelector<CategoryBloc, CategoryState, List<CategoryEntity>>(
                                selector: (state) {
                                  _categoriasDisponibles = state.categories.cast<CategoryEntity>();
                                  return _categoriasDisponibles;
                                },
                                builder: (context, categorias) {
                                  if (categorias.isEmpty && !(context.read<CategoryBloc>().state).isLoading) {
                                    return const Center(child: Text('No hay categorías disponibles.'));
                                  }

                                  // Componente de selección de categorías (Grid)
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 5,
                                        crossAxisSpacing: 3,
                                        mainAxisSpacing: 3,
                                      ),
                                      itemCount: categorias.length,
                                      itemBuilder: (context, index) {
                                        final categoria = categorias[index];
                                        return _buildCheckboxCategory(
                                          context,
                                          categoria: categoria,
                                          isSelected: isSelectedCategoria(categoria.id),
                                          onChanged: (value) {
                                            toggleCategoria(categoria.id, value ?? false);
                                                                                    },
                                          isDark: isDark,
                                        );
                                      },
                                    ),
                                  );
                                },
                            )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ServicioHorariosField(
                key: _horariosKey,
                initialHorarios: _currentHorarios,
                isDark: isDark,
                onHorariosChanged: (newHorarios) {
                  setState(() {
                    _currentHorarios = newHorarios;
                  });
                },
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child:  ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isEditingMode ? 'Actualizar Servicio' : 'Crear Servicio',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),

                  ),
                ),
              ),

              // ------------------------------------------------------------------
              // BOTONES DE ACCIÓN (Fixed Footer)
              // ------------------------------------------------------------------
            ],
          ),
        ),
      ),
      // Footer con botones
      bottomNavigationBar: Container(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
        padding: EdgeInsets.fromLTRB(
          16.0,
          0.0,
          16.0,
          bottomSafeArea,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [],
        ),
      ),
    );
  }

  // Widget para un campo de texto estándar
  Widget _buildTextField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required bool isDark,
        TextInputType keyboardType = TextInputType.text,
        String? placeholder,
        int? span, // Ignorado en el grid de Flutter, pero se mantiene la idea
      }) {
    final borderColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
    final inputColor = isDark ? const Color(0xFF374151) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final labelColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final primaryColor = Colors.amber[800]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: labelColor.withOpacity(0.6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: inputColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          validator: (value) => value!.isEmpty ? '$label es obligatorio' : null,
        ),
      ],
    );
  }

// Widget para el campo de descripción (TextArea)
  Widget _buildDescriptionField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required bool isDark,
      }) {
    final borderColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
    final inputColor = isDark ? const Color(0xFF374151) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final labelColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final primaryColor = Colors.amber[800]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: inputColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          validator: (value) => value!.isEmpty ? '$label es obligatorio' : null,
        ),
      ],
    );
  }

// Widget para campo de precio con ícono (S/.)
  Widget _buildPriceField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required bool isDark,
      }) {
    final borderColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
    final inputColor = isDark ? const Color(0xFF374151) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final labelColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final primaryColor = Colors.amber[800]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 4.0),
              child: Text('S/.', style: TextStyle(color: labelColor, fontSize: 14)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: inputColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          validator: (value) => value!.isEmpty ? '$label es obligatorio' : null,
        ),
      ],
    );
  }

// Widget para el Switch de Estado
  Widget _buildSwitchTile(
      BuildContext context, {
        required String title,
        required bool value,
        required ValueChanged<bool> onChanged,
        required bool isDark,
        required int span,
      }) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final primaryColor = Colors.amber[800]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: textColor, fontSize: 14)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: primaryColor,
            ),
          ],
        ),
      ],
    );
  }

// Widget para el Checkbox de Categoría
  Widget _buildCheckboxCategory(
      BuildContext context, {
        required CategoryEntity categoria,
        required bool isSelected,
        required ValueChanged<bool?> onChanged,
        required bool isDark,
      }) {
    final textColor = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151);
    final primaryColor = Colors.amber[800]!;

    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                categoria.nombre,
                style: TextStyle(fontSize: 14, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget para Dropdown (Select)
  Widget _buildDropdown(
      BuildContext context, {
        required String label,
        required int? value,
        required List<EmprendedorEntity> items,
        required ValueChanged<int?> onChanged,
        required bool isDark,
        required int span,
      }) {
    final borderColor = isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB);
    final inputColor = isDark ? const Color(0xFF374151) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final labelColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: inputColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: inputColor,
              style: TextStyle(color: textColor, fontSize: 14),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('Seleccione emprendedor', style: TextStyle(color: labelColor)),
                ),
                ...items.map((emprendedor) => DropdownMenuItem(
                  value: emprendedor.id,
                  child: Text(emprendedor.nombre, style: TextStyle(color: textColor)),
                )).toList(),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildDropdownEmprendedor(
      BuildContext context, {
        required int? value,
        required List<EmprendedorEntity> items,
        required ValueChanged<int?> onChanged,
        required bool isDark,
        int span = 1,
      }) {
    // ... (código de estilo) ...

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emprendedor (*)', // Indicador visual de campo obligatorio
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // 💡 USAR DropdownButtonFormField para validación
        DropdownButtonFormField<int>(
          value: value,
          decoration: InputDecoration(
            // ... (Estilo de InputDecoration) ...
            hintText: 'Seleccione un emprendedor',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          isExpanded: true,
          // 💡 LÓGICA DE VALIDACIÓN DEL CAMPO REQUERIDO
          validator: (val) {
            if (val == null) {
              return 'Este campo es obligatorio.';
            }
            return null;
          },
          items: items.map((emprendedor) {
            return DropdownMenuItem<int>(
              value: emprendedor.id,
              child: Text(emprendedor.nombre),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
