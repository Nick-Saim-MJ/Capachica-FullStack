import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/services_capachica_model.dart';
import '../../core/config/backend_config.dart';

class ServicesCapachicaProvider {
  final String baseUrl;

  ServicesCapachicaProvider({String? baseUrl}) 
    : baseUrl = baseUrl ?? BackendConfig.getBaseUrl();

  // Datos de prueba como fallback
  List<Map<String, dynamic>> get _datosEjemplo => [
    {
      "id": 1,
      "nombre": "Tour en Kayak por el Lago Titicaca",
      "descripcion": "Disfruta de un emocionante tour en kayak por las aguas cristalinas del Lago Titicaca, explorando la belleza natural de Capachica.",
      "precioReferencial": "80.00",
      "capacidad": 8,
      "ubicacionReferencia": "Muelle de Capachica",
      "estado": true,
      "emprendedorId": 1,
      "emprendedor": {
        "id": 1,
        "nombre": "María Quispe",
        "tipoServicio": "Turismo Acuático",
        "ubicacion": "Capachica, Puno",
        "telefono": "+51987654321",
        "imagenes": "assets/lugar-turistico1.jpg"
      },
      "categorias": [
        {
          "id": 1,
          "nombre": "Deportes Acuáticos"
        }
      ],
      "horarios": [
        {
          "diaSemana": "lunes",
          "horaInicio": "08:00",
          "horaFin": "17:00"
        },
        {
          "diaSemana": "martes",
          "horaInicio": "08:00",
          "horaFin": "17:00"
        },
        {
          "diaSemana": "miércoles",
          "horaInicio": "08:00",
          "horaFin": "17:00"
        }
      ]
    },
    {
      "id": 2,
      "nombre": "Caminata a los Miradores de Capachica",
      "descripcion": "Explora los impresionantes miradores naturales de la península de Capachica con vistas panorámicas del Lago Titicaca.",
      "precioReferencial": "45.00",
      "capacidad": 12,
      "ubicacionReferencia": "Plaza Principal de Capachica",
      "estado": true,
      "emprendedorId": 2,
      "emprendedor": {
        "id": 2,
        "nombre": "Carlos Mamani",
        "tipoServicio": "Turismo de Aventura",
        "ubicacion": "Capachica, Puno",
        "telefono": "+51987654322",
        "imagenes": "assets/lugar-turistico2.jpg"
      },
      "categorias": [
        {
          "id": 2,
          "nombre": "Ecoturismo"
        }
      ],
      "horarios": [
        {
          "diaSemana": "jueves",
          "horaInicio": "06:00",
          "horaFin": "16:00"
        },
        {
          "diaSemana": "viernes",
          "horaInicio": "06:00",
          "horaFin": "16:00"
        },
        {
          "diaSemana": "sábado",
          "horaInicio": "06:00",
          "horaFin": "16:00"
        }
      ]
    },
    {
      "id": 3,
      "nombre": "Experiencia Gastronómica Local",
      "descripcion": "Degusta los sabores únicos de la cocina tradicional de Capachica con ingredientes frescos del lago y la región.",
      "precioReferencial": "35.00",
      "capacidad": 15,
      "ubicacionReferencia": "Restaurante Familiar Titicaca",
      "estado": true,
      "emprendedorId": 3,
      "emprendedor": {
        "id": 3,
        "nombre": "Ana Condori",
        "tipoServicio": "Gastronomía",
        "ubicacion": "Capachica, Puno",
        "telefono": "+51987654323",
        "imagenes": "assets/lugar-turistico3.jpg"
      },
      "categorias": [
        {
          "id": 3,
          "nombre": "Gastronomía"
        }
      ],
      "horarios": [
        {
          "diaSemana": "lunes",
          "horaInicio": "12:00",
          "horaFin": "20:00"
        },
        {
          "diaSemana": "martes",
          "horaInicio": "12:00",
          "horaFin": "20:00"
        },
        {
          "diaSemana": "domingo",
          "horaInicio": "12:00",
          "horaFin": "18:00"
        }
      ]
    },
    {
      "id": 4,
      "nombre": "Paseo en Lancha a Islas Flotantes",
      "descripcion": "Visita las famosas islas flotantes en una cómoda lancha, conoce la cultura local y disfruta del paisaje único del Titicaca.",
      "precioReferencial": "65.00",
      "capacidad": 20,
      "ubicacionReferencia": "Puerto de Capachica",
      "estado": true,
      "emprendedorId": 4,
      "emprendedor": {
        "id": 4,
        "nombre": "Roberto Huanca",
        "tipoServicio": "Transporte Turístico",
        "ubicacion": "Capachica, Puno",
        "telefono": "+51987654324",
        "imagenes": "assets/lugar-turistico4.jpg"
      },
      "categorias": [
        {
          "id": 4,
          "nombre": "Turismo Cultural"
        }
      ],
      "horarios": [
        {
          "diaSemana": "miércoles",
          "horaInicio": "09:00",
          "horaFin": "15:00"
        },
        {
          "diaSemana": "jueves",
          "horaInicio": "09:00",
          "horaFin": "15:00"
        },
        {
          "diaSemana": "viernes",
          "horaInicio": "09:00",
          "horaFin": "15:00"
        }
      ]
    }
  ];

