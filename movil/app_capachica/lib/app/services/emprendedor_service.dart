import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/emprendedor_model.dart';
import '../core/config/backend_config.dart';
import '../core/exceptions/api_exception.dart';

class EmprendedorService {
  final String baseUrl = BackendConfig.getBaseUrl();

  // Datos de prueba para modo test
  static const List<Map<String, dynamic>> _testEmprendedores = [
    {
      'id': 1,
      'nombre': 'Casa Hospedaje Samary',
      'tipo_servicio': 'Alojamiento',
      'descripcion': 'Casa hospedaje familiar que ofrece habitaciones cómodas con vista al lago Titicaca y experiencia de turismo vivencial.',
      'ubicacion': 'Comunidad Llachón, a 200m del muelle principal',
      'telefono': '951222333',
      'email': 'samary.llachon@gmail.com',
      'pagina_web': 'https://samaryllachon.com',
      'horario_atencion': 'Todos los días: 7:00 am - 10:00 pm',
      'precio_rango': 'S/. 50 - S/. 100',
      'metodos_pago': '["Efectivo","Transferencia","Yape"]',
      'capacidad_aforo': 12,
      'numero_personas_atiende': 3,
      'comentarios_resenas': 'Excelente servicio, habitaciones limpias y comida deliciosa. Muy recomendado.',
      'imagenes': '["samary1.jpg","samary2.jpg","samary3.jpg"]',
      'categoria': 'Alojamiento',
      'certificaciones': 'TRC MINCETUR',
      'idiomas_hablados': 'Español, Inglés básico, Quechua',
      'opciones_acceso': 'A pie, en bote',
      'estado': true,
      'fecha_creacion': '2024-01-15T10:30:00Z',
      'fecha_actualizacion': '2024-01-20T14:45:00Z',
    },
    {
      'id': 2,
      'nombre': 'Restaurante El Sabor del Lago',
      'tipo_servicio': 'Restaurante',
      'descripcion': 'Restaurante especializado en pescados frescos del lago Titicaca y platos típicos de la región.',
      'ubicacion': 'Plaza principal de Capachica',
      'telefono': '951444555',
      'email': 'saborlago@hotmail.com',
      'pagina_web': 'https://elsabordellago.com',
      'horario_atencion': 'Lunes a Domingo: 11:00 am - 9:00 pm',
      'precio_rango': 'S/. 15 - S/. 45',
      'metodos_pago': '["Efectivo","Tarjeta","Yape"]',
      'capacidad_aforo': 50,
      'numero_personas_atiende': 8,
      'comentarios_resenas': 'La mejor trucha del lago, ambiente familiar y precios justos.',
      'imagenes': '["restaurante1.jpg","restaurante2.jpg"]',
      'categoria': 'Restaurante',
      'certificaciones': 'Salud DIGESA',
      'idiomas_hablados': 'Español, Quechua',
      'opciones_acceso': 'A pie, en taxi',
      'estado': true,
      'fecha_creacion': '2024-01-10T08:15:00Z',
      'fecha_actualizacion': '2024-01-18T16:20:00Z',
    },
    {
      'id': 3,
      'nombre': 'Aventuras Titicaca Tours',
      'tipo_servicio': 'Turismo',
      'descripcion': 'Agencia de turismo que ofrece tours personalizados por las islas del lago Titicaca y experiencias culturales.',
      'ubicacion': 'Oficina en el muelle principal',
      'telefono': '951666777',
      'email': 'info@aventurastiticaca.com',
      'pagina_web': 'https://aventurastiticaca.com',
      'horario_atencion': 'Lunes a Domingo: 6:00 am - 8:00 pm',
      'precio_rango': 'S/. 80 - S/. 200',
      'metodos_pago': '["Efectivo","Transferencia","Tarjeta"]',
      'capacidad_aforo': 20,
      'numero_personas_atiende': 5,
      'comentarios_resenas': 'Guías expertos, experiencias únicas y muy organizados.',
      'imagenes': '["tours1.jpg","tours2.jpg","tours3.jpg"]',
      'categoria': 'Turismo',
      'certificaciones': 'MINCETUR',
      'idiomas_hablados': 'Español, Inglés, Francés',
      'opciones_acceso': 'A pie, en bote',
      'estado': true,
      'fecha_creacion': '2024-01-05T12:00:00Z',
      'fecha_actualizacion': '2024-01-22T09:30:00Z',
    },
    {
      'id': 4,
      'nombre': 'Artesanías Llachón',
      'tipo_servicio': 'Artesanía',
      'descripcion': 'Taller de artesanías tradicionales con textiles y cerámicas típicas de la región.',
      'ubicacion': 'Comunidad Llachón, calle principal',
      'telefono': '951888999',
      'email': 'artesaniasllachon@gmail.com',
      'pagina_web': null,
      'horario_atencion': 'Lunes a Sábado: 8:00 am - 6:00 pm',
      'precio_rango': 'S/. 20 - S/. 150',
      'metodos_pago': '["Efectivo","Yape"]',
      'capacidad_aforo': 15,
      'numero_personas_atiende': 4,
      'comentarios_resenas': 'Productos auténticos y de alta calidad, muy buena atención.',
      'imagenes': '["artesania1.jpg","artesania2.jpg"]',
      'categoria': 'Artesanía',
      'certificaciones': 'MINCETUR',
      'idiomas_hablados': 'Español, Quechua',
      'opciones_acceso': 'A pie',
      'estado': true,
      'fecha_creacion': '2024-01-12T10:45:00Z',
      'fecha_actualizacion': '2024-01-19T15:15:00Z',
    },
    {
      'id': 5,
      'nombre': 'Transporte Lacustre Capachica',
      'tipo_servicio': 'Transporte',
      'descripcion': 'Servicio de transporte en botes tradicionales por el lago Titicaca.',
      'ubicacion': 'Muelle principal de Capachica',
      'telefono': '951111222',
      'email': 'transporte@capachica.com',
      'pagina_web': null,
      'horario_atencion': 'Todos los días: 5:00 am - 7:00 pm',
      'precio_rango': 'S/. 10 - S/. 30',
      'metodos_pago': '["Efectivo"]',
      'capacidad_aforo': 25,
      'numero_personas_atiende': 6,
      'comentarios_resenas': 'Servicio puntual y seguro, botes bien mantenidos.',
      'imagenes': '["transporte1.jpg"]',
      'categoria': 'Transporte',
      'certificaciones': 'DICAPI',
      'idiomas_hablados': 'Español, Quechua',
      'opciones_acceso': 'A pie',
      'estado': true,
      'fecha_creacion': '2024-01-08T07:30:00Z',
      'fecha_actualizacion': '2024-01-21T11:00:00Z',
    },
  ];

