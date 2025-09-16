import 'package:get/get.dart';

import '../http/http_client.dart';
import '../cache/cache_service.dart';

/// Servicio base con funcionalidades comunes
abstract class BaseService extends GetxService {
  final AppHttpClient _httpClient = AppHttpClient.instance;
  final CacheService _cacheService = CacheService.instance;

  // Estados observables comunes
  final isLoading = false.obs;
  final error = Rxn<String>();
  final isEmpty = false.obs;

  /// Realizar petición GET con (opcional) cache
  Future<ApiResponse<T>> getWithCache<T>(
      String endpoint, {
        String? cacheKey,
        T Function(Map<String, dynamic>)? fromJson,
        Duration? cacheTTL,
        bool forceRefresh = false,
        Map<String, String>? queryParams, // <- NUEVO
      }) async {
    try {
      // Intentar obtener del cache si no se fuerza refresh
      if (!forceRefresh && cacheKey != null && fromJson != null) {
        final cachedData = await _cacheService.get<T>(cacheKey, fromJson);
        if (cachedData != null) {
          return ApiResponse<T>.success(
            data: cachedData,
            message: 'Datos obtenidos del cache',
          );
        }
      }

      // Realizar petición HTTP
      final response = await _httpClient.get<T>(
        endpoint,
        fromJson: fromJson,
        queryParams: queryParams, // <- NUEVO
      );

      // Guardar en cache si fue exitosa
      if (response.success && response.data != null && cacheKey != null) {
        await _cacheService.set(cacheKey, response.data, ttl: cacheTTL);
      }

      return response;
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  /// Realizar petición POST
  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        Map<String, dynamic>? body,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _httpClient.post<T>(
        endpoint,
        body: body,
        fromJson: fromJson,
      );

      if (response.success) {
        await _invalidateRelatedCache(endpoint);
      }
      return response;
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  /// Realizar petición PUT
  Future<ApiResponse<T>> put<T>(
      String endpoint, {
        Map<String, dynamic>? body,
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _httpClient.put<T>(
        endpoint,
        body: body,
        fromJson: fromJson,
      );

      if (response.success) {
        await _invalidateRelatedCache(endpoint);
      }
      return response;
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  /// Realizar petición DELETE
  Future<ApiResponse<T>> delete<T>(
      String endpoint, {
        T Function(Map<String, dynamic>)? fromJson,
      }) async {
    try {
      final response = await _httpClient.delete<T>(
        endpoint,
        fromJson: fromJson,
      );

      if (response.success) {
        await _invalidateRelatedCache(endpoint);
      }
      return response;
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  /// Invalidar cache relacionado según el endpoint
  Future<void> _invalidateRelatedCache(String endpoint) async {
    if (endpoint.contains('/servicios')) {
      await _cacheService.invalidateByPattern('services_');
    } else if (endpoint.contains('/planes')) {
      await _cacheService.invalidateByPattern('planes_');
    } else if (endpoint.contains('/eventos')) {
      await _cacheService.invalidateByPattern('eventos_');
    } else if (endpoint.contains('/emprendedores')) {
      await _cacheService.invalidateByPattern('emprendedores_');
    } else if (endpoint.contains('/reservas')) {
      await _cacheService.invalidateByPattern('reservas_');
    } else if (endpoint.contains('/municipalidad')) {
      await _cacheService.invalidateByPattern('municipalidad_');
    }
  }

  /// Manejar estado de carga
  void setLoading(bool loading) {
    isLoading.value = loading;
    if (loading) {
      error.value = null;
    }
  }

  /// Manejar error
  void setError(String? errorMessage) {
    error.value = errorMessage;
    isLoading.value = false;
  }

  /// Limpiar error
  void clearError() {
    error.value = null;
  }

  /// Manejar estado vacío
  void setEmpty(bool empty) {
    isEmpty.value = empty;
  }

  /// Ejecutar operación con manejo de estados
  Future<T?> executeWithStates<T>(
      Future<T> Function() operation, {
        bool showLoading = true,
        bool clearPrevError = true, // <- RENOMBRADO
      }) async {
    try {
      if (showLoading) setLoading(true);
      if (clearPrevError) clearError(); // ya no choca con el parámetro

      final result = await operation();

      setLoading(false);
      setEmpty(result == null || (result is List && result.isEmpty));
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  /// Obtener lista paginada (con cache opcional)
  Future<PaginationResult<T>> getPaginated<T>(
      String endpoint, {
        int page = 1,
        int pageSize = 20,
        String? cacheKey,
        T Function(Map<String, dynamic>)? fromJson,
        Map<String, String>? queryParams,
      }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'per_page': pageSize.toString(),
        ...?queryParams,
      };

      // Pedimos el JSON crudo y lo adaptamos
      final response = await getWithCache<Map<String, dynamic>>(
        endpoint,
        cacheKey: cacheKey,
        fromJson: (m) => m,
        queryParams: params,
      );

      if (response.success && response.data != null) {
        return PaginationResult<T>.fromJson(response.data!, fromJson);
      }
      return PaginationResult<T>.empty();
    } catch (e) {
      return PaginationResult<T>.error(e.toString());
    }
  }

  /// Limpiar cache del servicio
  Future<void> clearCache() async => _cacheService.clear();

  /// Obtener estadísticas del cache
  Map<String, dynamic> getCacheStats() => _cacheService.getCacheStats();
}

/// Resultado de paginación local para evitar choque de nombres
class PaginationResult<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;
  final String? message;
  final bool success;

  PaginationResult({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
    this.message,
    required this.success,
  });

  factory PaginationResult.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>)? fromJson,
      ) {
    final list = (json['data'] as List?) ?? const [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const {};

    return PaginationResult<T>(
      data: fromJson != null
          ? list
          .cast<Map<String, dynamic>>()
          .map((item) => fromJson(item))
          .toList()
          : List<T>.from(list),
      currentPage: (meta['current_page'] ?? 1) as int,
      lastPage: (meta['last_page'] ?? 1) as int,
      perPage: (meta['per_page'] ?? 20) as int,
      total: (meta['total'] ?? 0) as int,
      hasMorePages: (meta['has_more_pages'] ?? false) as bool,
      message: json['message'] as String?,
      success: true,
    );
  }

  factory PaginationResult.empty() => PaginationResult<T>(
    data: const [],
    currentPage: 1,
    lastPage: 1,
    perPage: 20,
    total: 0,
    hasMorePages: false,
    success: true,
  );

  factory PaginationResult.error(String message) => PaginationResult<T>(
    data: const [],
    currentPage: 1,
    lastPage: 1,
    perPage: 20,
    total: 0,
    hasMorePages: false,
    message: message,
    success: false,
  );
}