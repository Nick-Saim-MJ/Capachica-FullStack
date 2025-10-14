import 'dart:convert';
import 'dart:io';
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmprendedorCreatePage extends StatefulWidget {
  const EmprendedorCreatePage({Key? key}) : super(key: key);

  @override
  State<EmprendedorCreatePage> createState() => _EmprendedorCreatePageState();
}

class _EmprendedorCreatePageState extends State<EmprendedorCreatePage> {
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

  @override
  void initState() {
    super.initState();
    _loadAsociaciones();
  }

  Future<void> _loadAsociaciones() async {
    try {
      final res = await dio.get('/asociaciones');
      if (res.statusCode == 200) {
        // CAMBIO AQUÍ: Accede a res.data['data']['data'] para obtener el array de asociaciones
        final rawData = res.data['data'];

        List<Map<String, dynamic>> dataList = [];

        // Verifica si rawData es un Map con estructura de paginación
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
        }
        // Si rawData es directamente una lista (sin paginación)
        else if (rawData is List) {
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
        } else {
          print('Formato inesperado de asociaciones: $rawData');
        }

        // Evitamos ids duplicados
        final ids = <int>{};
        dataList = dataList.where((a) {
          if (ids.contains(a['id'])) return false;
          ids.add(a['id']);
          return true;
        }).toList();

        setState(() {
          asociaciones = dataList;
        });

        print('Asociaciones cargadas: $asociaciones');
      } else {
        print('Error al obtener asociaciones: statusCode ${res.statusCode}');
      }
    } catch (e) {
      print('Error cargando asociaciones: $e');
    }
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => isSubmitting = true);

    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Debes iniciar sesión primero');

      final formData = FormData();
      formData.fields
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

      for (var path in imagenesPrincipales) {
        if (!path.startsWith('http')) {
          formData.files.add(MapEntry(
            'sliders_principales[]',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ));
        }
      }
      for (var path in imagenesSecundarias) {
        if (!path.startsWith('http')) {
          formData.files.add(MapEntry(
            'sliders_secundarios[]',
            await MultipartFile.fromFile(path, filename: path.split('/').last),
          ));
        }
      }

      print('metodosPago: $metodosPago');
      print('idiomasHablados: $idiomasHablados');
      print('imagenesPrincipales: $imagenesPrincipales');
      print('imagenesSecundarias: $imagenesSecundarias');

      final response = await dio.post(
        '/emprendedores',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emprendedor creado')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.statusCode}')));
      }
    } catch (e) {
      print('Error en la petición: $e');
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
              color: isSelected ? Colors.white : Colors.black, // Texto según estado
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

  Widget _buildNumberField({required String label, required TextEditingController value}) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            int current = int.tryParse(value.text) ?? 0;
            if (current > 0) {
              setState(() {
                value.text = (current - 1).toString();
              });
            }
          },
        ),
        SizedBox(
          width: 60,
          child: TextFormField(
            controller: value,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            int current = int.tryParse(value.text) ?? 0;
            setState(() {
              value.text = (current + 1).toString();
            });
          },
        ),
      ],
    );
  }


  Widget _buildImageList(List<String> images, Function(String) onDelete) {
    return Column(
      children: images
          .map((img) => ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(img), fit: BoxFit.cover)),
        ),
        title: Text(img.split('/').last),
        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => setState(() => onDelete(img))),
      ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Emprendedor'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información Básica',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: categoria,
                decoration: inputDecoration.copyWith(labelText: 'Categoría'),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => categoria = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: tipoServicio,
                decoration: inputDecoration.copyWith(labelText: 'Tipo de Servicio'),
                items: tiposServicio
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => tipoServicio = v),
                validator: (v) => v == null ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int?>(
                value: asociacionId,
                decoration: inputDecoration.copyWith(labelText: 'Asociación'),
                hint: const Text('Seleccione una asociación'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sin asociación'),
                  ),
                  ...asociaciones.map((a) {
                    final id = a['id'] is int
                        ? a['id'] as int
                        : int.tryParse(a['id'].toString()) ?? 0;
                    final nombre = a['nombre']?.toString() ?? 'Sin nombre';
                    return DropdownMenuItem<int?>(
                      value: id,
                      child: Text(
                        nombre,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  setState(() {
                    asociacionId = val;
                  });
                },
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

              _buildNumberField(
                label: 'Capacidad de Aforo',
                value: capacidadController,
              ),
              const SizedBox(height: 12),

              _buildNumberField(
                label: 'Personas que Atiende',
                value: personasAtiendeController,
              ),
              const SizedBox(height: 16),


              Text('Métodos de Pago'),
              _buildMultiSelectChip(opcionesPago, metodosPago,
                      (val) => setState(() => metodosPago = val)),
              const SizedBox(height: 16),

              Text('Idiomas Hablados'),
              _buildMultiSelectChip(idiomas, idiomasHablados,
                      (val) => setState(() => idiomasHablados = val)),
              const SizedBox(height: 16),

              TextFormField(
                controller: opcionesAccesoController,
                decoration: inputDecoration.copyWith(labelText: 'Opciones de Acceso'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(
                    child: Text('Cuenta con facilidades para personas con discapacidad'),
                  ),
                  Switch(
                    value: facilidadesDiscapacidad,
                    activeColor: Colors.white,       // Color del círculo
                    activeTrackColor: Colors.lightBlue,  // Color de la pista
                    onChanged: (v) => setState(() => facilidadesDiscapacidad = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Imágenes Principales'),
              _buildImageList(
                imagenesPrincipales,
                    (img) => imagenesPrincipales.remove(img),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Añadir Imagen Principal'),
                onPressed: () =>
                    pickImage((path) => setState(() => imagenesPrincipales.add(path))),
              ),
              const SizedBox(height: 16),

              Text('Imágenes Secundarias'),
              _buildImageList(
                imagenesSecundarias,
                    (img) => imagenesSecundarias.remove(img),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Añadir Imagen Secundaria'),
                onPressed: () =>
                    pickImage((path) => setState(() => imagenesSecundarias.add(path))),
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear Emprendedor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