  static const List<String> _testCategorias = [
    'Alojamiento',
    'Restaurante',
    'Turismo',
    'Artesanía',
    'Transporte',
    'Otros'
  ];

  // Método auxiliar para extraer datos de la respuesta paginada
  List<dynamic> _extractDataFromResponse(String responseBody) {
    final dynamic response = json.decode(responseBody);
    
    // Si la respuesta es directamente una lista
    if (response is List) {
      return response;
    }
    
    // Si la respuesta es un Map
    if (response is Map<String, dynamic>) {
      // Verificar si la respuesta tiene estructura paginada
      if (response.containsKey('data') && response['data'] is Map) {
        final dataMap = response['data'] as Map<String, dynamic>;
        if (dataMap.containsKey('data') && dataMap['data'] is List) {
          return dataMap['data'] as List<dynamic>;
        }
      }
      
      // Si no tiene estructura paginada, intentar usar directamente
      if (response.containsKey('data') && response['data'] is List) {
        return response['data'] as List<dynamic>;
      }
    }
    
    throw ApiException(message: 'Formato de respuesta no válido');
  }

  // Obtener lista completa de emprendedores
  Future<List<Emprendedor>> getEmprendedores() async {
    try {
      print('🔄 EmprendedorService: Obteniendo lista de emprendedores...');
      
      // Modo de prueba
      if (BackendConfig.testMode) {
        print('🧪 EmprendedorService: Usando datos de prueba');
        await Future.delayed(const Duration(milliseconds: 500)); // Simular delay de red
        
        final emprendedores = _testEmprendedores
            .map((json) => Emprendedor.fromJson(json))
            .toList();
        
        print('✅ EmprendedorService: ${emprendedores.length} emprendedores obtenidos (modo prueba)');
        return emprendedores;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 EmprendedorService: Response status: ${response.statusCode}');
      print('📡 EmprendedorService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataFromResponse(response.body);
        final emprendedores = data.map((json) => Emprendedor.fromJson(json)).toList();
        
        print('✅ EmprendedorService: ${emprendedores.length} emprendedores obtenidos');
        return emprendedores;
      } else {
        throw ApiException(message: 'Error al obtener emprendedores: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedorService: Error obteniendo emprendedores: $e');
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  // Buscar emprendedores por texto
  Future<List<Emprendedor>> searchEmprendedores(String query) async {
    try {
      print('🔍 EmprendedorService: Buscando emprendedores con query: "$query"');
      
      // Modo de prueba
      if (BackendConfig.testMode) {
        print('🧪 EmprendedorService: Búsqueda en modo prueba');
        await Future.delayed(const Duration(milliseconds: 300));
        
        final lowercaseQuery = query.toLowerCase();
        final results = _testEmprendedores.where((emprendedor) {
          return emprendedor['nombre'].toLowerCase().contains(lowercaseQuery) ||
                 emprendedor['tipo_servicio'].toLowerCase().contains(lowercaseQuery) ||
                 emprendedor['ubicacion'].toLowerCase().contains(lowercaseQuery) ||
                 (emprendedor['descripcion']?.toLowerCase().contains(lowercaseQuery) ?? false);
        }).map((json) => Emprendedor.fromJson(json)).toList();
        
        print('✅ EmprendedorService: ${results.length} resultados encontrados (modo prueba)');
        return results;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/search?query=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 EmprendedorService: Search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataFromResponse(response.body);
        final emprendedores = data.map((json) => Emprendedor.fromJson(json)).toList();
        
        print('✅ EmprendedorService: ${emprendedores.length} resultados encontrados');
        return emprendedores;
      } else {
        throw ApiException(message: 'Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedorService: Error en búsqueda: $e');
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  // Filtrar emprendedores por categoría
  Future<List<Emprendedor>> getEmprendedoresByCategoria(String categoria) async {
    try {
      print('🏷️ EmprendedorService: Filtrando emprendedores por categoría: "$categoria"');
      
      // Modo de prueba
      if (BackendConfig.testMode) {
        print('🧪 EmprendedorService: Filtro por categoría en modo prueba');
        await Future.delayed(const Duration(milliseconds: 300));
        
        final results = _testEmprendedores.where((emprendedor) {
          return emprendedor['categoria'].toLowerCase() == categoria.toLowerCase();
        }).map((json) => Emprendedor.fromJson(json)).toList();
        
        print('✅ EmprendedorService: ${results.length} emprendedores en categoría "$categoria" (modo prueba)');
        return results;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/categoria/${Uri.encodeComponent(categoria)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 EmprendedorService: Categoria filter response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataFromResponse(response.body);
        final emprendedores = data.map((json) => Emprendedor.fromJson(json)).toList();
        
        print('✅ EmprendedorService: ${emprendedores.length} emprendedores en categoría "$categoria"');
        return emprendedores;
      } else {
        throw ApiException(message: 'Error al filtrar por categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedorService: Error filtrando por categoría: $e');
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  // Obtener detalle de un emprendedor específico
  Future<Emprendedor> getEmprendedorById(int id) async {
    try {
      print('👤 EmprendedorService: Obteniendo detalle del emprendedor ID: $id');
      
      // Modo de prueba
      if (BackendConfig.testMode) {
        print('🧪 EmprendedorService: Obteniendo detalle en modo prueba');
        await Future.delayed(const Duration(milliseconds: 400));
        
        final emprendedorData = _testEmprendedores.firstWhere(
          (emprendedor) => emprendedor['id'] == id,
          orElse: () => throw ApiException(message: 'Emprendedor no encontrado'),
        );
        
        final emprendedor = Emprendedor.fromJson(emprendedorData);
        print('✅ EmprendedorService: Detalle del emprendedor obtenido: ${emprendedor.nombre} (modo prueba)');
        return emprendedor;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 EmprendedorService: Detail response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Verificar si la respuesta tiene estructura con 'data'
        final data = responseData.containsKey('data') ? responseData['data'] : responseData;
        final emprendedor = Emprendedor.fromJson(data);
        
        print('✅ EmprendedorService: Detalle del emprendedor obtenido: ${emprendedor.nombre}');
        return emprendedor;
      } else {
        throw ApiException(message: 'Error al obtener detalle: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedorService: Error obteniendo detalle: $e');
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  // Obtener relaciones de un emprendedor
  Future<List<RelacionEmprendedor>> getEmprendedorRelaciones(int id) async {
    try {
      print('🔗 EmprendedorService: Obteniendo relaciones del emprendedor ID: $id');
      
      // Modo de prueba
      if (BackendConfig.testMode) {
        print('🧪 EmprendedorService: Obteniendo relaciones en modo prueba');
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Datos de prueba para relaciones
        final testRelaciones = [
          {
            'id': 1,
            'tipo': 'red_social',
            'valor': 'facebook.com/emprendedor$id',
            'fecha_creacion': '2024-01-15T10:30:00Z',
          },
          {
            'id': 2,
            'tipo': 'whatsapp',
            'valor': '+51 951222333',
            'fecha_creacion': '2024-01-15T10:30:00Z',
          },
        ];
        
        final relaciones = testRelaciones.map((json) => RelacionEmprendedor.fromJson(json)).toList();
        print('✅ EmprendedorService: ${relaciones.length} relaciones obtenidas (modo prueba)');
        return relaciones;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/$id/relaciones'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 EmprendedorService: Relaciones response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataFromResponse(response.body);
        final relaciones = data.map((json) => RelacionEmprendedor.fromJson(json)).toList();
        
        print('✅ EmprendedorService: ${relaciones.length} relaciones obtenidas');
        return relaciones;
      } else {
        throw ApiException(message: 'Error al obtener relaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedorService: Error obteniendo relaciones: $e');
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  // Obtener servicios de un emprendedor
  Future<List<ServicioEmprendedor>> getEmprendedorServicios(int id) async {
    try {
      print('🛠️ EmprendedorService: Obteniendo servicios del emprendedor ID: $id');
      
      // Modo de prueba
      if (BackendConfig.testMode) {
        print('🧪 EmprendedorService: Obteniendo servicios en modo prueba');
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Datos de prueba para servicios
        final testServicios = [
          {
            'id': 1,
            'nombre': 'Habitación Doble',
            'descripcion': 'Habitación con vista al lago, baño privado y desayuno incluido',
            'precio_referencial': 80.0,
            'ubicacion_referencia': 'Segundo piso',
            'capacidad': 2,
            'estado': true,
            'categorias': [
              {
                'id': 1,
                'nombre': 'Alojamiento',
                'descripcion': 'Servicios de hospedaje'
              }
            ],
            'horarios': [
              {
                'id': 1,
                'dia_semana': 'Lunes',
                'hora_inicio': '14:00',
                'hora_fin': '12:00'
              },
              {
                'id': 2,
                'dia_semana': 'Martes',
                'hora_inicio': '14:00',
                'hora_fin': '12:00'
              }
            ]
          },
          {
            'id': 2,
            'nombre': 'Tour Guiado',
            'descripcion': 'Recorrido por las islas del lago con guía local',
            'precio_referencial': 120.0,
            'ubicacion_referencia': 'Muelle principal',
            'capacidad': 10,
            'estado': true,
            'categorias': [
              {
                'id': 2,
                'nombre': 'Turismo',
                'descripcion': 'Servicios turísticos'
              }
            ],
            'horarios': [
              {
                'id': 3,
                'dia_semana': 'Lunes',
                'hora_inicio': '08:00',
                'hora_fin': '17:00'
              }
            ]
          }
        ];
        
        final servicios = testServicios.map((json) => ServicioEmprendedor.fromJson(json)).toList();
        print('✅ EmprendedorService: ${servicios.length} servicios obtenidos (modo prueba)');
        return servicios;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/$id/servicios'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 EmprendedorService: Servicios response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataFromResponse(response.body);
        final servicios = data.map((json) => ServicioEmprendedor.fromJson(json)).toList();
        
        print('✅ EmprendedorService: ${servicios.length} servicios obtenidos');
        return servicios;
      } else {
        throw ApiException(message: 'Error al obtener servicios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EmprendedorService: Error obteniendo servicios: $e');
      throw ApiException(message: 'Error de conexión: $e');
    }
  }

  // Obtener categorías disponibles
  Future<List<String>> getCategorias() async {
    try {
      print('🏷️ EmprendedorService: Obteniendo categorías disponibles...');
      
      // Modo de prueba
      if (BackendConfig.testMode) {
        print('🧪 EmprendedorService: Obteniendo categorías en modo prueba');
        await Future.delayed(const Duration(milliseconds: 200));
        
        print('✅ EmprendedorService: ${_testCategorias.length} categorías obtenidas (modo prueba)');
        return _testCategorias;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/emprendedores/categorias'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = _extractDataFromResponse(response.body);
        final categorias = data.map((item) => item['nombre'] as String).toList();
        
        print('✅ EmprendedorService: ${categorias.length} categorías obtenidas');
        return categorias;
      } else {
        // Si no existe el endpoint de categorías, retornar categorías por defecto
        print('⚠️ EmprendedorService: Endpoint de categorías no disponible, usando categorías por defecto');
        return _testCategorias;
      }
    } catch (e) {
      print('❌ EmprendedorService: Error obteniendo categorías: $e');
      // Retornar categorías por defecto en caso de error
      return _testCategorias;
    }
  }

  void dispose() {
    // Cleanup si es necesario
  }
} 