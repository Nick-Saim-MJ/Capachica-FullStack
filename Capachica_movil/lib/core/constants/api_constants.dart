// lib/core/constants/api_constants.dart
import 'package:aplicativo_capachica/core/config/backend_config.dart';

class ApiConstants {
  static const String baseUrl = BackendConfig.baseUrl;
  static const bool isDevelopment = true; // Cambiar según el entorno

  // Endpoints
  static const String eventos = '/eventos';
  static const String emprendedores = '/emprendedores';
  static const String sliders = '/sliders';

  // Configuración
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;
}

// lib/core/utils/result.dart
abstract class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.error(String message) = Error<T>;

  R fold<R>(
      R Function(String error) onError,
      R Function(T data) onSuccess,
      ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onError((this as Error<T>).message);
    }
  }

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Success && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;
}

class Error<T> extends Result<T> {
  final String message;
  const Error(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Error && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}