class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

class NetworkException implements Exception {
  final String message;
  final String? originalError;

  NetworkException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() {
    return 'NetworkException: $message';
  }
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException({this.message = 'La petición ha excedido el tiempo de espera'});

  @override
  String toString() {
    return 'TimeoutException: $message';
  }
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({this.message = 'No autorizado'});

  @override
  String toString() {
    return 'UnauthorizedException: $message';
  }
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException({this.message = 'Recurso no encontrado'});

  @override
  String toString() {
    return 'NotFoundException: $message';
  }
} 