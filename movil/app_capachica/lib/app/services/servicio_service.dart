import '../data/models/servicio_model.dart';
import '../core/config/app_config.dart';
import '../core/compatibility/api_client.dart';
import '../core/compatibility/request_builder.dart';
import '../core/compatibility/response_adapter.dart'; // PaginatedResponse
import '../core/cache/cache_service.dart';
import '../core/services/base_service.dart';
import '../core/utils/pagination_helper.dart';

class ServicioService extends BaseService {
  final _httpClient = CompatibilityApiClient.instance;
  final _requestBuilder = RequestBuilder();
  final _cacheService = CacheService.instance;
  final _paginationHelper = PaginationHelper();

  // Cache TTL para servicios (15 minutos)
  static const Duration _cacheTTL = Duration(minutes: 15);

  // Datos de prueba para modo test
  static const List<Map<String, dynamic>> _testServicios = [
    {
      'id': 1,
      'emprendedor_id': 1,
      'nombre': 'Habitación Doble con Vista al Lago',
      'descripcion':
      'Habitación cómoda con vista panorámica al lago Titicaca, baño privado, desayuno incluido y wifi gratuito.',
      'precio': 80.0,
      'imagen_url': 'habitacion1.jpg',
      'categoria': 'Alojamiento',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '14:00',
      'hora_fin': '12:00',
      'capacidad': 2,
      'ubicacion': 'Segundo piso, habitación 201',
      'imagenes': ['habitacion1.jpg', 'habitacion2.jpg', 'vista_lago.jpg'],
      'fecha_creacion': '2024-01-15T10:30:00Z',
    },
    {
      'id': 2,
      'emprendedor_id': 1,
      'nombre': 'Habitación Familiar',
      'descripcion':
      'Habitación amplia para hasta 4 personas, ideal para familias, con baño privado y terraza.',
      'precio': 120.0,
      'imagen_url': 'habitacion_familiar.jpg',
      'categoria': 'Alojamiento',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '14:00',
      'hora_fin': '12:00',
      'capacidad': 4,
      'ubicacion': 'Primer piso, habitación 101',
      'imagenes': ['habitacion_familiar.jpg', 'terraza.jpg'],
      'fecha_creacion': '2024-01-15T10:30:00Z',
    },
    {
      'id': 3,
      'emprendedor_id': 2,
      'nombre': 'Trucha del Lago',
      'descripcion':
      'Trucha fresca del lago Titicaca preparada a la plancha con papas nativas y ensalada.',
      'precio': 25.0,
      'imagen_url': 'trucha_plancha.jpg',
      'categoria': 'Restaurante',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '11:00',
      'hora_fin': '21:00',
      'capacidad': 50,
      'ubicacion': 'Restaurante principal',
      'imagenes': ['trucha_plancha.jpg', 'plato_completo.jpg'],
      'fecha_creacion': '2024-01-10T08:15:00Z',
    },
    {
      'id': 4,
      'emprendedor_id': 2,
      'nombre': 'Cena Típica Andina',
      'descripcion':
      'Cena completa con sopa de quinua, segundo de alpaca y postre tradicional.',
      'precio': 35.0,
      'imagen_url': 'cena_andina.jpg',
      'categoria': 'Restaurante',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '18:00',
      'hora_fin': '22:00',
      'capacidad': 30,
      'ubicacion': 'Restaurante principal',
      'imagenes': ['cena_andina.jpg', 'sopa_quinua.jpg', 'alpaca.jpg'],
      'fecha_creacion': '2024-01-10T08:15:00Z',
    },
    {
      'id': 5,
      'emprendedor_id': 3,
      'nombre': 'Tour Islas Uros',
      'descripcion':
      'Tour completo por las islas flotantes de los Uros con guía local y almuerzo incluido.',
      'precio': 150.0,
      'imagen_url': 'tour_uros.jpg',
      'categoria': 'Turismo',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '08:00',
      'hora_fin': '17:00',
      'capacidad': 15,
      'ubicacion': 'Muelle principal',
      'imagenes': [
        'tour_uros.jpg',
        'islas_flotantes.jpg',
        'bote_tradicional.jpg'
      ],
      'fecha_creacion': '2024-01-05T12:00:00Z',
    },
    {
      'id': 6,
      'emprendedor_id': 3,
      'nombre': 'Tour Taquile',
      'descripcion':
      'Visita a la isla de Taquile con caminata por senderos tradicionales y experiencia cultural.',
      'precio': 120.0,
      'imagen_url': 'tour_taquile.jpg',
      'categoria': 'Turismo',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '07:00',
      'hora_fin': '18:00',
      'capacidad': 12,
      'ubicacion': 'Muelle principal',
      'imagenes': ['tour_taquile.jpg', 'isla_taquile.jpg', 'textiles.jpg'],
      'fecha_creacion': '2024-01-05T12:00:00Z',
    },
    {
      'id': 7,
      'emprendedor_id': 4,
      'nombre': 'Taller de Textiles',
      'descripcion':
      'Aprende las técnicas tradicionales de tejido andino con artesanos locales.',
      'precio': 40.0,
      'imagen_url': 'taller_textiles.jpg',
      'categoria': 'Artesanía',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '09:00',
      'hora_fin': '16:00',
      'capacidad': 8,
      'ubicacion': 'Taller principal',
      'imagenes': ['taller_textiles.jpg', 'tejido_tradicional.jpg'],
      'fecha_creacion': '2024-01-12T10:45:00Z',
    },
    {
      'id': 8,
      'emprendedor_id': 5,
      'nombre': 'Transporte a Islas',
      'descripcion':
      'Servicio de transporte en bote tradicional a las islas del lago Titicaca.',
      'precio': 20.0,
      'imagen_url': 'transporte_bote.jpg',
      'categoria': 'Transporte',
      'disponible': true,
      'fecha_inicio': '2024-01-01',
      'fecha_fin': '2024-12-31',
      'hora_inicio': '06:00',
      'hora_fin': '18:00',
      'capacidad': 25,
      'ubicacion': 'Muelle principal',
      'imagenes': ['transporte_bote.jpg'],
      'fecha_creacion': '2024-01-08T07:30:00Z',
    },
  ];

