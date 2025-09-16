import 'dart:convert';
import 'package:app_capachica/app/core/config/backend_config.dart';
import 'package:app_capachica/app/data/models/emprendedor_model.dart';
import 'package:app_capachica/app/data/models/emprendedor_resumen_model.dart';
import 'package:app_capachica/app/data/models/services_capachica_model.dart';
import 'package:http/http.dart' as http;

class EmprendedoresCapachicaProvider {
  final String baseUrl;

  EmprendedoresCapachicaProvider({String? baseUrl})
      : baseUrl = baseUrl ?? BackendConfig.getBaseUrl();

  static const List<Map<String, dynamic>> _testEmprendedores = [
    {
      'id': 1,
      'nombre': 'Casa Hospedaje Samary',
      'tipo_servicio': 'Alojamiento',
      'descripcion':
      'Casa hospedaje familiar que ofrece habitaciones cómodas con vista al lago Titicaca y experiencia de turismo vivencial.',
      'ubicacion': 'Comunidad Llachón, a 200m del muelle principal',
      'telefono': '951222333',
      'email': 'samary.llachon@gmail.com',
      'imagen': 'samary1.jpg',
      'estado': true,
      'fecha_creacion': '2024-01-15T10:30:00Z',
      'total_servicios': 3,
      'precio_minimo': 50.0,
    },
    {
      'id': 2,
      'nombre': 'Restaurante El Sabor del Lago',
      'tipo_servicio': 'Restaurante',
      'descripcion':
      'Restaurante especializado en pescados frescos del lago Titicaca y platos típicos de la región.',
      'ubicacion': 'Plaza principal de Capachica',
      'telefono': '951444555',
      'email': 'saborlago@hotmail.com',
      'imagen': 'restaurante1.jpg',
      'estado': true,
      'fecha_creacion': '2024-01-10T08:15:00Z',
      'total_servicios': 5,
      'precio_minimo': 15.0,
    },
    {
      'id': 3,
      'nombre': 'Aventuras Titicaca Tours',
      'tipo_servicio': 'Turismo',
      'descripcion':
      'Agencia de turismo que ofrece tours personalizados por las islas del lago Titicaca y experiencias culturales.',
      'ubicacion': 'Oficina en el muelle principal',
      'telefono': '951666777',
      'email': 'info@aventurastiticaca.com',
      'imagen': 'tours1.jpg',
      'estado': true,
      'fecha_creacion': '2024-01-05T12:00:00Z',
      'total_servicios': 8,
      'precio_minimo': 80.0,
    },
    {
      'id': 4,
      'nombre': 'Artesanías Llachón',
      'tipo_servicio': 'Artesanía',
      'descripcion':
      'Taller de artesanías tradicionales con textiles y cerámicas típicas de la región.',
      'ubicacion': 'Comunidad Llachón, calle principal',
      'telefono': '951888999',
      'email': 'artesaniasllachon@gmail.com',
      'imagen': 'artesania1.jpg',
      'estado': true,
      'fecha_creacion': '2024-01-12T10:45:00Z',
      'total_servicios': 12,
      'precio_minimo': 20.0,
    },
    {
      'id': 5,
      'nombre': 'Transporte Lacustre Capachica',
      'tipo_servicio': 'Transporte',
      'descripcion':
      'Servicio de transporte en botes tradicionales por el lago Titicaca.',
      'ubicacion': 'Muelle principal de Capachica',
      'telefono': '951111222',
      'email': 'transporte@capachica.com',
      'imagen': 'transporte1.jpg',
      'estado': true,
      'fecha_creacion': '2024-01-08T07:30:00Z',
      'total_servicios': 2,
      'precio_minimo': 10.0,
    },
  ];

  Future<List<EmprendedorResumen>> fetchEmprendedores() async {
    try {
      print('🔄 EmprendedoresCapachicaProvider: Iniciando fetch de emprendedores...');
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Manejar la estructura de respuesta anidada
        List<dynamic> data;
        // Intenta acceder a 'data' anidado dentro de 'data'
        if (decoded['data'] != null && decoded['data']['data'] != null) {
          data = decoded['data']['data'];
        } else if (decoded['data'] is List) {
          // Si la respuesta es una lista directamente dentro de 'data'
          data = decoded['data'];
        } else if (decoded is List) {
          // Si la respuesta es una lista en la raíz
          data = decoded;
        } else {
          // Si no se encuentra una lista, asume que es un único objeto y lo pone en una lista
          data = [decoded['data'] ?? decoded];
        }

        final emprendedores = data.map((e) => EmprendedorResumen.fromJson(e)).toList();
        print('✅ EmprendedoresCapachicaProvider: ${emprendedores.length} emprendedores cargados exitosamente');
        return emprendedores;
      } else {
        print('❌ EmprendedoresCapachicaProvider: Error HTTP ${response.statusCode}');
        throw Exception('Error al cargar emprendedores: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedoresCapachicaProvider: Error en fetchEmprendedores: $e');
      print('🔄 EmprendedoresCapachicaProvider: Usando datos de ejemplo como fallback...');
      // Se mantiene el fallback a los datos de prueba
      return _testEmprendedores.map((e) => EmprendedorResumen.fromJson(e)).toList();
    }
  }

