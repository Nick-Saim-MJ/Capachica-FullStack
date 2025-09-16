import 'package:get/get.dart';

import '../core/config/app_config.dart';
import '../core/services/base_service.dart';
import '../core/cache/cache_service.dart';
import '../core/compatibility/response_adapter.dart'; // <- PaginatedResponse
import '../data/models/services_capachica_model.dart';

/// Servicio para manejar servicios de Capachica
class ServicesCapachicaService extends BaseService {
  static ServicesCapachicaService get instance =>
      Get.find<ServicesCapachicaService>();

  // Cache service (se usaba sin declarar)
  final _cacheService = CacheService.instance;

  /// Obtener todos los servicios
  Future<List<ServicioCapachica>> getServicios({bool forceRefresh = false}) async {
    return await executeWithStates<List<ServicioCapachica>>(() async {
      final response = await getWithCache<List<ServicioCapachica>>(
        AppConfig.getEndpoint('services', 'list'),
        cacheKey: 'all_services',
        fromJson: (json) {
          final data = (json is Map<String, dynamic>) ? (json['data'] ?? json) : json;
          if (data is List) {
            return data
                .map((item) => ServicioCapachica.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <ServicioCapachica>[];
        },
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw response.message;
      }
    }) ??
        <ServicioCapachica>[];
  }

  /// Obtener servicio por ID
  Future<ServicioCapachica?> getServicioById(int id) async {
    return await executeWithStates<ServicioCapachica?>(() async {
      final response = await getWithCache<ServicioCapachica>(
        '${AppConfig.getEndpoint('services', 'detail')}/$id',
        cacheKey: 'service_$id',
        fromJson: (json) {
          final data = (json is Map<String, dynamic>) ? (json['data'] ?? json) : json;
          return ServicioCapachica.fromJson(data as Map<String, dynamic>);
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw response.message;
      }
    });
  }

  /// Obtener servicios por categoría
  Future<List<ServicioCapachica>> getServiciosByCategoria(int categoriaId) async {
    return await executeWithStates<List<ServicioCapachica>>(() async {
      final response = await getWithCache<List<ServicioCapachica>>(
        '${AppConfig.getEndpoint('services', 'byCategory')}/$categoriaId',
        cacheKey: 'services_category_$categoriaId',
        fromJson: (json) {
          final data = (json is Map<String, dynamic>) ? (json['data'] ?? json) : json;
          if (data is List) {
            return data
                .map((item) => ServicioCapachica.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <ServicioCapachica>[];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw response.message;
      }
    }) ??
        <ServicioCapachica>[];
  }

  /// Obtener servicios por emprendedor
  Future<List<ServicioCapachica>> getServiciosByEmprendedor(int emprendedorId) async {
    return await executeWithStates<List<ServicioCapachica>>(() async {
      final response = await getWithCache<List<ServicioCapachica>>(
        '${AppConfig.getEndpoint('services', 'byEmprendedor')}/$emprendedorId',
        cacheKey: 'services_emprendedor_$emprendedorId',
        fromJson: (json) {
          final data = (json is Map<String, dynamic>) ? (json['data'] ?? json) : json;
          if (data is List) {
            return data
                .map((item) => ServicioCapachica.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <ServicioCapachica>[];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw response.message;
      }
    }) ??
        <ServicioCapachica>[];
  }

  /// Buscar servicios
  Future<List<ServicioCapachica>> searchServicios(String query) async {
    return await executeWithStates<List<ServicioCapachica>>(() async {
      final response = await getWithCache<List<ServicioCapachica>>(
        AppConfig.getEndpoint('services', 'list'),
        cacheKey: 'search_services_$query',
        queryParams: {'search': query},
        fromJson: (json) {
          final data = (json is Map<String, dynamic>) ? (json['data'] ?? json) : json;
          if (data is List) {
            return data
                .map((item) => ServicioCapachica.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <ServicioCapachica>[];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw response.message;
      }
    }) ??
        <ServicioCapachica>[];
  }

  /// Obtener servicios paginados
  Future<PaginatedResponse<ServicioCapachica>> getServiciosPaginated({
    int page = 1,
    int pageSize = 20,
    String? search,
    int? categoriaId,
  }) async {
    final result =
    await executeWithStates<PaginatedResponse<ServicioCapachica>>(() async {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoriaId != null) 'categoria_id': categoriaId.toString(),
      };

      // Recuperamos lista y derivamos la paginación si el backend no envía meta
      final listResp = await getWithCache<List<ServicioCapachica>>(
        AppConfig.getEndpoint('services', 'list'),
        cacheKey: 'services_page_${page}_${search ?? 'all'}_${categoriaId ?? 'all'}',
        queryParams: queryParams,
        fromJson: (json) {
          final data = (json is Map<String, dynamic>) ? (json['data'] ?? json) : json;
          if (data is List) {
            return data
                .map((e) => ServicioCapachica.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <ServicioCapachica>[];
        },
      );

      if (!(listResp.success && listResp.data != null)) {
        throw listResp.message;
      }

      final items = listResp.data!;
      final totalItems = items.length; // si no hay meta, usamos la longitud
      final totalPages = (totalItems == 0) ? 1 : (totalItems / pageSize).ceil();
      final hasNext = items.length >= pageSize;

      return PaginatedResponse<ServicioCapachica>.success(
        data: items,
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: pageSize,
        hasNextPage: hasNext,
        hasPreviousPage: page > 1,
        message: listResp.message,
        statusCode: listResp.statusCode,
      );
    });

    return result ??
        PaginatedResponse<ServicioCapachica>.success(
          data: const [],
          currentPage: page,
          totalPages: 1,
          totalItems: 0,
          perPage: pageSize,
          hasNextPage: false,
          hasPreviousPage: false,
          message: 'Sin datos',
          statusCode: 200,
        );
  }

  /// Refrescar servicios
  Future<void> refreshServicios() async {
    await getServicios(forceRefresh: true);
  }

  /// Limpiar cache de servicios
  Future<void> clearServicesCache() async {
    await _cacheService.invalidateByPattern('services_');
  }
}