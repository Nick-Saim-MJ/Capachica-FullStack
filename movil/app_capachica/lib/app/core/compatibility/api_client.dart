import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';
import '../exceptions/api_exception.dart';
import '../http/http_client.dart';
import 'request_builder.dart';
import 'response_adapter.dart';
/// Import necesario para AuthService
import '../../services/auth_service.dart';
/// Cliente HTTP de compatibilidad que maneja diferentes formatos de respuesta del backend
class CompatibilityApiClient {
  static CompatibilityApiClient? _instance;
  static CompatibilityApiClient get instance => _instance ??= CompatibilityApiClient._();
  
  CompatibilityApiClient._();

  final http.Client _client = http.Client();
  final GetStorage _storage = GetStorage();
  final RequestBuilder _requestBuilder = RequestBuilder();
  final ResponseAdapter _responseAdapter = ResponseAdapter();
  
  String? _token;
  String? _baseUrl;

  /// Inicializar el cliente HTTP
  Future<void> init() async {
    _baseUrl = AppConfig.baseUrl;
    _token = _storage.read('token');
    
    // Escuchar cambios en el token
    try {
      final authService = Get.find<AuthService>();
      ever(authService.token, (String? newToken) {
        _token = newToken;
      });
    } catch (e) {
      print('[CompatibilityApiClient] AuthService not found, token updates disabled');
    }
  }

  /// Obtener la URL base actual
  String get baseUrl => _baseUrl ?? AppConfig.baseUrl;

  /// Obtener headers con autenticación
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  /// Realizar petición GET con reintentos y manejo de errores 401
  Future<CompatibilityResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    int maxRetries = AppConfig.maxRetries,
  }) async {
    return await _executeWithRetry(
      () => _performGet<T>(endpoint, queryParams, fromJson, timeout),
      maxRetries: maxRetries,
    );
  }

  /// Realizar petición POST con reintentos y manejo de errores 401
  Future<CompatibilityResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    int maxRetries = AppConfig.maxRetries,
  }) async {
    return await _executeWithRetry(
      () => _performPost<T>(endpoint, body, fromJson, timeout),
      maxRetries: maxRetries,
    );
  }

  /// Realizar petición PUT con reintentos y manejo de errores 401
  Future<CompatibilityResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    int maxRetries = AppConfig.maxRetries,
  }) async {
    return await _executeWithRetry(
      () => _performPut<T>(endpoint, body, fromJson, timeout),
      maxRetries: maxRetries,
    );
  }

  /// Realizar petición DELETE con reintentos y manejo de errores 401
  Future<CompatibilityResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    int maxRetries = AppConfig.maxRetries,
  }) async {
    return await _executeWithRetry(
      () => _performDelete<T>(endpoint, fromJson, timeout),
      maxRetries: maxRetries,
    );
  }

  /// Ejecutar petición con reintentos
  Future<CompatibilityResponse<T>> _executeWithRetry<T>(
    Future<CompatibilityResponse<T>> Function() request, {
    required int maxRetries,
  }) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        final response = await request();
        
        // Si es 401, manejar autenticación
        if (response.statusCode == 401) {
          await _handleUnauthorized();
          // No reintentar en 401, solo limpiar token
          return response;
        }
        
        // Si es exitoso o error no recuperable, retornar
        if (response.success || !_isRetryableError(response.statusCode)) {
          return response;
        }
        
        // Si es error recuperable, reintentar
        if (attempts < maxRetries) {
          await Future.delayed(AppConfig.retryDelay * (attempts + 1));
        }
        
        attempts++;
      } catch (e) {
        if (attempts >= maxRetries) {
          return CompatibilityResponse<T>.error(
            message: e.toString(),
            statusCode: 0,
          );
        }
        
        await Future.delayed(AppConfig.retryDelay * (attempts + 1));
        attempts++;
      }
    }
    
    return CompatibilityResponse<T>.error(
      message: 'Máximo número de reintentos alcanzado',
      statusCode: 0,
    );
  }

  /// Realizar petición GET
  Future<CompatibilityResponse<T>> _performGet<T>(
    String endpoint,
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  ) async {
    try {
      final uri = _requestBuilder.buildUri(baseUrl, endpoint, queryParams);
      print('[CompatibilityApiClient] GET $uri');
      
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _responseAdapter.adaptResponse<T>(response, fromJson);
    } catch (e) {
      print('[CompatibilityApiClient] GET Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Realizar petición POST
  Future<CompatibilityResponse<T>> _performPost<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  ) async {
    try {
      final uri = _requestBuilder.buildUri(baseUrl, endpoint);
      print('[CompatibilityApiClient] POST $uri');
      
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _responseAdapter.adaptResponse<T>(response, fromJson);
    } catch (e) {
      print('[CompatibilityApiClient] POST Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Realizar petición PUT
  Future<CompatibilityResponse<T>> _performPut<T>(
    String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  ) async {
    try {
      final uri = _requestBuilder.buildUri(baseUrl, endpoint);
      print('[CompatibilityApiClient] PUT $uri');
      
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _responseAdapter.adaptResponse<T>(response, fromJson);
    } catch (e) {
      print('[CompatibilityApiClient] PUT Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Realizar petición DELETE
  Future<CompatibilityResponse<T>> _performDelete<T>(
    String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  ) async {
    try {
      final uri = _requestBuilder.buildUri(baseUrl, endpoint);
      print('[CompatibilityApiClient] DELETE $uri');
      
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _responseAdapter.adaptResponse<T>(response, fromJson);
    } catch (e) {
      print('[CompatibilityApiClient] DELETE Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Manejar error 401 (no autorizado)
  Future<void> _handleUnauthorized() async {
    print('[CompatibilityApiClient] Handling 401 Unauthorized');
    
    // Limpiar token local
    _token = null;
    await _storage.remove('token');
    
    // Intentar limpiar datos de usuario
    try {
      final authService = Get.find<AuthService>();
      authService.token.value = null;
      authService.currentUser.value = null;
    } catch (e) {
      print('[CompatibilityApiClient] Could not clear auth service: $e');
    }
    
    // No navegar automáticamente - dejar que la UI maneje esto
  }

  /// Verificar si un error es recuperable
  bool _isRetryableError(int? statusCode) {
    if (statusCode == null) return true;
    
    // Reintentar en errores de servidor (5xx) y algunos errores de red
    return statusCode >= 500 || statusCode == 408 || statusCode == 429;
  }

  /// Manejar errores de red
  CompatibilityResponse<T> _handleError<T>(dynamic error) {
    if (error is SocketException) {
      return CompatibilityResponse<T>.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } else if (error is HttpException) {
      return CompatibilityResponse<T>.error(
        message: 'Error HTTP: ${error.message}',
        statusCode: 0,
      );
    } else if (error is FormatException) {
      return CompatibilityResponse<T>.error(
        message: 'Error de formato en la respuesta',
        statusCode: 0,
      );
    } else {
      return CompatibilityResponse<T>.error(
        message: error.toString(),
        statusCode: 0,
      );
    }
  }

  /// Cerrar cliente HTTP
  void dispose() {
    _client.close();
  }
}


