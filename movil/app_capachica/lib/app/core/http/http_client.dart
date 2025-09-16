import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';
import '../exceptions/api_exception.dart';
/// Import necesario para AuthService
import '../../services/auth_service.dart';

/// Cliente HTTP centralizado con manejo de autenticación y configuración
class AppHttpClient {
  static AppHttpClient? _instance;
  static AppHttpClient get instance => _instance ??= AppHttpClient._();
  
  AppHttpClient._();

  final http.Client _client = http.Client();
  final GetStorage _storage = GetStorage();
  
  String? _token;
  String? _baseUrl;

  /// Inicializar el cliente HTTP
  Future<void> init() async {
    _baseUrl = AppConfig.baseUrl;
    _token = _storage.read('token');
    
    // Escuchar cambios en el token
    ever(Get.find<AuthService>().token, (String? newToken) {
      _token = newToken;
    });
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

  /// Realizar petición GET
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      print('[HttpClient] GET $uri');
      
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('[HttpClient] GET Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Realizar petición POST
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      print('[HttpClient] POST $uri');
      
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('[HttpClient] POST Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Realizar petición PUT
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      print('[HttpClient] PUT $uri');
      
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('[HttpClient] PUT Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Realizar petición DELETE
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      print('[HttpClient] DELETE $uri');
      
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(timeout ?? AppConfig.requestTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      print('[HttpClient] DELETE Error: $e');
      return _handleError<T>(e);
    }
  }

  /// Construir URI con query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// Manejar respuesta HTTP
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    print('[HttpClient] Response ${response.statusCode}: ${response.body}');
    
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.success(
          data: fromJson != null ? fromJson(data) : data as T,
          message: data['message'] ?? 'Operación exitosa',
        );
      } else {
        return ApiResponse<T>.error(
          message: _extractErrorMessage(data, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>.error(
        message: 'Error al procesar respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }

  /// Manejar errores de red
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is SocketException) {
      return ApiResponse<T>.error(
        message: 'Error de conexión. Verifica tu conexión a internet.',
        statusCode: 0,
      );
    } else if (error is HttpException) {
      return ApiResponse<T>.error(
        message: 'Error HTTP: ${error.message}',
        statusCode: 0,
      );
    } else if (error is FormatException) {
      return ApiResponse<T>.error(
        message: 'Error de formato en la respuesta',
        statusCode: 0,
      );
    } else {
      return ApiResponse<T>.error(
        message: error.toString(),
        statusCode: 0,
      );
    }
  }

  /// Extraer mensaje de error de la respuesta
  String _extractErrorMessage(Map<String, dynamic> data, int statusCode) {
    // Intentar obtener mensaje de diferentes ubicaciones
    String? message = data['message'] ?? 
                     data['error'] ?? 
                     data['errors']?.toString();
    
    if (message != null && message.isNotEmpty) {
      return message;
    }
    
    // Mensajes por defecto según código de estado
    switch (statusCode) {
      case 400:
        return 'Solicitud inválida';
      case 401:
        return 'No autorizado. Inicia sesión nuevamente';
      case 403:
        return 'Acceso denegado';
      case 404:
        return 'Recurso no encontrado';
      case 422:
        return 'Datos de entrada inválidos';
      case 500:
        return 'Error interno del servidor';
      default:
        return 'Error del servidor (${statusCode})';
    }
  }

  /// Cerrar cliente HTTP
  void dispose() {
    _client.close();
  }
}

/// Clase para respuestas de API tipadas
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse._({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success({
    required T data,
    required String message,
    int? statusCode,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

