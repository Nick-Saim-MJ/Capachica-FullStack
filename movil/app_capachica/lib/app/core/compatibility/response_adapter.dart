import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/case_converter.dart';

/// Adaptador de respuestas que maneja diferentes formatos del backend
class ResponseAdapter {
  final CaseConverter _caseConverter = CaseConverter();

  /// Adaptar respuesta HTTP a formato estándar
  CompatibilityResponse<T> adaptResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    print('[ResponseAdapter] Response ${response.statusCode}: ${response.body}');
    
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _handleSuccessResponse<T>(data, fromJson, response.statusCode);
      } else {
        return _handleErrorResponse<T>(data, response.statusCode);
      }
    } catch (e) {
      return CompatibilityResponse<T>.error(
        message: 'Error al procesar respuesta del servidor',
        statusCode: response.statusCode,
      );
    }
  }

  /// Manejar respuesta exitosa
  CompatibilityResponse<T> _handleSuccessResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic>)? fromJson,
    int statusCode,
  ) {
    // Normalizar datos a camelCase
    final normalizedData = _normalizeData(data);
    
    // Extraer datos según diferentes formatos de respuesta
    final extractedData = _extractData(normalizedData);
    final message = _extractMessage(normalizedData);
    
    if (fromJson != null && extractedData != null) {
      try {
        final parsedData = fromJson(extractedData);
        return CompatibilityResponse<T>.success(
          data: parsedData,
          message: message,
          statusCode: statusCode,
        );
      } catch (e) {
        return CompatibilityResponse<T>.error(
          message: 'Error al parsear datos: $e',
          statusCode: statusCode,
        );
      }
    } else {
      return CompatibilityResponse<T>.success(
        data: extractedData as T,
        message: message,
        statusCode: statusCode,
      );
    }
  }

  /// Manejar respuesta de error
  CompatibilityResponse<T> _handleErrorResponse<T>(
    dynamic data,
    int statusCode,
  ) {
    final normalizedData = _normalizeData(data);
    final message = _extractErrorMessage(normalizedData, statusCode);
    final errors = _extractErrors(normalizedData);
    
    return CompatibilityResponse<T>.error(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Normalizar datos a camelCase
  dynamic _normalizeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _caseConverter.convertMapToCamelCase(data);
    } else if (data is List) {
      return data.map((item) => _normalizeData(item)).toList();
    }
    return data;
  }

  /// Extraer datos según diferentes formatos de respuesta
  dynamic _extractData(Map<String, dynamic> data) {
    // Formato 1: { data: {...} }
    if (data.containsKey('data')) {
      return data['data'];
    }
    
    // Formato 2: { result: {...} }
    if (data.containsKey('result')) {
      return data['result'];
    }
    
    // Formato 3: { items: [...] } (para listas)
    if (data.containsKey('items')) {
      return data['items'];
    }
    
    // Formato 4: { results: [...] } (para listas)
    if (data.containsKey('results')) {
      return data['results'];
    }
    
    // Formato 5: Respuesta directa
    return data;
  }

  /// Extraer mensaje de la respuesta
  String _extractMessage(Map<String, dynamic> data) {
    return data['message'] ?? 
           data['msg'] ?? 
           data['description'] ?? 
           'Operación exitosa';
  }

  /// Extraer mensaje de error
  String _extractErrorMessage(Map<String, dynamic> data, int statusCode) {
    // Intentar obtener mensaje de diferentes ubicaciones
    String? message = data['message'] ?? 
                     data['error'] ?? 
                     data['msg'] ??
                     data['description'] ??
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

  /// Extraer errores de validación
  Map<String, dynamic>? _extractErrors(Map<String, dynamic> data) {
    if (data.containsKey('errors')) {
      return data['errors'];
    }
    
    if (data.containsKey('validation_errors')) {
      return data['validation_errors'];
    }
    
    return null;
  }

  /// Adaptar respuesta paginada
  PaginatedResponse<T> adaptPaginatedResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final compatibilityResponse = adaptResponse<List<T>>(
      response,
      (data) => (data as List).map((item) => fromJson(item)).toList(),
    );
    
    if (!compatibilityResponse.success) {
      return PaginatedResponse<T>.error(
        message: compatibilityResponse.message,
        statusCode: compatibilityResponse.statusCode,
      );
    }
    
    // Extraer metadatos de paginación
    final data = jsonDecode(response.body);
    final normalizedData = _normalizeData(data);
    
    return PaginatedResponse<T>.success(
      data: compatibilityResponse.data!,
      currentPage: _extractCurrentPage(normalizedData),
      totalPages: _extractTotalPages(normalizedData),
      totalItems: _extractTotalItems(normalizedData),
      perPage: _extractPerPage(normalizedData),
      hasNextPage: _extractHasNextPage(normalizedData),
      hasPreviousPage: _extractHasPreviousPage(normalizedData),
      message: compatibilityResponse.message,
      statusCode: compatibilityResponse.statusCode,
    );
  }

  /// Extraer página actual
  int _extractCurrentPage(Map<String, dynamic> data) {
    return data['current_page'] ?? 
           data['page'] ?? 
           data['currentPage'] ?? 
           1;
  }

  /// Extraer total de páginas
  int _extractTotalPages(Map<String, dynamic> data) {
    return data['last_page'] ?? 
           data['total_pages'] ?? 
           data['totalPages'] ?? 
           1;
  }

  /// Extraer total de elementos
  int _extractTotalItems(Map<String, dynamic> data) {
    return data['total'] ?? 
           data['total_items'] ?? 
           data['totalItems'] ?? 
           0;
  }

  /// Extraer elementos por página
  int _extractPerPage(Map<String, dynamic> data) {
    return data['per_page'] ?? 
           data['perPage'] ?? 
           data['limit'] ?? 
           20;
  }

  /// Extraer si hay página siguiente
  bool _extractHasNextPage(Map<String, dynamic> data) {
    return data['has_next_page'] ?? 
           data['hasNextPage'] ?? 
           data['next_page_url'] != null;
  }

  /// Extraer si hay página anterior
  bool _extractHasPreviousPage(Map<String, dynamic> data) {
    return data['has_previous_page'] ?? 
           data['hasPreviousPage'] ?? 
           data['prev_page_url'] != null;
  }
}

/// Respuesta de compatibilidad tipada
class CompatibilityResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  CompatibilityResponse._({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory CompatibilityResponse.success({
    required T data,
    required String message,
    int? statusCode,
  }) {
    return CompatibilityResponse._(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory CompatibilityResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return CompatibilityResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

/// Respuesta paginada
class PaginatedResponse<T> {
  final bool success;
  final List<T>? data;
  final String message;
  final int? statusCode;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse._({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.success({
    required List<T> data,
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required int perPage,
    required bool hasNextPage,
    required bool hasPreviousPage,
    required String message,
    int? statusCode,
  }) {
    return PaginatedResponse._(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: perPage,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  factory PaginatedResponse.error({
    required String message,
    int? statusCode,
  }) {
    return PaginatedResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      perPage: 20,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }
}
