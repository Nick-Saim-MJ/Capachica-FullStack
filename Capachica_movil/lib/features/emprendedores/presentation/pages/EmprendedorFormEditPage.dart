import 'dart:convert';
import 'dart:io';
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmprendedorFormEditPage extends StatefulWidget {
  final dynamic emprendedor;

  const EmprendedorFormEditPage({Key? key, required this.emprendedor}) : super(key: key);

  @override
  State<EmprendedorFormEditPage> createState() => _EmprendedorFormEditPageState();
}

class _EmprendedorFormEditPageState extends State<EmprendedorFormEditPage> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  final Dio dio = Dio(BaseOptions(baseUrl: BackendConfig.baseUrl));

  // Controllers
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController paginaWebController = TextEditingController();
  final TextEditingController horarioController = TextEditingController();
  final TextEditingController precioRangoController = TextEditingController();
  final TextEditingController capacidadController = TextEditingController();
  final TextEditingController personasAtiendeController = TextEditingController();
  final TextEditingController opcionesAccesoController = TextEditingController();

  String? categoria;
  String? tipoServicio;
  int? asociacionId;
  bool facilidadesDiscapacidad = false;

  List<String> imagenesPrincipales = [];
  List<String> imagenesSecundarias = [];
  List<String> metodosPago = [];
  List<String> idiomasHablados = [];

  final List<String> categorias = [
    'Artesanía','Gastronomía','Alojamiento','Aventura','Cultural','Transporte','Alimentación','Actividades','Otro'
  ];

  final List<String> tiposServicio = [
    'Artesanía','Gastronomía','Alojamiento','Transporte','Guía Turístico','Alimentación','Actividades','Otro'
  ];

  final List<String> opcionesPago = [
    'Efectivo','Tarjeta de Crédito/Débito','Transferencia Bancaria','Yape','Plin'
  ];

  final List<String> idiomas = ['Español','Inglés','Quechua','Aymara'];
  List<Map<String, dynamic>> asociaciones = [];

  bool isSubmitting = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAsociaciones();
    _loadEmprendedorData();
  }

  Future<void> _loadAsociaciones() async {
    try {
      final res = await dio.get('/asociaciones');
      if (res.statusCode == 200) {
        final rawData = res.data['data'];
        List<Map<String, dynamic>> dataList = [];

        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          final asociacionesList = rawData['data'];
          if (asociacionesList is List) {
            dataList = asociacionesList.map((e) {
              if (e is Map<String, dynamic>) {
                return {
                  'id': e['id'] is int ? e['id'] : int.tryParse(e['id'].toString()) ?? 0,
                  'nombre': e['nombre']?.toString() ?? 'Sin nombre',
                };
              } else {
                return {'id': 0, 'nombre': e.toString()};
              }
            }).toList();
          }
        } else if (rawData is List) {
          dataList = rawData.map((e) {
            if (e is Map<String, dynamic>) {
              return {
                'id': e['id'] is int ? e['id'] : int.tryParse(e['id'].toString()) ?? 0,
                'nombre': e['nombre']?.toString() ?? 'Sin nombre',
              };
            } else {
              return {'id': 0, 'nombre': e.toString()};
            }
          }).toList();
        }

        final ids = <int>{};
        dataList = dataList.where((a) {
          final id = a['id'] as int;
          if (id <= 0 || ids.contains(id)) return false;
          ids.add(id);
          return true;
        }).toList();

        setState(() {
          asociaciones = dataList;
        });

        print('✅ Asociaciones cargadas: ${asociaciones.length} items');
      }
    } catch (e) {
      print('❌ Error cargando asociaciones: $e');
    }
  }

  /// Función auxiliar universal para convertir cualquier valor a List<String>
  /// Maneja: JSON strings, listas, strings separados por comas, y objetos Map con 'url'
  List<String> _safeList(dynamic value) {
    if (value == null) return [];

    // Si ya es una lista
    if (value is List) {
      return value.map((e) {
        // Si el elemento es un Map con URL (como sliders)
        if (e is Map && e.containsKey('url')) {
          return e['url'].toString();
        }
        return e.toString();
      }).where((e) => e.isNotEmpty).toList();
    }

    // Si es un String
    if (value is String) {
      value = value.trim();
      if (value.isEmpty) return [];

      // Intentar decodificar como JSON primero
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
        }
      } catch (_) {
        // No es JSON válido, continuar
      }

      // Separar por comas si es string plano
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Función auxiliar para obtener valores soportando snake_case y camelCase
  dynamic _getValue(String key) {
    final emp = widget.emprendedor;

    // Si es un Map (datos directos del backend)
    if (emp is Map<String, dynamic>) {
      switch (key) {
        case 'id':
          return emp['id'];
        case 'nombre':
          return emp['nombre'];
        case 'descripcion':
          return emp['descripcion'];
        case 'ubicacion':
          return emp['ubicacion'];
        case 'telefono':
          return emp['telefono'];
        case 'email':
          return emp['email'];
        case 'categoria':
          return emp['categoria'];
        case 'estado':
          return emp['estado'];

      // Campos con snake_case y camelCase
        case 'pagina_web':
        case 'paginaWeb':
          return emp['pagina_web'] ?? emp['paginaWeb'];

        case 'horario_atencion':
        case 'horarioAtencion':
          return emp['horario_atencion'] ?? emp['horarioAtencion'];

        case 'precio_rango':
        case 'precioRango':
          return emp['precio_rango'] ?? emp['precioRango'];

        case 'capacidad_aforo':
        case 'capacidadAforo':
          return emp['capacidad_aforo'] ?? emp['capacidadAforo'];

        case 'numero_personas_atiende':
        case 'numeroPersonasAtiende':
          return emp['numero_personas_atiende'] ?? emp['numeroPersonasAtiende'];

        case 'opciones_acceso':
        case 'opcionesAcceso':
          return emp['opciones_acceso'] ?? emp['opcionesAcceso'];

        case 'tipo_servicio':
        case 'tipoServicio':
          return emp['tipo_servicio'] ?? emp['tipoServicio'];

        case 'asociacion_id':
        case 'asociacionId':
          return emp['asociacion_id'] ?? emp['asociacionId'];

        case 'facilidades_discapacidad':
        case 'facilidadesDiscapacidad':
          return emp['facilidades_discapacidad'] ?? emp['facilidadesDiscapacidad'];

        case 'metodos_pago':
        case 'metodosPago':
          return emp['metodos_pago'] ?? emp['metodosPago'];

        case 'idiomas_hablados':
        case 'idiomasHablados':
          return emp['idiomas_hablados'] ?? emp['idiomasHablados'];

        case 'sliders_principales':
        case 'slidersPrincipales':
          return emp['sliders_principales'] ?? emp['slidersPrincipales'];

        case 'sliders_secundarios':
        case 'slidersSecundarios':
          return emp['sliders_secundarios'] ?? emp['slidersSecundarios'];

        default:
          return emp[key];
      }
    }

    // Si es EmprendedorEntity (objeto de dominio)
    try {
      switch (key) {
        case 'id': return emp.id;
        case 'nombre': return emp.nombre;
        case 'descripcion': return emp.descripcion;
        case 'ubicacion': return emp.ubicacion;
        case 'telefono': return emp.telefono;
        case 'email': return emp.email;
        case 'categoria': return emp.categoria;
        case 'estado': return emp.estado;
        case 'pagina_web':
        case 'paginaWeb':
          return emp.paginaWeb;
        case 'horario_atencion':
        case 'horarioAtencion':
          return emp.horarioAtencion;
        case 'precio_rango':
        case 'precioRango':
          return emp.precioRango;
        case 'capacidad_aforo':
        case 'capacidadAforo':
          return emp.capacidadAforo;
        case 'numero_personas_atiende':
        case 'numeroPersonasAtiende':
          return emp.numeroPersonasAtiende;
        case 'opciones_acceso':
        case 'opcionesAcceso':
          return emp.opcionesAcceso;
        case 'tipo_servicio':
        case 'tipoServicio':
          return emp.tipoServicio;
        case 'asociacion_id':
        case 'asociacionId':
          return emp.asociacionId;
        case 'facilidades_discapacidad':
        case 'facilidadesDiscapacidad':
          return emp.facilidadesDiscapacidad;
        case 'metodos_pago':
        case 'metodosPago':
          return emp.metodosPago;
        case 'idiomas_hablados':
        case 'idiomasHablados':
          return emp.idiomasHablados;
        case 'sliders_principales':
        case 'slidersPrincipales':
          return emp.slidersPrincipales;
        case 'sliders_secundarios':
        case 'slidersSecundarios':
          return emp.slidersSecundarios;
        default:
          return null;
      }
    } catch (e) {
      print('⚠️ Error obteniendo $key: $e');
      return null;
    }
  }

  void _loadEmprendedorData() {
    print('📋 Emprendedor completo: ${widget.emprendedor}');

    // Función auxiliar para String seguro
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is num || value is bool) return value.toString();
      return '';
    }

    // Función auxiliar para bool seguro
    bool safeBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is num) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    // ===== CAMPOS DE TEXTO =====
    nombreController.text = safeString(_getValue('nombre'));
    descripcionController.text = safeString(_getValue('descripcion'));
    ubicacionController.text = safeString(_getValue('ubicacion'));
    telefonoController.text = safeString(_getValue('telefono'));
    emailController.text = safeString(_getValue('email'));
    paginaWebController.text = safeString(_getValue('pagina_web'));
    horarioController.text = safeString(_getValue('horario_atencion'));
    precioRangoController.text = safeString(_getValue('precio_rango'));
    capacidadController.text = safeString(_getValue('capacidad_aforo'));
    personasAtiendeController.text = safeString(_getValue('numero_personas_atiende'));

    // Opciones de acceso (puede ser lista o string)
    final opcionesAccesoValue = _getValue('opciones_acceso');
    if (opcionesAccesoValue is List) {
      opcionesAccesoController.text = opcionesAccesoValue.join(', ');
    } else {
      opcionesAccesoController.text = safeString(opcionesAccesoValue);
    }

    // ===== DROPDOWNS =====
    final categoriaValue = safeString(_getValue('categoria'));
    categoria = categoriaValue.isNotEmpty ? categoriaValue : null;

    final tipoServicioValue = safeString(_getValue('tipo_servicio'));
    tipoServicio = tipoServicioValue.isNotEmpty ? tipoServicioValue : null;

    // ===== ASOCIACIÓN =====
    final asocId = _getValue('asociacion_id');
    asociacionId = (asocId != null && asocId.toString() != '0')
        ? int.tryParse(asocId.toString())
        : null;

    // ===== FACILIDADES DISCAPACIDAD =====
    facilidadesDiscapacidad = safeBool(_getValue('facilidades_discapacidad'));

    // ===== LISTAS (métodos de pago, idiomas) =====
    metodosPago = _safeList(_getValue('metodos_pago'));
    idiomasHablados = _safeList(_getValue('idiomas_hablados'));

    // ===== SLIDERS/IMÁGENES =====
    imagenesPrincipales = _safeList(_getValue('sliders_principales'));
    imagenesSecundarias = _safeList(_getValue('sliders_secundarios'));

    print('💳 Métodos de pago: $metodosPago');
    print('🗣️ Idiomas hablados: $idiomasHablados');
    print('🖼️ Imágenes principales: $imagenesPrincipales');
    print('🖼️ Imágenes secundarias: $imagenesSecundarias');

    // Actualizar UI
    Future.microtask(() {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> pickImage(Function(String) onPicked) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/emprendedores');
      if (!await dir.exists()) await dir.create(recursive: true);
      final savedImage = await File(pickedFile.path).copy('${dir.path}/${pickedFile.name}');
      onPicked(savedImage.path);
    }
  }

  Future<void> _submitForm() async {
    print('🔄 Botón Actualizar presionado');
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => isSubmitting = true);

    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Debes iniciar sesión primero');

      final empId = _getValue('id');
      final formData = FormData();

      formData.fields
        ..add(MapEntry('_method', 'PUT'))
        ..add(MapEntry('nombre', nombreController.text.trim()))
        ..add(MapEntry('descripcion', descripcionController.text.trim()))
        ..add(MapEntry('categoria', categoria ?? 'Otro'))
        ..add(MapEntry('tipo_servicio', tipoServicio ?? 'Otro'))
        ..add(MapEntry('asociacion_id', asociacionId?.toString() ?? ''))
        ..add(MapEntry('ubicacion', ubicacionController.text.trim()))
        ..add(MapEntry('telefono', telefonoController.text.trim()))
        ..add(MapEntry('email', emailController.text.trim()))
        ..add(MapEntry('pagina_web', paginaWebController.text.trim()))
        ..add(MapEntry('horario_atencion', horarioController.text.trim()))
        ..add(MapEntry('precio_rango', precioRangoController.text.trim()))
        ..add(MapEntry('capacidad_aforo', capacidadController.text.trim()))
        ..add(MapEntry('numero_personas_atiende', personasAtiendeController.text.trim()))
        ..add(MapEntry('opciones_acceso', opcionesAccesoController.text.trim()))
        ..add(MapEntry('facilidades_discapacidad', facilidadesDiscapacidad ? '1' : '0'))
        ..add(MapEntry('estado', '1'))
        ..add(MapEntry('metodos_pago', jsonEncode(metodosPago)))
        ..add(MapEntry('idiomas_hablados', jsonEncode(idiomasHablados)));

      // Añadir nuevas imágenes principales (solo archivos locales)
      for (var path in imagenesPrincipales) {
        if (!path.startsWith('http')) {
          formData.files.add(MapEntry(
            'sliders_principales[]',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ));
        }
      }

      // Añadir nuevas imágenes secundarias (solo archivos locales)
      for (var path in imagenesSecundarias) {
        if (!path.startsWith('http')) {
          formData.files.add(MapEntry(
            'sliders_secundarios[]',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ));
        }
      }

      final response = await dio.post(
        '/emprendedores/$empId',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('✅ Respuesta: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emprendedor actualizado correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('❌ Error en la petición: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildMultiSelectChip(List<String> options, List<String> selected, Function(List<String>) onChanged) {
    return Wrap(
      spacing: 8,
      children: options.map((e) {
        final isSelected = selected.contains(e);
        return ChoiceChip(
          label: Text(e,
            style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          ),
          selected: isSelected,
          selectedColor: Colors.lightBlue, // Fondo cuando está seleccionado
          backgroundColor: Colors.grey.shade200, // Fondo cuando NO está seleccionado
          onSelected: (val) {
            setState(() {
              if (val && !selected.contains(e)) selected.add(e);
              if (!val && selected.contains(e)) selected.remove(e);
              onChanged(selected);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController value,
    required InputDecoration decoration,
    int min = 0,
    int max = 99999,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            int current = int.tryParse(value.text) ?? 0;
            if (current > min) {
              setState(() {
                value.text = (current - 1).toString();
              });
            }
          },
        ),
        SizedBox(
          width: 80,
          child: TextFormField(
            controller: value,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              // import: FilteringTextInputFormatter.digitsOnly
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: decoration.copyWith(contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8)),
            validator: (v) {
              if ((v ?? '').isEmpty) return 'Campo obligatorio';
              final n = int.tryParse(v!);
              if (n == null) return 'Número inválido';
              if (n < min) return 'Mínimo $min';
              if (n > max) return 'Máx $max';
              return null;
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            int current = int.tryParse(value.text) ?? 0;
            if (current < max) {
              setState(() {
                value.text = (current + 1).toString();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildImageList(List<String> images, Function(String) onDelete) {
    return Column(
      children: images.map((img) {
        final isUrl = img.startsWith('http');
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: isUrl
                  ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                  : Image.file(File(img), fit: BoxFit.cover),
            ),
          ),
          title: Text(
            img.split('/').last,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() => onDelete(img)),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
    );

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Emprendedor'),
          backgroundColor: Colors.lightBlue,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Emprendedor'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Información Básica', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),

              TextFormField(
                controller: nombreController,
                decoration: inputDecoration.copyWith(labelText: 'Nombre del Emprendimiento'),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: descripcionController,
                decoration: inputDecoration.copyWith(labelText: 'Descripción'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: categoria,
                decoration: inputDecoration.copyWith(labelText: 'Categoría'),
                items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => categoria = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: tipoServicio,
                decoration: inputDecoration.copyWith(labelText: 'Tipo de Servicio'),
                items: tiposServicio.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => tipoServicio = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int?>(
                value: asociaciones.any((a) => a['id'] == asociacionId) ? asociacionId : null,
                decoration: inputDecoration.copyWith(labelText: 'Asociación'),
                hint: const Text('Seleccione una asociación'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Sin asociación')),
                  ...asociaciones.map((a) {
                    final id = a['id'] as int;
                    final nombre = a['nombre'] as String;
                    return DropdownMenuItem<int?>(value: id, child: Text(nombre));
                  }).toList(),
                ],
                onChanged: (val) => setState(() => asociacionId = val),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: ubicacionController,
                decoration: inputDecoration.copyWith(labelText: 'Ubicación'),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: telefonoController,
                decoration: inputDecoration.copyWith(labelText: 'Teléfono'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Solo permite números
                ],
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                decoration: inputDecoration.copyWith(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: paginaWebController,
                decoration: inputDecoration.copyWith(labelText: 'Página Web'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: horarioController,
                decoration: inputDecoration.copyWith(labelText: 'Horario de Atención'),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: precioRangoController,
                decoration: inputDecoration.copyWith(labelText: 'Rango de Precios'),
              ),
              const SizedBox(height: 12),

              // Número con botones
              _buildNumberField(
                label: 'Capacidad de Aforo',
                value: capacidadController,
                decoration: inputDecoration,
              ),
              const SizedBox(height: 12),

              _buildNumberField(
                label: 'Personas que Atiende',
                value: personasAtiendeController,
                decoration: inputDecoration,
              ),
              const SizedBox(height: 16),

              const Text('Métodos de Pago'),
              const SizedBox(height: 8),
              _buildMultiSelectChip(opcionesPago, metodosPago, (val) => setState(() => metodosPago = val)),
              const SizedBox(height: 16),

              const Text('Idiomas Hablados'),
              const SizedBox(height: 8),
              _buildMultiSelectChip(idiomas, idiomasHablados, (val) => setState(() => idiomasHablados = val)),
              const SizedBox(height: 16),

              TextFormField(
                controller: opcionesAccesoController,
                decoration: inputDecoration.copyWith(labelText: 'Opciones de Acceso'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(child: Text('Cuenta con facilidades para personas con discapacidad')),
                  Switch(
                    value: facilidadesDiscapacidad,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.lightBlue,
                    onChanged: (v) => setState(() => facilidadesDiscapacidad = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Imágenes Principales'),
              const SizedBox(height: 8),
              _buildImageList(imagenesPrincipales, (img) => setState(() => imagenesPrincipales.remove(img))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Añadir Imagen Principal'),
                onPressed: () => pickImage((path) => setState(() => imagenesPrincipales.add(path))),
              ),
              const SizedBox(height: 16),

              const Text('Imágenes Secundarias'),
              const SizedBox(height: 8),
              _buildImageList(imagenesSecundarias, (img) => setState(() => imagenesSecundarias.remove(img))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Añadir Imagen Secundaria'),
                onPressed: () => pickImage((path) => setState(() => imagenesSecundarias.add(path))),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSubmitting ? null : _submitForm,
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Actualizar Emprendedor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    ubicacionController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    paginaWebController.dispose();
    horarioController.dispose();
    precioRangoController.dispose();
    capacidadController.dispose();
    personasAtiendeController.dispose();
    opcionesAccesoController.dispose();
    super.dispose();
  }
}


//(0_0)