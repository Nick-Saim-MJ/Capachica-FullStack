import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/backend_config.dart';
import '../core/exceptions/api_exception.dart';
import '../data/models/plan_model.dart';
import '../data/models/plan_detalle_model.dart';
import '../data/models/emprendedor_model.dart';

class PlanService {
  final http.Client _client = http.Client();

  // GET /api/public/planes - obtener lista de planes para landing page
  Future<List<Plan>> getPlanesPublicosLanding() async {
    try {
      print('🗺️ PlanService: Obteniendo planes públicos para landing...');
      
      if (BackendConfig.testMode) {
        print('🧪 PlanService: Usando modo de prueba para planes públicos landing');
        await Future.delayed(Duration(milliseconds: 800));
        return [
          Plan(
            id: 1,
            titulo: 'Aventura en el Lago Titicaca',
            descripcion: 'Explora las islas flotantes y conoce la cultura local',
            imagenUrl: 'https://example.com/plan1.jpg',
            precio: 150.0,
            duracion: 2,
            ubicacion: 'Lago Titicaca, Puno',
            isPublico: true,
            categoria: 'Aventura',
            rating: 4.8,
            numResenas: 45,
            isActivo: true,
          ),
          Plan(
            id: 2,
            titulo: 'Cultura y Tradición Capachica',
            descripcion: 'Sumérgete en las tradiciones ancestrales de la región',
            imagenUrl: 'https://example.com/plan2.jpg',
            precio: 120.0,
            duracion: 1,
            ubicacion: 'Capachica, Puno',
            isPublico: true,
            categoria: 'Cultural',
            rating: 4.6,
            numResenas: 32,
            isActivo: true,
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/public/planes'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 PlanService: Planes públicos landing response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> planesData = data['data'] ?? data;
        return planesData.map((json) => Plan.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo planes públicos landing: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ PlanService: Error obteniendo planes públicos landing: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/public/planes/{id} - obtener detalles de un plan público
  Future<PlanDetalle> getPlanPublicoDetalle(int id) async {
    try {
      print('🗺️ PlanService: Obteniendo detalles del plan público $id...');
      
      if (BackendConfig.testMode) {
        print('🧪 PlanService: Usando modo de prueba para plan público $id');
        await Future.delayed(Duration(milliseconds: 600));
        
        final plan = Plan(
          id: id,
          titulo: 'Aventura en el Lago Titicaca',
          descripcion: 'Explora las islas flotantes y conoce la cultura local',
          imagenUrl: 'https://example.com/plan$id.jpg',
          precio: 150.0,
          duracion: 2,
          ubicacion: 'Lago Titicaca, Puno',
          isPublico: true,
          categoria: 'Aventura',
          rating: 4.8,
          numResenas: 45,
          isActivo: true,
        );

        final itinerario = [
          Itinerario(
            id: 1,
            titulo: 'Llegada y Bienvenida',
            descripcion: 'Recepción en el puerto de Puno',
            dia: 1,
            horaInicio: '08:00',
            horaFin: '09:00',
            ubicacion: 'Puerto de Puno',
          ),
          Itinerario(
            id: 2,
            titulo: 'Navegación a las Islas',
            descripcion: 'Viaje en bote tradicional',
            dia: 1,
            horaInicio: '09:30',
            horaFin: '11:00',
            ubicacion: 'Lago Titicaca',
          ),
        ];

        final incluye = [
          Incluye(id: 1, nombre: 'Transporte', descripcion: 'Bote ida y vuelta', isIncluido: true),
          Incluye(id: 2, nombre: 'Guía local', descripcion: 'Guía bilingüe', isIncluido: true),
          Incluye(id: 3, nombre: 'Almuerzo', descripcion: 'Comida típica', isIncluido: true),
        ];

        final noIncluye = [
          Incluye(id: 4, nombre: 'Bebidas', descripcion: 'Bebidas adicionales', isIncluido: false),
          Incluye(id: 5, nombre: 'Propinas', descripcion: 'Propinas opcionales', isIncluido: false),
        ];

        return PlanDetalle(
          plan: plan,
          itinerario: itinerario,
          incluye: incluye,
          noIncluye: noIncluye,
          informacionAdicional: {
            'capacidad_maxima': 15,
            'edad_minima': 5,
            'requisitos': 'Ropa cómoda y protector solar',
          },
        );
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/public/planes/$id'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 PlanService: Plan público $id response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detalleData = data['data'] ?? data;
        return PlanDetalle.fromJson(detalleData);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Plan no encontrado');
      } else {
        throw ApiException(
          message: 'Error obteniendo plan público: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ PlanService: Error obteniendo plan público $id: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/planes - listar todos los planes
  Future<List<Plan>> getAllPlanes() async {
    try {
      print('🗺️ PlanService: Obteniendo todos los planes...');
      
      if (BackendConfig.testMode) {
        print('🧪 PlanService: Usando modo de prueba para todos los planes');
        await Future.delayed(Duration(milliseconds: 1000));
        return [
          Plan(
            id: 1,
            titulo: 'Aventura en el Lago Titicaca',
            descripcion: 'Explora las islas flotantes y conoce la cultura local',
            imagenUrl: 'https://example.com/plan1.jpg',
            precio: 150.0,
            duracion: 2,
            ubicacion: 'Lago Titicaca, Puno',
            isPublico: true,
            categoria: 'Aventura',
            rating: 4.8,
            numResenas: 45,
            isActivo: true,
          ),
          Plan(
            id: 2,
            titulo: 'Cultura y Tradición Capachica',
            descripcion: 'Sumérgete en las tradiciones ancestrales de la región',
            imagenUrl: 'https://example.com/plan2.jpg',
            precio: 120.0,
            duracion: 1,
            ubicacion: 'Capachica, Puno',
            isPublico: true,
            categoria: 'Cultural',
            rating: 4.6,
            numResenas: 32,
            isActivo: true,
          ),
          Plan(
            id: 3,
            titulo: 'Gastronomía Local',
            descripcion: 'Descubre los sabores auténticos de la región',
            imagenUrl: 'https://example.com/plan3.jpg',
            precio: 80.0,
            duracion: 1,
            ubicacion: 'Capachica, Puno',
            isPublico: false,
            categoria: 'Gastronomía',
            rating: 4.5,
            numResenas: 28,
            isActivo: true,
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/planes'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 PlanService: Todos los planes response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> planesData = data['data'] ?? data;
        return planesData.map((json) => Plan.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo todos los planes: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ PlanService: Error obteniendo todos los planes: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/planes/publicos - listar solo planes públicos
  Future<List<Plan>> getPlanesPublicos() async {
    try {
      print('🗺️ PlanService: Obteniendo planes públicos...');
      
      if (BackendConfig.testMode) {
        print('🧪 PlanService: Usando modo de prueba para planes públicos');
        await Future.delayed(Duration(milliseconds: 900));
        return [
          Plan(
            id: 1,
            titulo: 'Aventura en el Lago Titicaca',
            descripcion: 'Explora las islas flotantes y conoce la cultura local',
            imagenUrl: 'https://example.com/plan1.jpg',
            precio: 150.0,
            duracion: 2,
            ubicacion: 'Lago Titicaca, Puno',
            isPublico: true,
            categoria: 'Aventura',
            rating: 4.8,
            numResenas: 45,
            isActivo: true,
          ),
          Plan(
            id: 2,
            titulo: 'Cultura y Tradición Capachica',
            descripcion: 'Sumérgete en las tradiciones ancestrales de la región',
            imagenUrl: 'https://example.com/plan2.jpg',
            precio: 120.0,
            duracion: 1,
            ubicacion: 'Capachica, Puno',
            isPublico: true,
            categoria: 'Cultural',
            rating: 4.6,
            numResenas: 32,
            isActivo: true,
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/planes/publicos'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 PlanService: Planes públicos response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> planesData = data['data'] ?? data;
        return planesData.map((json) => Plan.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo planes públicos: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ PlanService: Error obteniendo planes públicos: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/planes/search - buscar planes con parámetros
  Future<List<Plan>> searchPlanes({
    String? query,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? duracionMin,
    int? duracionMax,
    String? ubicacion,
  }) async {
    try {
      print('🗺️ PlanService: Buscando planes...');
      
      if (BackendConfig.testMode) {
        print('🧪 PlanService: Usando modo de prueba para búsqueda de planes');
        await Future.delayed(Duration(milliseconds: 700));
        
        // Simular búsqueda filtrada
        final allPlanes = [
          Plan(
            id: 1,
            titulo: 'Aventura en el Lago Titicaca',
            descripcion: 'Explora las islas flotantes y conoce la cultura local',
            imagenUrl: 'https://example.com/plan1.jpg',
            precio: 150.0,
            duracion: 2,
            ubicacion: 'Lago Titicaca, Puno',
            isPublico: true,
            categoria: 'Aventura',
            rating: 4.8,
            numResenas: 45,
            isActivo: true,
          ),
          Plan(
            id: 2,
            titulo: 'Cultura y Tradición Capachica',
            descripcion: 'Sumérgete en las tradiciones ancestrales de la región',
            imagenUrl: 'https://example.com/plan2.jpg',
            precio: 120.0,
            duracion: 1,
            ubicacion: 'Capachica, Puno',
            isPublico: true,
            categoria: 'Cultural',
            rating: 4.6,
            numResenas: 32,
            isActivo: true,
          ),
        ];

        // Aplicar filtros simulados
        var filteredPlanes = allPlanes;
        
        if (query != null && query.isNotEmpty) {
          filteredPlanes = filteredPlanes.where((plan) =>
            plan.titulo.toLowerCase().contains(query.toLowerCase()) ||
            (plan.descripcion?.toLowerCase().contains(query.toLowerCase()) ?? false)
          ).toList();
        }

        if (categoria != null && categoria.isNotEmpty) {
          filteredPlanes = filteredPlanes.where((plan) =>
            plan.categoria?.toLowerCase() == categoria.toLowerCase()
          ).toList();
        }

        if (precioMin != null) {
          filteredPlanes = filteredPlanes.where((plan) =>
            plan.precio != null && plan.precio! >= precioMin
          ).toList();
        }

        if (precioMax != null) {
          filteredPlanes = filteredPlanes.where((plan) =>
            plan.precio != null && plan.precio! <= precioMax
          ).toList();
        }

        return filteredPlanes;
      }

      // Construir query parameters
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (categoria != null && categoria.isNotEmpty) queryParams['categoria'] = categoria;
      if (precioMin != null) queryParams['precio_min'] = precioMin.toString();
      if (precioMax != null) queryParams['precio_max'] = precioMax.toString();
      if (duracionMin != null) queryParams['duracion_min'] = duracionMin.toString();
      if (duracionMax != null) queryParams['duracion_max'] = duracionMax.toString();
      if (ubicacion != null && ubicacion.isNotEmpty) queryParams['ubicacion'] = ubicacion;

      final uri = Uri.parse('${BackendConfig.getBaseUrl()}/planes/search').replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: BackendConfig.defaultHeaders)
          .timeout(BackendConfig.requestTimeout);

      print('📡 PlanService: Búsqueda de planes response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> planesData = data['data'] ?? data;
        return planesData.map((json) => Plan.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error buscando planes: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ PlanService: Error buscando planes: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/planes/{id} - ver un plan específico
  Future<PlanDetalle> getPlanDetalle(int id) async {
    try {
      print('🗺️ PlanService: Obteniendo detalles del plan $id...');
      
      if (BackendConfig.testMode) {
        print('🧪 PlanService: Usando modo de prueba para plan $id');
        await Future.delayed(Duration(milliseconds: 600));
        
        final plan = Plan(
          id: id,
          titulo: 'Aventura en el Lago Titicaca',
          descripcion: 'Explora las islas flotantes y conoce la cultura local',
          imagenUrl: 'https://example.com/plan$id.jpg',
          precio: 150.0,
          duracion: 2,
          ubicacion: 'Lago Titicaca, Puno',
          isPublico: true,
          categoria: 'Aventura',
          rating: 4.8,
          numResenas: 45,
          isActivo: true,
        );

        final itinerario = [
          Itinerario(
            id: 1,
            titulo: 'Llegada y Bienvenida',
            descripcion: 'Recepción en el puerto de Puno',
            dia: 1,
            horaInicio: '08:00',
            horaFin: '09:00',
            ubicacion: 'Puerto de Puno',
          ),
          Itinerario(
            id: 2,
            titulo: 'Navegación a las Islas',
            descripcion: 'Viaje en bote tradicional',
            dia: 1,
            horaInicio: '09:30',
            horaFin: '11:00',
            ubicacion: 'Lago Titicaca',
          ),
        ];

        final incluye = [
          Incluye(id: 1, nombre: 'Transporte', descripcion: 'Bote ida y vuelta', isIncluido: true),
          Incluye(id: 2, nombre: 'Guía local', descripcion: 'Guía bilingüe', isIncluido: true),
          Incluye(id: 3, nombre: 'Almuerzo', descripcion: 'Comida típica', isIncluido: true),
        ];

        final noIncluye = [
          Incluye(id: 4, nombre: 'Bebidas', descripcion: 'Bebidas adicionales', isIncluido: false),
          Incluye(id: 5, nombre: 'Propinas', descripcion: 'Propinas opcionales', isIncluido: false),
        ];

        return PlanDetalle(
          plan: plan,
          itinerario: itinerario,
          incluye: incluye,
          noIncluye: noIncluye,
          informacionAdicional: {
            'capacidad_maxima': 15,
            'edad_minima': 5,
            'requisitos': 'Ropa cómoda y protector solar',
          },
        );
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/planes/$id'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 PlanService: Plan $id response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detalleData = data['data'] ?? data;
        return PlanDetalle.fromJson(detalleData);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Plan no encontrado');
      } else {
        throw ApiException(
          message: 'Error obteniendo plan: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ PlanService: Error obteniendo plan $id: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/planes/{id}/emprendedores - ver emprendedores asociados a un plan
  Future<List<Emprendedor>> getEmprendedoresPorPlan(int id) async {
    try {
      print('🗺️ PlanService: Obteniendo emprendedores del plan $id...');
      
      if (BackendConfig.testMode) {
        print('🧪 PlanService: Usando modo de prueba para emprendedores del plan $id');
        await Future.delayed(Duration(milliseconds: 500));
        return [
          Emprendedor(
            id: 1,
            nombre: 'Restaurante El Lago',
            tipoServicio: 'Gastronomía',
            ubicacion: 'Plaza Principal, Capachica',
            descripcion: 'Comida típica de la región con vista al lago',
            telefono: '+51 987 654 321',
            email: 'info@ellago.com',
            imagen: 'https://example.com/emprendedor1.jpg',
            estado: true,
          ),
          Emprendedor(
            id: 2,
            nombre: 'Artesanías Titicaca',
            tipoServicio: 'Artesanía',
            ubicacion: 'Calle Comercial, Capachica',
            descripcion: 'Productos artesanales locales',
            telefono: '+51 987 654 322',
            email: 'info@artesanias.com',
            imagen: 'https://example.com/emprendedor2.jpg',
            estado: true,
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/planes/$id/emprendedores'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 PlanService: Emprendedores del plan $id response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> emprendedoresData = data['data'] ?? data;
        return emprendedoresData.map((json) => Emprendedor.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Plan no encontrado');
      } else {
        throw ApiException(
          message: 'Error obteniendo emprendedores del plan: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ PlanService: Error obteniendo emprendedores del plan $id: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  void dispose() {
    _client.close();
  }
} 