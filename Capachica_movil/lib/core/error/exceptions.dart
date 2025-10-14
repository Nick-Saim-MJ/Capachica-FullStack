class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}

class NotFoundException implements Exception {}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

/// 🔹 Excepción principal para errores de API
/// Permite capturar el mensaje y el código de estado HTTP
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException ($statusCode): $message';
}

//Conservado por temas de compatibilidad
class DataException implements Exception {
  final String message;
  final int? statusCode;

  /// Excepción lanzada por la capa de Data/Repository para indicar un fallo
  /// al obtener, enviar o procesar datos (ej: red, serialización, BD local).
  DataException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'DataException: [$statusCode] $message';
    }
    return 'DataException: $message';
  }
}