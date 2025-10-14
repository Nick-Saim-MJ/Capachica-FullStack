import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/asociacion_bloc.dart';
import '../bloc/asociacion_event.dart';
import '../bloc/asociacion_state.dart';
import '../../domain/usecases/create_asociacion.dart';
import '../../domain/usecases/update_asociacion.dart';
import '../../domain/entities/asociacion.dart';
import '../../domain/entities/municipalidad.dart';
import '../widgets/map_coordinate_selector.dart';

class AsociacionFormPage extends StatefulWidget {
  final AsociacionEntity? asociacion; // null para crear, no null para editar

  const AsociacionFormPage({super.key, this.asociacion});

  @override
  State<AsociacionFormPage> createState() => _AsociacionFormPageState();
}

class _AsociacionFormPageState extends State<AsociacionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  bool _isLoading = false;
  bool _estado = true; // Por defecto activo
  int? _selectedMunicipalidadId; // ID de municipalidad seleccionada

  @override
  void initState() {
    super.initState();
    
    // Cargar municipalidades desde la base de datos
    context.read<AsociacionBloc>().add(LoadMunicipalidades());
    
    if (widget.asociacion != null) {
      // Modo edición
      _nombreController.text = widget.asociacion!.nombre;
      _descripcionController.text = widget.asociacion!.descripcion;
      _direccionController.text = widget.asociacion!.direccion ?? '';
      _telefonoController.text = widget.asociacion!.telefono ?? '';
      _emailController.text = widget.asociacion!.email ?? '';
      _latitudController.text = widget.asociacion!.latitud?.toString() ?? '';
      _longitudController.text = widget.asociacion!.longitud?.toString() ?? '';
      _selectedMunicipalidadId = widget.asociacion!.municipalidadId;
      _estado = widget.asociacion!.estado ?? true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (widget.asociacion == null) {
        // Crear nueva asociación
        if (_selectedMunicipalidadId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.warning_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Por favor seleccione una municipalidad')),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        final params = CreateAsociacionParams(
          nombre: _nombreController.text,
          descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
          direccion: _direccionController.text.isNotEmpty ? _direccionController.text : null,
          telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          latitud: _latitudController.text.isNotEmpty ? double.tryParse(_latitudController.text) : null,
          longitud: _longitudController.text.isNotEmpty ? double.tryParse(_longitudController.text) : null,
          municipalidadId: _selectedMunicipalidadId!,
          estado: _estado,
        );
        context.read<AsociacionBloc>().add(CreateAsociacion(params));
      } else {
        // Actualizar asociación existente
        if (_selectedMunicipalidadId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.warning_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Por favor seleccione una municipalidad')),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          setState(() => _isLoading = false);
          return;
        }

        final params = UpdateAsociacionParams(
          id: widget.asociacion!.id,
          nombre: _nombreController.text,
          descripcion: _descripcionController.text.isNotEmpty ? _descripcionController.text : null,
          direccion: _direccionController.text.isNotEmpty ? _direccionController.text : null,
          telefono: _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          latitud: _latitudController.text.isNotEmpty ? double.tryParse(_latitudController.text) : null,
          longitud: _longitudController.text.isNotEmpty ? double.tryParse(_longitudController.text) : null,
          municipalidadId: _selectedMunicipalidadId!,
          estado: _estado,
        );
        context.read<AsociacionBloc>().add(UpdateAsociacion(params));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCreating = widget.asociacion == null;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isCreating ? 'Crear Asociación' : 'Editar Asociación',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
                  : [Colors.lightBlue.shade400, Colors.lightBlue.shade600],
            ),
          ),
        ),
      ),
      body: BlocListener<AsociacionBloc, AsociacionState>(
        listener: (context, state) {
          if (state is AsociacionCreated || state is AsociacionUpdated) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCreating 
                    ? 'Asociación creada exitosamente' 
                            : 'Asociación actualizada exitosamente',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AsociacionCrudError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Error: ${state.message}')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.lightBlue.shade400,
                              Colors.lightBlue.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCreating ? Icons.add_business_rounded : Icons.edit_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCreating ? 'Nueva Asociación' : 'Editar Asociación',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCreating 
                                  ? 'Complete los datos para crear una nueva asociación'
                                  : 'Modifique los datos de la asociación',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Sección: Información Básica
                _FormSection(
                  isDark: isDark,
                  title: 'Información Básica',
                  icon: Icons.info_rounded,
                  children: [
                    _buildStyledTextField(
                      controller: _nombreController,
                      label: 'Nombre de la Asociación',
                      icon: Icons.business_rounded,
                      hint: 'Ej: Asociación de Artesanos',
                      isRequired: true,
                      isDark: isDark,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                    _buildStyledTextField(
                  controller: _descripcionController,
                      label: 'Descripción',
                      icon: Icons.description_rounded,
                      hint: 'Describe brevemente la asociación...',
                  maxLines: 3,
                      isDark: isDark,
                ),
                const SizedBox(height: 16),
                    _buildMunicipalidadDropdown(isDark),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Sección: Información de Contacto
                _FormSection(
                  isDark: isDark,
                  title: 'Información de Contacto',
                  icon: Icons.contact_phone_rounded,
                  children: [
                    _buildStyledTextField(
                  controller: _direccionController,
                      label: 'Dirección',
                      icon: Icons.location_on_rounded,
                      hint: 'Ej: Av. Principal 123',
                      isRequired: true,
                      isDark: isDark,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La dirección es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                    _buildStyledTextField(
                  controller: _telefonoController,
                      label: 'Teléfono',
                      icon: Icons.phone_rounded,
                      hint: 'Ej: +51 987654321',
                  keyboardType: TextInputType.phone,
                      isDark: isDark,
                ),
                const SizedBox(height: 16),
                    _buildStyledTextField(
                  controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_rounded,
                      hint: 'Ej: contacto@asociacion.com',
                  keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email inválido';
                      }
                    }
                    return null;
                  },
                ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Sección: Estado
                _FormSection(
                  isDark: isDark,
                  title: 'Estado',
                  icon: Icons.toggle_on_rounded,
                  children: [
                    Container(
                    padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.lightBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _estado 
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _estado 
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _estado ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: _estado ? Colors.green : Colors.red,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                Text(
                                  'Estado de la Asociación',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                            Text(
                                  _estado ? 'Activa' : 'Inactiva',
                                  style: TextStyle(
                                    fontSize: 18,
                                fontWeight: FontWeight.bold,
                                    color: _estado ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                          ),
                          Switch(
                            value: _estado,
                            onChanged: (value) {
                              setState(() {
                                _estado = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Sección: Ubicación
                _FormSection(
                  isDark: isDark,
                  title: 'Ubicación',
                  icon: Icons.map_rounded,
                  children: [
                        Row(
                          children: [
                            Expanded(
                          child: _buildStyledTextField(
                                controller: _latitudController,
                            label: 'Latitud',
                            icon: Icons.my_location_rounded,
                            hint: '-15.8402',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                readOnly: true,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                            Expanded(
                          child: _buildStyledTextField(
                                controller: _longitudController,
                            label: 'Longitud',
                            icon: Icons.my_location_rounded,
                            hint: '-70.0219',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                readOnly: true,
                            isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                    const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _selectCoordinates,
                        icon: const Icon(Icons.map_rounded, size: 20),
                        label: const Text(
                          'Seleccionar en Mapa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                            style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue.shade400,
                              foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Botón de guardar
                if (_isLoading)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isCreating ? 'Creando asociación...' : 'Actualizando asociación...',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                    onPressed: _submitForm,
                      icon: Icon(
                        isCreating ? Icons.add_rounded : Icons.save_rounded,
                        size: 24,
                      ),
                      label: Text(
                        isCreating ? 'Crear Asociación' : 'Guardar Cambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.lightBlue.withOpacity(0.4),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectCoordinates() async {
    final double? currentLat = _latitudController.text.isNotEmpty 
        ? double.tryParse(_latitudController.text) 
        : null;
    final double? currentLng = _longitudController.text.isNotEmpty 
        ? double.tryParse(_longitudController.text) 
        : null;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapCoordinateSelector(
          initialLatitude: currentLat,
          initialLongitude: currentLng,
          onCoordinatesSelected: (latitude, longitude) {
            setState(() {
              _latitudController.text = latitude.toStringAsFixed(6);
              _longitudController.text = longitude.toStringAsFixed(6);
            });
          },
        ),
      ),
    );
  }
  
  Widget _buildMunicipalidadDropdown(bool isDark) {
    return BlocBuilder<AsociacionBloc, AsociacionState>(
      buildWhen: (previous, current) => 
          current is MunicipalidadesLoading ||
          current is MunicipalidadesLoaded ||
          current is MunicipalidadesError,
      builder: (context, state) {
        // Estado de carga
        if (state is MunicipalidadesLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue.shade400),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cargando municipalidades...',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Estado de error
        if (state is MunicipalidadesError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Error al cargar municipalidades',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AsociacionBloc>().add(LoadMunicipalidades());
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Estado cargado
        if (state is MunicipalidadesLoaded) {
          final municipalidades = state.municipalidades;
          
          if (municipalidades.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No hay municipalidades disponibles',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return DropdownButtonFormField<int>(
            value: _selectedMunicipalidadId,
            decoration: InputDecoration(
              labelText: 'Municipalidad *',
              hintText: 'Seleccione una municipalidad',
              prefixIcon: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue.shade400,
                      Colors.lightBlue.shade600,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 22),
              ),
              filled: true,
              fillColor: isDark 
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.lightBlue.shade400,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
            items: municipalidades.map((municipalidad) {
              return DropdownMenuItem<int>(
                value: municipalidad.id,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        size: 16,
                        color: Colors.lightBlue.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        municipalidad.nombre,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMunicipalidadId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Debe seleccionar una municipalidad';
              }
              return null;
            },
            dropdownColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: Colors.lightBlue.shade400,
              size: 28,
            ),
            isExpanded: true,
          );
        }

        // Estado por defecto (inicial)
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue.shade400),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cargando municipalidades...',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.lightBlue.shade400,
                Colors.lightBlue.shade600,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        filled: true,
        fillColor: isDark 
            ? Colors.grey.shade800.withOpacity(0.3)
            : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.lightBlue.shade400,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.grey.shade900,
      ),
    );
  }
}

// Widget para secciones del formulario
class _FormSection extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormSection({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue.shade400,
                      Colors.lightBlue.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}


