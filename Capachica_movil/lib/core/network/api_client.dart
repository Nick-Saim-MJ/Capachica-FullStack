import 'package:aplicativo_capachica/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import '../constants/api_constants.dart';
import 'package:http/http.dart' as http; // Add this import
// 1. Clase de Excepción Personalizada
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  late final Dio _dio;
  final AppSecureStorage _secureStorage;
  late final String _baseUrl;

  ApiClient(this._secureStorage, {String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 30000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 1. Interceptor para Autenticación, Logs básicos y Manejo de Errores
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lógica de Autenticación: Añadir token a menos que se use un header para omitirlo (no implementado aquí)
          final token = await _secureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
            print('ERROR MESSAGE: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ));
    }
  }

  // --- MÉTODOS DE PETICIÓN ---

  // GET request
  Future<Response<dynamic>> get( // <-- CAMBIO CLAVE: Agregando <dynamic>
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<Response<dynamic>> post( // <-- CAMBIO CLAVE: Agregando <dynamic>
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  // DELETE request
  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST Multipart Request
  Future<Response> postMultipart(
      String path,
      FormData data,
      {Options? options}
      ) async {
    try {
      // Configuramos el Content-Type para asegurar el manejo correcto de multipart/form-data.
      final newOptions = (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      );

      return await _dio.post(
        path,
        data: data,
        options: newOptions,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }


  // --- MANEJO DE ERRORES ---
  Exception _handleDioError(DioException error) {
    String message;
    final statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Tiempo de conexión agotado. Verifica tu conexión a internet.';
        // Código 0 para errores de red/timeout
        return ApiException(0, message);
      case DioExceptionType.connectionError:
        message = 'Sin conexión a internet. Verifica tu conectividad.';
        return ApiException(0, message);
      case DioExceptionType.cancel:
        message = 'Solicitud cancelada.';
        return ApiException(0, message);
      case DioExceptionType.badResponse:
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              message = 'Solicitud incorrecta. Verifica los datos enviados.';
              break;
            case 401:
              message = 'No autorizado. Inicia sesión nuevamente.';
              break;
            case 403:
              message = 'Acceso denegado. No tienes permisos para esta acción.';
              break;
            case 404:
              message = 'Recurso no encontrado.';
              break;
            case 422:
              final responseData = error.response?.data;
              if (responseData is Map && responseData.containsKey('message')) {
                message = responseData['message'].toString();
              } else {
                message = 'Error de validación en los datos enviados.';
              }
              break;
            case 500:
              message = 'Error interno del servidor. Intenta más tarde.';
              break;
            default:
              message = 'Error del servidor (${statusCode}). Intenta más tarde.';
          }
        } else {
          message = 'Error de respuesta del servidor.';
        }// Devolvemos ApiException con el código de estado real
        return ApiException(statusCode ?? 500, message);
      case DioExceptionType.badCertificate:
        message = 'Certificado SSL inválido.';
        return ApiException(0, message);
      case DioExceptionType.unknown:
      default:
        message = 'Error desconocido: ${error.message ?? 'Ha ocurrido un error inesperado. Inténtalo de nuevo.'}';
        return ApiException(0, message);
    }
  }

  Future<Response<dynamic>> putMultipart( // <--- Retorno consistente
      String path,
      Map<String, dynamic> body, {
        String? filePath,
        String fileKey = 'foto_perfil',
        Options? options,
      }) async {
    try {
      final formData = FormData.fromMap(body);
      formData.fields.add(MapEntry('_method', 'PUT'));
      if (filePath != null) {
        formData.files.add(
          MapEntry(
            fileKey,
            await MultipartFile.fromFile(filePath),
          ),
        );
      }

      final newOptions = (options ?? Options()).copyWith(
        contentType: 'multipart/form-data',
      );

      // Usar _dio.put
      return await _dio.post(
        path,
        data: formData,
        options: newOptions,
      );
    } on DioException catch (e) {
      throw _handleDioError(e); // <--- Usa el manejo de errores de Dio
    }
  }
}