  Future<List<ServicioCapachica>> fetchServicios() async {
    try {
      print('🔄 ServicesCapachicaProvider: Iniciando fetch de servicios...');
      print('🌐 ServicesCapachicaProvider: URL: $baseUrl/servicios');
      
      final response = await http.get(
        Uri.parse('$baseUrl/servicios'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);
      
      print('📡 ServicesCapachicaProvider: Status code: ${response.statusCode}');
      print('📄 ServicesCapachicaProvider: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        // Manejar diferentes estructuras de respuesta
        List<dynamic> data;
        if (decoded['data'] != null && decoded['data']['data'] != null) {
          data = decoded['data']['data'];
        } else if (decoded['data'] != null) {
          data = decoded['data'] is List ? decoded['data'] : [decoded['data']];
        } else {
          data = decoded is List ? decoded : [decoded];
        }
        
        final servicios = data.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios cargados exitosamente');
        return servicios;
      } else {
        print('❌ ServicesCapachicaProvider: Error HTTP ${response.statusCode}');
        throw Exception('Error al cargar los servicios: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServicios: $e');
      print('🔄 ServicesCapachicaProvider: Usando datos de ejemplo como fallback...');
      
      // Usar datos de ejemplo como fallback
      try {
        final servicios = _datosEjemplo.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios de ejemplo cargados');
        return servicios;
      } catch (fallbackError) {
        print('❌ ServicesCapachicaProvider: Error al cargar datos de ejemplo: $fallbackError');
        throw Exception('Error al cargar los servicios: $e');
      }
    }
  }

  Future<ServicioCapachica> fetchServicioById(int id) async {
    try {
      print('🔄 ServicesCapachicaProvider: Obteniendo servicio con ID: $id');
      
      final response = await http.get(
        Uri.parse('$baseUrl/servicios/$id'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] ?? decoded;
        final servicio = ServicioCapachica.fromJson(data);
        print('✅ ServicesCapachicaProvider: Servicio $id cargado exitosamente');
        return servicio;
      } else {
        throw Exception('Error al cargar el servicio: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServicioById: $e');
      print('🔄 ServicesCapachicaProvider: Buscando en datos de ejemplo...');
      
      // Buscar en datos de ejemplo como fallback
      try {
        final servicioData = _datosEjemplo.firstWhere((s) => s['id'] == id);
        final servicio = ServicioCapachica.fromJson(servicioData);
        print('✅ ServicesCapachicaProvider: Servicio $id encontrado en datos de ejemplo');
        return servicio;
      } catch (fallbackError) {
        print('❌ ServicesCapachicaProvider: Servicio $id no encontrado en datos de ejemplo');
        throw Exception('Error al cargar el servicio: $e');
      }
    }
  }

  Future<List<ServicioCapachica>> fetchServiciosByCategoria(int categoriaId) async {
    try {
      print('🔄 ServicesCapachicaProvider: Obteniendo servicios por categoría: $categoriaId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/servicios/categoria/$categoriaId'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data;
        if (decoded['data'] != null && decoded['data']['data'] != null) {
          data = decoded['data']['data'];
        } else if (decoded['data'] != null) {
          data = decoded['data'] is List ? decoded['data'] : [decoded['data']];
        } else {
          data = decoded is List ? decoded : [decoded];
        }
        
        final servicios = data.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios por categoría cargados');
        return servicios;
      } else {
        throw Exception('Error al cargar servicios por categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServiciosByCategoria: $e');
      print('🔄 ServicesCapachicaProvider: Filtrando datos de ejemplo por categoría...');
      
      // Filtrar datos de ejemplo como fallback
      try {
        final serviciosFiltrados = _datosEjemplo.where((s) {
          final categorias = s['categorias'] as List<dynamic>;
          return categorias.any((cat) => cat['id'] == categoriaId);
        }).toList();
        
        final servicios = serviciosFiltrados.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios de ejemplo filtrados por categoría');
        return servicios;
      } catch (fallbackError) {
        print('❌ ServicesCapachicaProvider: Error al filtrar datos de ejemplo: $fallbackError');
        throw Exception('Error al cargar servicios por categoría: $e');
      }
    }
  }

  Future<List<ServicioCapachica>> fetchServiciosByEmprendedor(int emprendedorId) async {
    try {
      print('🔄 ServicesCapachicaProvider: Obteniendo servicios por emprendedor: $emprendedorId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/servicios/emprendedor/$emprendedorId'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.requestTimeout);
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data;
        if (decoded['data'] != null && decoded['data']['data'] != null) {
          data = decoded['data']['data'];
        } else if (decoded['data'] != null) {
          data = decoded['data'] is List ? decoded['data'] : [decoded['data']];
        } else {
          data = decoded is List ? decoded : [decoded];
        }
        
        final servicios = data.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios por emprendedor cargados');
        return servicios;
      } else {
        throw Exception('Error al cargar servicios por emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServiciosByEmprendedor: $e');
      print('🔄 ServicesCapachicaProvider: Filtrando datos de ejemplo por emprendedor...');
      
      // Filtrar datos de ejemplo como fallback
      try {
        final serviciosFiltrados = _datosEjemplo.where((s) => s['emprendedorId'] == emprendedorId).toList();
        final servicios = serviciosFiltrados.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios de ejemplo filtrados por emprendedor');
        return servicios;
      } catch (fallbackError) {
        print('❌ ServicesCapachicaProvider: Error al filtrar datos de ejemplo: $fallbackError');
        throw Exception('Error al cargar servicios por emprendedor: $e');
      }
    }
  }
} 