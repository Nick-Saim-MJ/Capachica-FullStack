import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

/// Servicio de cache ligero con TTL
class CacheService extends GetxService {
  static CacheService get instance => Get.find<CacheService>();
  
  final GetStorage _storage = GetStorage();
  
  // Prefijos para diferentes tipos de cache
  static const String _authPrefix = 'auth_';
  static const String _servicesPrefix = 'services_';
  static const String _planesPrefix = 'planes_';
  static const String _eventosPrefix = 'eventos_';
  static const String _emprendedoresPrefix = 'emprendedores_';
  static const String _municipalidadPrefix = 'municipalidad_';
  static const String _reservasPrefix = 'reservas_';
  static const String _slidersPrefix = 'sliders_';

  @override
  Future<void> onInit() async {
    super.onInit();
    // Limpiar cache expirado al inicializar
    await _cleanExpiredCache();
  }

  /// Obtener datos del cache
  Future<T?> get<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final cacheKey = _getCacheKey(key);
      final cachedData = _storage.read(cacheKey);
      
      if (cachedData == null) {
        return null;
      }
      
      final cacheEntry = CacheEntry.fromJson(cachedData);
      
      // Verificar si el cache ha expirado
      if (cacheEntry.isExpired) {
        await remove(key);
        return null;
      }
      
      return fromJson(cacheEntry.data);
    } catch (e) {
      print('[CacheService] Error getting cache for key $key: $e');
      return null;
    }
  }

  /// Guardar datos en cache
  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    try {
      final cacheKey = _getCacheKey(key);
      final cacheEntry = CacheEntry(
        data: data is Map<String, dynamic> ? data : (data as dynamic).toJson(),
        timestamp: DateTime.now(),
        ttl: ttl ?? AppConfig.cacheTTL,
      );
      
      await _storage.write(cacheKey, cacheEntry.toJson());
    } catch (e) {
      print('[CacheService] Error setting cache for key $key: $e');
    }
  }

  /// Remover datos del cache
  Future<void> remove(String key) async {
    try {
      final cacheKey = _getCacheKey(key);
      await _storage.remove(cacheKey);
    } catch (e) {
      print('[CacheService] Error removing cache for key $key: $e');
    }
  }

  /// Limpiar todo el cache
  Future<void> clear() async {
    try {
      final keys = _storage.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _storage.remove(key);
        }
      }
    } catch (e) {
      print('[CacheService] Error clearing cache: $e');
    }
  }

  /// Limpiar cache expirado
  Future<void> _cleanExpiredCache() async {
    try {
      final keys = _storage.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          final cachedData = _storage.read(key);
          if (cachedData != null) {
            final cacheEntry = CacheEntry.fromJson(cachedData);
            if (cacheEntry.isExpired) {
              await _storage.remove(key);
            }
          }
        }
      }
    } catch (e) {
      print('[CacheService] Error cleaning expired cache: $e');
    }
  }

  /// Obtener clave de cache con prefijo
  String _getCacheKey(String key) {
    return 'cache_$key';
  }

  // Métodos específicos para diferentes tipos de datos

  /// Cache para autenticación (TTL corto)
  Future<void> setAuthData(String key, dynamic data) async {
    await set(_authPrefix + key, data, ttl: AppConfig.shortCacheTTL);
  }

  Future<T?> getAuthData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_authPrefix + key, fromJson);
  }

  /// Cache para servicios
  Future<void> setServicesData(String key, dynamic data) async {
    await set(_servicesPrefix + key, data);
  }

  Future<T?> getServicesData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_servicesPrefix + key, fromJson);
  }

  /// Cache para planes
  Future<void> setPlanesData(String key, dynamic data) async {
    await set(_planesPrefix + key, data);
  }

  Future<T?> getPlanesData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_planesPrefix + key, fromJson);
  }

  /// Cache para eventos
  Future<void> setEventosData(String key, dynamic data) async {
    await set(_eventosPrefix + key, data);
  }

  Future<T?> getEventosData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_eventosPrefix + key, fromJson);
  }

  /// Cache para emprendedores
  Future<void> setEmprendedoresData(String key, dynamic data) async {
    await set(_emprendedoresPrefix + key, data);
  }

  Future<T?> getEmprendedoresData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_emprendedoresPrefix + key, fromJson);
  }

  /// Cache para municipalidad
  Future<void> setMunicipalidadData(String key, dynamic data) async {
    await set(_municipalidadPrefix + key, data);
  }

  Future<T?> getMunicipalidadData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_municipalidadPrefix + key, fromJson);
  }

  /// Cache para reservas (TTL corto)
  Future<void> setReservasData(String key, dynamic data) async {
    await set(_reservasPrefix + key, data, ttl: AppConfig.shortCacheTTL);
  }

  Future<T?> getReservasData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_reservasPrefix + key, fromJson);
  }

  /// Cache para sliders
  Future<void> setSlidersData(String key, dynamic data) async {
    await set(_slidersPrefix + key, data);
  }

  Future<T?> getSlidersData<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    return await get<T>(_slidersPrefix + key, fromJson);
  }

  /// Invalidar cache por patrón
  Future<void> invalidateByPattern(String pattern) async {
    try {
      final keys = _storage.getKeys();
      for (final key in keys) {
        if (key.contains(pattern)) {
          await _storage.remove(key);
        }
      }
    } catch (e) {
      print('[CacheService] Error invalidating cache by pattern $pattern: $e');
    }
  }

  /// Obtener estadísticas del cache
  Map<String, dynamic> getCacheStats() {
    try {
      final keys = _storage.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith('cache_')).toList();
      
      int expiredCount = 0;
      int validCount = 0;
      
      for (final key in cacheKeys) {
        final cachedData = _storage.read(key);
        if (cachedData != null) {
          final cacheEntry = CacheEntry.fromJson(cachedData);
          if (cacheEntry.isExpired) {
            expiredCount++;
          } else {
            validCount++;
          }
        }
      }
      
      return {
        'totalKeys': cacheKeys.length,
        'validKeys': validCount,
        'expiredKeys': expiredCount,
        'storageSize': _storage.getKeys().length,
      };
    } catch (e) {
      print('[CacheService] Error getting cache stats: $e');
      return {};
    }
  }
}

/// Entrada de cache con TTL
class CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'ttl': ttl.inMilliseconds,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    data: Map<String, dynamic>.from(json['data'] ?? {}),
    timestamp: DateTime.parse(json['timestamp']),
    ttl: Duration(milliseconds: json['ttl'] ?? 0),
  );
}
