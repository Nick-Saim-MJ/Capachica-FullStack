import 'package:app_capachica/app/core/compatibility/response_adapter.dart';
import 'package:flutter/foundation.dart';

import '../data/models/emprendedor_model.dart';
import '../data/models/emprendedor_resumen_model.dart';
import '../core/config/app_config.dart';
import '../core/compatibility/api_client.dart';
import '../core/compatibility/request_builder.dart';
import '../core/cache/cache_service.dart';
import '../core/services/base_service.dart';

class EmprendedorService extends BaseService {
  final _httpClient = CompatibilityApiClient.instance;
  final _requestBuilder = RequestBuilder();
  final _cacheService = CacheService.instance;

  // Datos de prueba para modo test
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

  // =========================
  // GET /api/emprendedores
  // =========================
  Future<PaginatedResponse<EmprendedorResumen>> getEmprendedores({
    int page = 1,
    int perPage = 20,
    String? query,
    String? categoria,
    String? ubicacion,
    bool? estado,
    String? sortBy,
    String? sortOrder = 'asc',
  }) async {
    final result =
    await executeWithStates<PaginatedResponse<EmprendedorResumen>>(
            () async {
          // Modo de prueba
          if (AppConfig.isTestMode) {
            debugPrint(
                '[EmprendedorService] (test) getEmprendedores con filtros: q=$query, cat=$categoria, ubi=$ubicacion, estado=$estado');

            await Future.delayed(const Duration(milliseconds: 500));
            List<Map<String, dynamic>> filteredData = List.from(_testEmprendedores);

            if (query != null && query.isNotEmpty) {
              final q = query.toLowerCase();
              filteredData = filteredData.where((e) {
                return e['nombre'].toLowerCase().contains(q) ||
                    e['tipo_servicio'].toLowerCase().contains(q) ||
                    e['ubicacion'].toLowerCase().contains(q) ||
                    (e['descripcion']?.toLowerCase().contains(q) ?? false);
              }).toList();
            }

            if (categoria != null && categoria.isNotEmpty) {
              filteredData = filteredData
                  .where((e) =>
              e['tipo_servicio'].toLowerCase() == categoria.toLowerCase())
                  .toList();
            }

            if (ubicacion != null && ubicacion.isNotEmpty) {
              filteredData = filteredData
                  .where((e) =>
                  e['ubicacion'].toLowerCase().contains(ubicacion.toLowerCase()))
                  .toList();
            }

            if (estado != null) {
              filteredData =
                  filteredData.where((e) => e['estado'] == estado).toList();
            }

            final startIndex = (page - 1) * perPage;
            final endIndex = (startIndex + perPage).clamp(0, filteredData.length);
            final paginatedData = filteredData.sublist(startIndex, endIndex);

            final list = paginatedData
                .map((json) => EmprendedorResumen.fromJson(json))
                .toList();

            return PaginatedResponse<EmprendedorResumen>.success(
              data: list,
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
            estado: estado?.toString(),
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
              'emprendedores_${page}_${perPage}_${query ?? ''}_${categoria ?? ''}_${ubicacion ?? ''}_${estado ?? ''}_${sortBy ?? ''}_${sortOrder ?? ''}';

          final cached =
          await _cacheService.getEmprendedoresData<PaginatedResponse<EmprendedorResumen>>(
            cacheKey,
                (json) => _parsePaginatedResponse(json),
          );
          if (cached != null) {
            debugPrint('[EmprendedorService] cache hit: $cacheKey');
            return cached;
          }

          // Petición
          final response = await _httpClient.get<List<EmprendedorResumen>>(
            AppConfig.getEndpoint('emprendedores', 'list'),
            queryParams: queryParams,
            fromJson: (json) =>
                (json as List).map((x) => EmprendedorResumen.fromJson(x)).toList(),
          );

          if (response.success && response.data != null) {
            final dataList = response.data!;
            final totalPages = _calculateTotalPages(dataList.length, perPage);
            final hasNext = dataList.length >= perPage;

            // Construimos el objeto de negocio…
            final pageResp = PaginatedResponse<EmprendedorResumen>.success(
              data: dataList,
              currentPage: page,
              totalPages: totalPages,
              totalItems: dataList.length,
              perPage: perPage,
              hasNextPage: hasNext,
              hasPreviousPage: page > 1,
              message: response.message,
              statusCode: response.statusCode,
            );

            // …y guardamos al cache como Map, no usando toJson inexistente
            final cacheMap = {
              'data': dataList.map((e) => e.toJson()).toList(),
              'currentPage': page,
              'totalPages': totalPages,
              'totalItems': dataList.length,
              'perPage': perPage,
              'hasNextPage': hasNext,
              'hasPreviousPage': page > 1,
              'message': response.message,
              'statusCode': response.statusCode,
            };
            await _cacheService.setEmprendedoresData(cacheKey, cacheMap);

            return pageResp;
          } else {
            throw response.message;
          }
        });

    if (result == null) throw 'No se recibió respuesta en getEmprendedores';
    return result;
  }

  // =========================
  // GET /api/emprendedores/{id}
  // =========================
  Future<Emprendedor> getEmprendedor(int id) async {
    final result = await executeWithStates<Emprendedor>(() async {
      if (AppConfig.isTestMode) {
        debugPrint('[EmprendedorService] (test) getEmprendedor $id');
        await Future.delayed(const Duration(milliseconds: 400));

        final emprendedorData = _testEmprendedores.firstWhere(
              (e) => e['id'] == id,
          orElse: () => throw Exception('Emprendedor no encontrado'),
        );

        final full = {
          ...emprendedorData,
          'servicios': [],
          'relaciones': [],
        };
        return Emprendedor.fromJson(full);
      }

      final cacheKey = 'emprendedor_detail_$id';
      final cached = await _cacheService.getEmprendedoresData<Emprendedor>(
        cacheKey,
            (json) => Emprendedor.fromJson(json),
      );
      if (cached != null) {
        debugPrint('[EmprendedorService] cache hit: $cacheKey');
        return cached;
      }

      final response = await _httpClient.get<Emprendedor>(
        '${AppConfig.getEndpoint('emprendedores', 'detail')}/$id',
        fromJson: (json) => Emprendedor.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _cacheService.setEmprendedoresData(
            cacheKey, response.data!.toJson());
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta en getEmprendedor';
    return result;
  }

  // =========================================
  // GET /api/emprendedores/categoria/{cat}
  // =========================================
  Future<PaginatedResponse<EmprendedorResumen>> getEmprendedoresByCategoria(
      String categoria, {
        int page = 1,
        int perPage = 20,
        String? query,
        String? ubicacion,
        bool? estado,
      }) async {
    final result =
    await executeWithStates<PaginatedResponse<EmprendedorResumen>>(
            () async {
          if (AppConfig.isTestMode) {
            debugPrint(
                '[EmprendedorService] (test) getEmprendedoresByCategoria $categoria');

            await Future.delayed(const Duration(milliseconds: 300));
            List<Map<String, dynamic>> filtered = _testEmprendedores
                .where((e) =>
            e['tipo_servicio'].toLowerCase() == categoria.toLowerCase())
                .toList();

            if (query != null && query.isNotEmpty) {
              final q = query.toLowerCase();
              filtered = filtered.where((e) {
                return e['nombre'].toLowerCase().contains(q) ||
                    e['ubicacion'].toLowerCase().contains(q) ||
                    (e['descripcion']?.toLowerCase().contains(q) ?? false);
              }).toList();
            }
            if (ubicacion != null && ubicacion.isNotEmpty) {
              filtered = filtered
                  .where((e) =>
                  e['ubicacion'].toLowerCase().contains(ubicacion.toLowerCase()))
                  .toList();
            }
            if (estado != null) {
              filtered = filtered.where((e) => e['estado'] == estado).toList();
            }

            final startIndex = (page - 1) * perPage;
            final endIndex = (startIndex + perPage).clamp(0, filtered.length);
            final pageList = filtered.sublist(startIndex, endIndex);

            final data = pageList
                .map((json) => EmprendedorResumen.fromJson(json))
                .toList();

            return PaginatedResponse<EmprendedorResumen>.success(
              data: data,
              currentPage: page,
              totalPages: (filtered.length / perPage).ceil(),
              totalItems: filtered.length,
              perPage: perPage,
              hasNextPage: endIndex < filtered.length,
              hasPreviousPage: page > 1,
              message: 'Datos obtenidos en modo prueba',
              statusCode: 200,
            );
          }

          final searchParams = _requestBuilder.buildSearchParams(query: query);
          final filterParams = _requestBuilder.buildFilterParams(
            categoria: categoria,
            estado: estado?.toString(),
          );
          final paginationParams =
          _requestBuilder.buildPaginationParams(page: page, perPage: perPage);

          final queryParams = _requestBuilder.combineParams(
            _requestBuilder.combineParams(searchParams, filterParams),
            paginationParams,
          );

          if (ubicacion != null && ubicacion.isNotEmpty) {
            queryParams['ubicacion'] = ubicacion;
          }

          final cacheKey =
              'emprendedores_categoria_${categoria}_${page}_${perPage}_${query ?? ''}_${ubicacion ?? ''}_${estado ?? ''}';

          final cached =
          await _cacheService.getEmprendedoresData<PaginatedResponse<EmprendedorResumen>>(
            cacheKey,
                (json) => _parsePaginatedResponse(json),
          );
          if (cached != null) {
            debugPrint('[EmprendedorService] cache hit: $cacheKey');
            return cached;
          }

          final response = await _httpClient.get<List<EmprendedorResumen>>(
            '${AppConfig.getEndpoint('emprendedores', 'byCategory')}/$categoria',
            queryParams: queryParams,
            fromJson: (json) =>
                (json as List).map((x) => EmprendedorResumen.fromJson(x)).toList(),
          );

          if (response.success && response.data != null) {
            final dataList = response.data!;
            final totalPages = _calculateTotalPages(dataList.length, perPage);
            final hasNext = dataList.length >= perPage;

            final pageResp = PaginatedResponse<EmprendedorResumen>.success(
              data: dataList,
              currentPage: page,
              totalPages: totalPages,
              totalItems: dataList.length,
              perPage: perPage,
              hasNextPage: hasNext,
              hasPreviousPage: page > 1,
              message: response.message,
              statusCode: response.statusCode,
            );

            final cacheMap = {
              'data': dataList.map((e) => e.toJson()).toList(),
              'currentPage': page,
              'totalPages': totalPages,
              'totalItems': dataList.length,
              'perPage': perPage,
              'hasNextPage': hasNext,
              'hasPreviousPage': page > 1,
              'message': response.message,
              'statusCode': response.statusCode,
            };
            await _cacheService.setEmprendedoresData(cacheKey, cacheMap);

            return pageResp;
          } else {
            throw response.message;
          }
        });

    if (result == null) {
      throw 'No se recibió respuesta en getEmprendedoresByCategoria';
    }
    return result;
  }

  // =========================
  // Destacados
  // =========================
  Future<List<EmprendedorResumen>> getEmprendedoresDestacados() async {
    final result = await executeWithStates<List<EmprendedorResumen>>(() async {
      if (AppConfig.isTestMode) {
        debugPrint(
            '[EmprendedorService] (test) getEmprendedoresDestacados');
        await Future.delayed(const Duration(milliseconds: 300));
        return _testEmprendedores
            .take(3)
            .map((json) => EmprendedorResumen.fromJson(json))
            .toList();
      }

      const cacheKey = 'emprendedores_destacados';
      final cached =
      await _cacheService.getEmprendedoresData<List<EmprendedorResumen>>(
        cacheKey,
            (json) =>
            (json as List).map((x) => EmprendedorResumen.fromJson(x)).toList(),
      );
      if (cached != null) {
        debugPrint('[EmprendedorService] cache hit destacados');
        return cached;
      }

      final response = await _httpClient.get<List<EmprendedorResumen>>(
        '${AppConfig.getEndpoint('emprendedores', 'list')}/destacados',
        fromJson: (json) =>
            (json as List).map((x) => EmprendedorResumen.fromJson(x)).toList(),
      );

      if (response.success && response.data != null) {
        await _cacheService.setEmprendedoresData(cacheKey, response.data!);
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) {
      throw 'No se recibió respuesta en getEmprendedoresDestacados';
    }
    return result;
  }

  // =========================
  // Categorías
  // =========================
  Future<List<String>> getCategorias() async {
    final result = await executeWithStates<List<String>>(() async {
      if (AppConfig.isTestMode) {
        debugPrint('[EmprendedorService] (test) getCategorias');
        await Future.delayed(const Duration(milliseconds: 200));
        return [
          'Alojamiento',
          'Restaurante',
          'Turismo',
          'Artesanía',
          'Transporte',
          'Otros'
        ];
      }

      const cacheKey = 'emprendedores_categorias';
      final cached = await _cacheService.getEmprendedoresData<List<String>>(
        cacheKey,
            (json) => (json as List).map((x) => x.toString()).toList(),
      );
      if (cached != null) {
        debugPrint('[EmprendedorService] cache hit categorías');
        return cached;
      }

      final response = await _httpClient.get<List<String>>(
        '${AppConfig.getEndpoint('emprendedores', 'list')}/categorias',
        fromJson: (json) => (json as List).map((x) => x.toString()).toList(),
      );

      if (response.success && response.data != null) {
        await _cacheService.setEmprendedoresData(cacheKey, response.data!);
        return response.data!;
      } else {
        // fallback por si backend no responde
        return [
          'Alojamiento',
          'Restaurante',
          'Turismo',
          'Artesanía',
          'Transporte',
          'Otros'
        ];
      }
    });

    if (result == null) throw 'No se recibió respuesta en getCategorias';
    return result;
  }

  // =========================
  // Utilidades privadas
  // =========================

  int _calculateTotalPages(int totalItems, int perPage) {
    if (perPage <= 0) return 1;
    return (totalItems / perPage).ceil();
  }

  PaginatedResponse<EmprendedorResumen> _parsePaginatedResponse(
      Map<String, dynamic> json) {
    final data = (json['data'] as List)
        .map((x) => EmprendedorResumen.fromJson(x))
        .toList();

    return PaginatedResponse<EmprendedorResumen>.success(
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

  // =========================
  // Invalidate Helpers
  // =========================
  Future<void> invalidarCache({String? patron}) async {
    if (patron != null) {
      await _cacheService.invalidateByPattern('emprendedores_$patron');
    } else {
      await _cacheService.invalidateByPattern('emprendedores_');
    }
  }

  Future<void> limpiarCache() async {
    await _cacheService.invalidateByPattern('emprendedores_');
  }
}