  // =========================
  // GET /api/servicios
  // =========================
  Future<PaginatedResponse<Servicio>> getServicios({
    int page = 1,
    int perPage = 20,
    String? query,
    String? categoria,
    int? emprendedorId,
    double? precioMin,
    double? precioMax,
    bool? disponible,
    String? ubicacion,
    String? sortBy,
    String? sortOrder = 'asc',
  }) async {
    final result =
    await executeWithStates<PaginatedResponse<Servicio>>(() async {
      // Modo de prueba
      if (AppConfig.isTestMode) {
        // ignore: avoid_print
        print('[ServicioService] Usando datos de prueba para getServicios');
        await Future.delayed(const Duration(milliseconds: 500));

        List<Map<String, dynamic>> filteredData = List.from(_testServicios);

        // Filtros
        if (query != null && query.isNotEmpty) {
          final q = query.toLowerCase();
          filteredData = filteredData.where((s) {
            return s['nombre'].toLowerCase().contains(q) ||
                s['descripcion'].toLowerCase().contains(q) ||
                s['categoria'].toLowerCase().contains(q);
          }).toList();
        }
        if (categoria != null && categoria.isNotEmpty) {
          filteredData = filteredData
              .where((s) =>
          s['categoria'].toLowerCase() == categoria.toLowerCase())
              .toList();
        }
        if (emprendedorId != null) {
          filteredData =
              filteredData.where((s) => s['emprendedor_id'] == emprendedorId).toList();
        }
        if (precioMin != null) {
          filteredData = filteredData
              .where((s) => (s['precio'] as num).toDouble() >= precioMin)
              .toList();
        }
        if (precioMax != null) {
          filteredData = filteredData
              .where((s) => (s['precio'] as num).toDouble() <= precioMax)
              .toList();
        }
        if (disponible != null) {
          filteredData =
              filteredData.where((s) => s['disponible'] == disponible).toList();
        }
        if (ubicacion != null && ubicacion.isNotEmpty) {
          filteredData = filteredData
              .where((s) =>
              (s['ubicacion'] as String).toLowerCase().contains(ubicacion.toLowerCase()))
              .toList();
        }

        // Paginación
        final startIndex = (page - 1) * perPage;
        final endIndex = (startIndex + perPage).clamp(0, filteredData.length);
        final pageList = filteredData.sublist(startIndex, endIndex);

        final servicios =
        pageList.map((json) => Servicio.fromJson(json)).toList();

        return PaginatedResponse<Servicio>.success(
          data: servicios,
          currentPage: page,
          totalPages: (filteredData.length / perPage).ceil(),
          totalItems: filteredData.length,
          perPage: perPage,
          hasNextPage: endIndex < filteredData.length,
          hasPreviousPage: page > 1,
          message: 'Datos obtenidos en modo prueba',
          statusCode: 200,
        );
      }

      // Parámetros
      final searchParams = _requestBuilder.buildSearchParams(query: query);
      final filterParams = _requestBuilder.buildFilterParams(
        categoria: categoria,
        emprendedorId: emprendedorId,
        precioMin: precioMin,
        precioMax: precioMax,
        estado: disponible?.toString(),
      );
      final paginationParams =
      _requestBuilder.buildPaginationParams(page: page, perPage: perPage);
      final sortParams =
      _requestBuilder.buildSortParams(sortBy: sortBy, sortOrder: sortOrder);

      final queryParams = _requestBuilder.combineParams(
        _requestBuilder.combineParams(
          _requestBuilder.combineParams(searchParams, filterParams),
          paginationParams,
        ),
        sortParams,
      );

      if (ubicacion != null && ubicacion.isNotEmpty) {
        queryParams['ubicacion'] = ubicacion;
      }

      final cacheKey =
          'servicios_${page}_${perPage}_${query ?? ''}_${categoria ?? ''}_${emprendedorId ?? ''}_${precioMin ?? ''}_${precioMax ?? ''}_${disponible ?? ''}_${ubicacion ?? ''}_${sortBy ?? ''}_${sortOrder ?? ''}';

      // Cache
      final cached =
      await _cacheService.getServicesData<PaginatedResponse<Servicio>>(
        cacheKey,
            (json) => _parsePaginatedResponse(json),
      );
      if (cached != null) {
        // ignore: avoid_print
        print('[ServicioService] Datos obtenidos del cache: $cacheKey');
        return cached;
      }

      // Petición
      final response = await _httpClient.get<List<Servicio>>(
        AppConfig.getEndpoint('services', 'list'),
        queryParams: queryParams,
        fromJson: (json) =>
            (json as List).map((x) => Servicio.fromJson(x)).toList(),
      );

      if (response.success && response.data != null) {
        final list = response.data!;
        final totalPages = _calculateTotalPages(list.length, perPage);
        final hasNext = list.length >= perPage;

        final pageResp = PaginatedResponse<Servicio>.success(
          data: list,
          currentPage: page,
          totalPages: totalPages,
          totalItems: list.length,
          perPage: perPage,
          hasNextPage: hasNext,
          hasPreviousPage: page > 1,
          message: response.message,
          statusCode: response.statusCode,
        );

        // Guardamos al cache como Map (PaginatedResponse no tiene toJson)
        final cacheMap = {
          'data': list.map((e) => e.toJson()).toList(),
          'currentPage': page,
          'totalPages': totalPages,
          'totalItems': list.length,
          'perPage': perPage,
          'hasNextPage': hasNext,
          'hasPreviousPage': page > 1,
          'message': response.message,
          'statusCode': response.statusCode,
        };
        await _cacheService.setServicesData(cacheKey, cacheMap);

        return pageResp;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta en getServicios';
    return result;
  }

  // =========================
  // GET /api/servicios/{id}
  // =========================
  Future<Servicio> getServicio(int id) async {
    final result = await executeWithStates<Servicio>(() async {
      if (AppConfig.isTestMode) {
        // ignore: avoid_print
        print('[ServicioService] Usando datos de prueba para getServicio');
        await Future.delayed(const Duration(milliseconds: 400));

        final servicioData = _testServicios.firstWhere(
              (s) => s['id'] == id,
          orElse: () => throw Exception('Servicio no encontrado'),
        );
        return Servicio.fromJson(servicioData);
      }

      final cacheKey = 'servicio_detail_$id';

      final cached =
      await _cacheService.getServicesData<Servicio>(cacheKey, (json) {
        return Servicio.fromJson(json);
      });
      if (cached != null) {
        // ignore: avoid_print
        print('[ServicioService] Servicio obtenido del cache: $id');
        return cached;
      }

      final response = await _httpClient.get<Servicio>(
        '${AppConfig.getEndpoint('services', 'detail')}/$id',
        fromJson: (json) => Servicio.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _cacheService.setServicesData(cacheKey, response.data!.toJson());
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta en getServicio';
    return result;
  }

  // =========================
  // GET /api/servicios/emprendedor/{id}
  // =========================
  Future<PaginatedResponse<Servicio>> getServiciosByEmprendedor(
      int emprendedorId, {
        int page = 1,
        int perPage = 20,
        String? query,
        String? categoria,
        double? precioMin,
        double? precioMax,
        bool? disponible,
      }) async {
    final result =
    await executeWithStates<PaginatedResponse<Servicio>>(() async {
      if (AppConfig.isTestMode) {
        // ignore: avoid_print
        print(
            '[ServicioService] Usando datos de prueba para getServiciosByEmprendedor');
        await Future.delayed(const Duration(milliseconds: 300));

        List<Map<String, dynamic>> filteredData =
        _testServicios.where((s) => s['emprendedor_id'] == emprendedorId).toList();

        if (query != null && query.isNotEmpty) {
          final q = query.toLowerCase();
          filteredData = filteredData.where((s) {
            return s['nombre'].toLowerCase().contains(q) ||
                s['descripcion'].toLowerCase().contains(q);
          }).toList();
        }
        if (categoria != null && categoria.isNotEmpty) {
          filteredData = filteredData
              .where((s) => s['categoria'].toLowerCase() == categoria.toLowerCase())
              .toList();
        }
        if (precioMin != null) {
          filteredData = filteredData
              .where((s) => (s['precio'] as num).toDouble() >= precioMin)
              .toList();
        }
        if (precioMax != null) {
          filteredData = filteredData
              .where((s) => (s['precio'] as num).toDouble() <= precioMax)
              .toList();
        }
        if (disponible != null) {
          filteredData =
              filteredData.where((s) => s['disponible'] == disponible).toList();
        }

        final startIndex = (page - 1) * perPage;
        final endIndex = (startIndex + perPage).clamp(0, filteredData.length);
        final pageList = filteredData.sublist(startIndex, endIndex);

        final servicios =
        pageList.map((json) => Servicio.fromJson(json)).toList();

        return PaginatedResponse<Servicio>.success(
          data: servicios,
          currentPage: page,
          totalPages: (filteredData.length / perPage).ceil(),
          totalItems: filteredData.length,
          perPage: perPage,
          hasNextPage: endIndex < filteredData.length,
          hasPreviousPage: page > 1,
          message: 'Datos obtenidos en modo prueba',
          statusCode: 200,
        );
      }

      final searchParams = _requestBuilder.buildSearchParams(query: query);
      final filterParams = _requestBuilder.buildFilterParams(
        categoria: categoria,
        precioMin: precioMin,
        precioMax: precioMax,
        estado: disponible?.toString(),
      );
      final paginationParams =
      _requestBuilder.buildPaginationParams(page: page, perPage: perPage);

      final queryParams = _requestBuilder.combineParams(
        _requestBuilder.combineParams(searchParams, filterParams),
        paginationParams,
      );

      final cacheKey =
          'servicios_emprendedor_${emprendedorId}_${page}_${perPage}_${query ?? ''}_${categoria ?? ''}_${precioMin ?? ''}_${precioMax ?? ''}_${disponible ?? ''}';

      final cached =
      await _cacheService.getServicesData<PaginatedResponse<Servicio>>(
        cacheKey,
            (json) => _parsePaginatedResponse(json),
      );
      if (cached != null) {
        // ignore: avoid_print
        print(
            '[ServicioService] Datos de emprendedor obtenidos del cache: $cacheKey');
        return cached;
      }

      final response = await _httpClient.get<List<Servicio>>(
        '${AppConfig.getEndpoint('services', 'byEmprendedor')}/$emprendedorId',
        queryParams: queryParams,
        fromJson: (json) =>
            (json as List).map((x) => Servicio.fromJson(x)).toList(),
      );

      if (response.success && response.data != null) {
        final list = response.data!;
        final totalPages = _calculateTotalPages(list.length, perPage);
        final hasNext = list.length >= perPage;

        final pageResp = PaginatedResponse<Servicio>.success(
          data: list,
          currentPage: page,
          totalPages: totalPages,
          totalItems: list.length,
          perPage: perPage,
          hasNextPage: hasNext,
          hasPreviousPage: page > 1,
          message: response.message,
          statusCode: response.statusCode,
        );

        final cacheMap = {
          'data': list.map((e) => e.toJson()).toList(),
          'currentPage': page,
          'totalPages': totalPages,
          'totalItems': list.length,
          'perPage': perPage,
          'hasNextPage': hasNext,
          'hasPreviousPage': page > 1,
          'message': response.message,
          'statusCode': response.statusCode,
        };
        await _cacheService.setServicesData(cacheKey, cacheMap);

        return pageResp;
      } else {
        throw response.message;
      }
    });

    if (result == null) {
      throw 'No se recibió respuesta en getServiciosByEmprendedor';
    }
    return result;
  }

  // =========================
  // Buscar (reusa getServicios)
  // =========================
  Future<PaginatedResponse<Servicio>> buscarServicios({
    required String query,
    int page = 1,
    int perPage = 20,
    String? categoria,
    int? emprendedorId,
    double? precioMin,
    double? precioMax,
    bool? disponible,
    String? ubicacion,
  }) async {
    return await getServicios(
      page: page,
      perPage: perPage,
      query: query,
      categoria: categoria,
      emprendedorId: emprendedorId,
      precioMin: precioMin,
      precioMax: precioMax,
      disponible: disponible,
      ubicacion: ubicacion,
    );
  }

  // =========================
  // Destacados
  // =========================
  Future<List<Servicio>> getServiciosDestacados() async {
    final result = await executeWithStates<List<Servicio>>(() async {
      if (AppConfig.isTestMode) {
        // ignore: avoid_print
        print(
            '[ServicioService] Usando datos de prueba para getServiciosDestacados');
        await Future.delayed(const Duration(milliseconds: 300));
        return _testServicios
            .take(4)
            .map((json) => Servicio.fromJson(json))
            .toList();
      }

      const cacheKey = 'servicios_destacados';
      final cached =
      await _cacheService.getServicesData<List<Servicio>>(cacheKey, (json) {
        return (json as List).map((x) => Servicio.fromJson(x)).toList();
      });
      if (cached != null) {
        // ignore: avoid_print
        print('[ServicioService] Servicios destacados obtenidos del cache');
        return cached;
      }

      final response = await _httpClient.get<List<Servicio>>(
        '${AppConfig.getEndpoint('services', 'list')}/destacados',
        fromJson: (json) =>
            (json as List).map((x) => Servicio.fromJson(x)).toList(),
      );

      if (response.success && response.data != null) {
        await _cacheService.setServicesData(cacheKey, response.data!);
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta en getServiciosDestacados';
    return result;
  }

  // =========================
  // Categorías
  // =========================
  Future<List<String>> getCategoriasServicios() async {
    final result = await executeWithStates<List<String>>(() async {
      if (AppConfig.isTestMode) {
        // ignore: avoid_print
        print('[ServicioService] Usando datos de prueba para getCategoriasServicios');
        await Future.delayed(const Duration(milliseconds: 200));
        return ['Alojamiento', 'Restaurante', 'Turismo', 'Artesanía', 'Transporte'];
      }

      const cacheKey = 'servicios_categorias';
      final cached =
      await _cacheService.getServicesData<List<String>>(cacheKey, (json) {
        return (json as List).map((x) => x.toString()).toList();
      });
      if (cached != null) {
        // ignore: avoid_print
        print('[ServicioService] Categorías obtenidas del cache');
        return cached;
      }

      final response = await _httpClient.get<List<String>>(
        '${AppConfig.getEndpoint('services', 'list')}/categorias',
        fromJson: (json) => (json as List).map((x) => x.toString()).toList(),
      );

      if (response.success && response.data != null) {
        await _cacheService.setServicesData(cacheKey, response.data!);
        return response.data!;
      } else {
        // fallback
        return ['Alojamiento', 'Restaurante', 'Turismo', 'Artesanía', 'Transporte'];
      }
    });

    if (result == null) throw 'No se recibió respuesta en getCategoriasServicios';
    return result;
  }

  // =========================
  // Cache helpers
  // =========================
  Future<void> invalidarCache({String? patron}) async {
    if (patron != null) {
      await _cacheService.invalidateByPattern('services_$patron');
    } else {
      await _cacheService.invalidateByPattern('services_');
    }
  }

  Future<void> limpiarCache() async {
    await _cacheService.invalidateByPattern('services_');
  }

  // =========================
  // Utilidades privadas
  // =========================
  int _calculateTotalPages(int totalItems, int perPage) {
    if (perPage <= 0) return 1;
    return (totalItems / perPage).ceil();
  }

  PaginatedResponse<Servicio> _parsePaginatedResponse(
      Map<String, dynamic> json) {
    final data =
    (json['data'] as List).map((x) => Servicio.fromJson(x)).toList();

    return PaginatedResponse<Servicio>.success(
      data: data,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? data.length,
      perPage: json['perPage'] ?? 20,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      message: json['message'] ?? 'Datos obtenidos del cache',
      statusCode: json['statusCode'],
    );
  }
}