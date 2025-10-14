import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ IMPORTANTE
import '../../../../core/config/backend_config.dart';
import '../../domain/entities/municipalidad.dart';

final storage = FlutterSecureStorage(); // ✅ Instancia global

class MunicipalidadFormEditPage extends StatefulWidget {
  final MunicipalidadEntity municipalidad;

  const MunicipalidadFormEditPage({super.key, required this.municipalidad});

  @override
  State<MunicipalidadFormEditPage> createState() =>
      _MunicipalidadFormEditPageState();
}

class _MunicipalidadFormEditPageState extends State<MunicipalidadFormEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController redFacebookController;
  late TextEditingController redInstagramController;
  late TextEditingController redYoutubeController;
  late TextEditingController fraseController;
  late TextEditingController comunidadesController;
  late TextEditingController historiaFamiliasController;
  late TextEditingController historiaCapachicaController;
  late TextEditingController comiteController;
  late TextEditingController misionController;
  late TextEditingController visionController;
  late TextEditingController valoresController;
  late TextEditingController ordenanzaMunicipalController;
  late TextEditingController alianzasController;
  late TextEditingController correoController;
  late TextEditingController horarioAtencionController;
  late TextEditingController coordenadasXController;
  late TextEditingController coordenadasYController;

  final Dio dio = Dio(BaseOptions(baseUrl: BackendConfig.baseUrl));
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final m = widget.municipalidad;

    nombreController = TextEditingController(text: m.nombre);
    descripcionController = TextEditingController(text: m.descripcion);
    redFacebookController = TextEditingController(text: m.redFacebook ?? "");
    redInstagramController = TextEditingController(text: m.redInstagram ?? "");
    redYoutubeController = TextEditingController(text: m.redYoutube ?? "");
    fraseController = TextEditingController(text: m.frase ?? "");
    comunidadesController = TextEditingController(text: m.comunidades ?? "");
    historiaFamiliasController =
        TextEditingController(text: m.historiaFamilias ?? "");
    historiaCapachicaController =
        TextEditingController(text: m.historiaCapachica ?? "");
    comiteController = TextEditingController(text: m.comite ?? "");
    misionController = TextEditingController(text: m.mision ?? "");
    visionController = TextEditingController(text: m.vision ?? "");
    valoresController = TextEditingController(text: m.valores ?? "");
    ordenanzaMunicipalController =
        TextEditingController(text: m.ordenanzaMunicipal ?? "");
    alianzasController = TextEditingController(text: m.alianzas ?? "");
    correoController = TextEditingController(text: m.correo ?? "");
    horarioAtencionController =
        TextEditingController(text: m.horarioAtencion ?? "");

    // ✅ Campos coordenadas
    coordenadasXController = TextEditingController(
      text: widget.municipalidad.coordenadasX?.toString() ?? '',
    );
    coordenadasYController = TextEditingController(
      text: widget.municipalidad.coordenadasY?.toString() ?? '',
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isSubmitting = true);

    try {
      // ✅ Leer token
      final token = await storage.read(key: 'auth_token');

      // ✅ Agregar headers
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
        dio.options.headers['Accept'] = 'application/json';
      }

      final id = widget.municipalidad.id;

      final formData = FormData.fromMap({
        '_method': 'PUT', // ✅ IMPORTANTE
        'nombre': nombreController.text.trim(),
        'descripcion': descripcionController.text.trim(),
        'red_facebook': redFacebookController.text.trim(),
        'red_instagram': redInstagramController.text.trim(),
        'red_youtube': redYoutubeController.text.trim(),
        'frase': fraseController.text.trim(),
        'comunidades': comunidadesController.text.trim(),
        'historiafamilias': historiaFamiliasController.text.trim(),
        'historiacapachica': historiaCapachicaController.text.trim(),
        'comite': comiteController.text.trim(),
        'mision': misionController.text.trim(),
        'vision': visionController.text.trim(),
        'valores': valoresController.text.trim(),
        'ordenanzamunicipal': ordenanzaMunicipalController.text.trim(),
        'alianzas': alianzasController.text.trim(),
        'correo': correoController.text.trim(),
        'horariodeatencion': horarioAtencionController.text.trim(),
        'coordenadas_x': coordenadasXController.text.trim(),
        'coordenadas_y': coordenadasYController.text.trim(),
      });

      print('✅ Enviando datos: ${formData.fields}');

      // ✅ Cambiar PUT por POST
      final response = await dio.post(
        '/municipalidad/$id',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Municipalidad actualizada')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

// Función para campos con estilo moderno
  Widget _styledField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.lightBlue),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.lightBlue.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.lightBlue.shade400, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Municipalidad'),
        backgroundColor: Colors.lightBlue, // Color consistente
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _styledField('Nombre', nombreController),
              _styledField('Descripción', descripcionController, maxLines: 3),
              _styledField('Facebook', redFacebookController),
              _styledField('Instagram', redInstagramController),
              _styledField('YouTube', redYoutubeController),
              _styledField('Frase', fraseController),
              _styledField('Comunidades', comunidadesController, maxLines: 3),
              _styledField('Historia Familias', historiaFamiliasController, maxLines: 3),
              _styledField('Historia Capachica', historiaCapachicaController, maxLines: 3),
              _styledField('Comité', comiteController),
              _styledField('Misión', misionController),
              _styledField('Visión', visionController),
              _styledField('Valores', valoresController),
              _styledField('Ordenanza Municipal', ordenanzaMunicipalController),
              _styledField('Alianzas', alianzasController),
              _styledField('Correo', correoController),
              _styledField('Horario de Atención', horarioAtencionController),
              _styledField('Coordenadas X', coordenadasXController),
              _styledField('Coordenadas Y', coordenadasYController),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Guardar Cambios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
