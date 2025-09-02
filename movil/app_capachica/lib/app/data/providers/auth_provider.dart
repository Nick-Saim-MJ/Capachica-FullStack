import 'package:get/get.dart';
import '../models/login_model.dart';
import '../../core/config/backend_config.dart';
import 'dart:convert';

class AuthProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = BackendConfig.defaultBaseUrl;
    httpClient.timeout = BackendConfig.requestTimeout;

    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      return request;
    });
  }

  // Método para cambiar la URL base dinámicamente
  void setBaseUrl(String url) {
    httpClient.baseUrl = url;
    print('[AuthProvider] URL base cambiada a: $url');
  }

  Future<Response<LoginResponse>> login(LoginRequest loginRequest) async {
    print('[AuthProvider] Iniciando petición POST a /login');
    final response = await post<LoginResponse>(
      '/login',
      loginRequest.toJson(),
      decoder: (data) {
        print('[AuthProvider] Decodificando respuesta del login: $data');
        return LoginResponse.fromJson(data);
      },
    );
    print('[AuthProvider] Respuesta recibida del servidor con Status: ${response.statusCode}');
    print('[AuthProvider] Cuerpo de la respuesta: ${response.bodyString}');
    return response;
  }

  Future<Response> register(FormData formData) async {
    return await post(
      '/register',
      formData,
    );
  }

  Future<Response> getGoogleSignInUrl() async {
    print('[AuthProvider] Obteniendo URL de autenticación de Google...');
    print('[AuthProvider] URL base actual: ${httpClient.baseUrl}');
    
    // Modo de prueba - simular respuesta del backend
    if (BackendConfig.testMode) {
      print('[AuthProvider] Modo de prueba activado - simulando URL de Google');
      await Future.delayed(Duration(seconds: 1)); // Simular delay de red
      
      return Response(
        statusCode: 200,
        body: BackendConfig.testGoogleAuthUrl,
        bodyString: jsonEncode(BackendConfig.testGoogleAuthUrl),
      );
    }
    
    try {
      final response = await get('/auth/google').timeout(
        BackendConfig.requestTimeout,
        onTimeout: () {
          print('[AuthProvider] Timeout al obtener URL de Google');
          throw 'Timeout: La petición tardó demasiado en responder';
        },
      );
      
      print('[AuthProvider] Respuesta de Google auth - Status: ${response.statusCode}');
      print('[AuthProvider] Respuesta de Google auth - Body: ${response.bodyString}');
      
      if (response.statusCode == 200) {
        return response;
      } else {
        print('[AuthProvider] Error HTTP ${response.statusCode} al obtener URL de Google');
        throw 'Error del servidor: ${response.statusCode}';
      }
    } catch (e) {
      print('[AuthProvider] Excepción al obtener URL de Google: $e');
      rethrow;
    }
  }

  Future<Response<LoginResponse>> verifyGoogleToken(String token) async {
    print('[AuthProvider] Iniciando petición GET a /auth/google con token');
    final response = await get<LoginResponse>(
      '/auth/google?token=$token',
      decoder: (data) {
        print('[AuthProvider] Decodificando respuesta de Google auth: $data');
        return LoginResponse.fromJson(data);
      },
    );
    print('[AuthProvider] Respuesta recibida del servidor con Status: ${response.statusCode}');
    print('[AuthProvider] Cuerpo de la respuesta: ${response.bodyString}');
    return response;
  }
}