  Future<Emprendedor> fetchEmprendedorById(int id) async {
    try {
      print('🔄 EmprendedoresCapachicaProvider: Obteniendo emprendedor con ID: $id');
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/$id'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] ?? decoded;
        final emprendedor = Emprendedor.fromJson(data);
        print('✅ EmprendedoresCapachicaProvider: Emprendedor $id cargado exitosamente');
        return emprendedor;
      } else {
        throw Exception('Error al cargar el emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedoresCapachicaProvider: Error en fetchEmprendedorById: $e');
      print('🔄 EmprendedoresCapachicaProvider: Buscando en datos de ejemplo...');
      try {
        final emprendedorData = _testEmprendedores.firstWhere((e) => e['id'] == id);
        return Emprendedor.fromJson(emprendedorData);
      } catch (fallbackError) {
        print('❌ EmprendedoresCapachicaProvider: Emprendedor $id no encontrado en datos de ejemplo');
        throw Exception('Error al cargar el emprendedor: $e');
      }
    }
  }

  Future<List<EmprendedorResumen>> fetchEmprendedoresByCategoria(String categoria) async {
    try {
      print('🔄 EmprendedoresCapachicaProvider: Obteniendo emprendedores por categoría: $categoria');
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/categoria/$categoria'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded['data'] ?? decoded;
        final emprendedores = data.map((e) => EmprendedorResumen.fromJson(e)).toList();
        print('✅ EmprendedoresCapachicaProvider: ${emprendedores.length} emprendedores por categoría cargados');
        return emprendedores;
      } else {
        throw Exception('Error al cargar emprendedores por categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedoresCapachicaProvider: Error en fetchEmprendedoresByCategoria: $e');
      print('🔄 EmprendedoresCapachicaProvider: Filtrando datos de ejemplo por categoría...');
      final filteredList = _testEmprendedores
          .where((e) => e['tipo_servicio'].toString().toLowerCase() == categoria.toLowerCase())
          .toList();
      return filteredList.map((e) => EmprendedorResumen.fromJson(e)).toList();
    }
  }

  Future<List<EmprendedorResumen>> fetchEmprendedoresByAsociacion(int asociacionId) async {
    try {
      print('🔄 EmprendedoresCapachicaProvider: Obteniendo emprendedores por asociación: $asociacionId');
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/asociacion/$asociacionId'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded['data'] ?? decoded;
        final emprendedores = data.map((e) => EmprendedorResumen.fromJson(e)).toList();
        print('✅ EmprendedoresCapachicaProvider: ${emprendedores.length} emprendedores por asociación cargados');
        return emprendedores;
      } else {
        throw Exception('Error al cargar emprendedores por asociación: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedoresCapachicaProvider: Error en fetchEmprendedoresByAsociacion: $e');
      print('⚠️ Nota: Los datos de prueba no incluyen el campo de asociación. Se retornará una lista vacía.');
      return [];
    }
  }

  Future<List<EmprendedorResumen>> searchEmprendedores(String query) async {
    try {
      print('🔄 EmprendedoresCapachicaProvider: Buscando emprendedores con query: $query');
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/search?q=$query'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded['data'] ?? decoded;
        final emprendedores = data.map((e) => EmprendedorResumen.fromJson(e)).toList();
        print('✅ EmprendedoresCapachicaProvider: ${emprendedores.length} resultados de búsqueda cargados');
        return emprendedores;
      } else {
        throw Exception('Error al buscar emprendedores: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedoresCapachicaProvider: Error en searchEmprendedores: $e');
      print('🔄 EmprendedoresCapachicaProvider: Filtrando datos de ejemplo con query...');
      final filteredList = _testEmprendedores.where((e) {
        final lowerCaseQuery = query.toLowerCase();
        return e['nombre'].toString().toLowerCase().contains(lowerCaseQuery) ||
            e['tipo_servicio'].toString().toLowerCase().contains(lowerCaseQuery) ||
            e['descripcion'].toString().toLowerCase().contains(lowerCaseQuery);
      }).toList();
      return filteredList.map((e) => EmprendedorResumen.fromJson(e)).toList();
    }
  }

  Future<List<ServicioCapachica>> getServiciosByEmprendedor(int id) async {
    try {
      print('🔄 EmprendedoresCapachicaProvider: Obteniendo servicios del emprendedor con ID: $id');
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/$id/servicios'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data = decoded['data'] ?? decoded;
        final servicios = data.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ EmprendedoresCapachicaProvider: ${servicios.length} servicios cargados para el emprendedor $id');
        return servicios;
      } else {
        throw Exception('Error al cargar los servicios del emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedoresCapachicaProvider: Error en getServiciosByEmprendedor: $e');
      print('⚠️ Nota: Esta funcionalidad no está en los datos de prueba. Se retornará una lista vacía.');
      return [];
    }
  }

// TODO: Implementar getWithRelations si es necesario en el frontend
// Future<EmprendedorResumen> getWithRelations(int id) async {
//   //...
// }
}