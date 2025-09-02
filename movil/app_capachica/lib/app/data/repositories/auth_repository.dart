import 'package:get/get.dart';
import '../models/login_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  Future<LoginResponse> login(String email, String password) async {
    print('[AuthRepository] Intentando iniciar sesión para: $email');
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await _authProvider.login(loginRequest);

      if (response.status.hasError) {
        print('[AuthRepository] Error de estado HTTP detectado: ${response.statusText}');
        String errorMessage = response.statusText ?? 'Error desconocido';
        if (response.body?.message != null && response.body!.message!.isNotEmpty) {
          errorMessage = response.body!.message!;
        }
        throw errorMessage;
      }

      final loginResponse = response.body;
      if (loginResponse?.token == null) {
        print('[AuthRepository] Error: La respuesta decodificada no contiene un token.');
        throw 'La respuesta del API no incluyó un token.';
      }

      print('[AuthRepository] Login exitoso. Token recibido.');
      return loginResponse!;
    } catch (e) {
      print('[AuthRepository] Excepción capturada durante el login: $e');
      // Re-lanzar la excepción para que sea manejada por el controlador.
      rethrow;
    }
  }

  Future<void> register(FormData formData) async {
    try {
      final response = await _authProvider.register(formData);

      if (response.status.hasError) {
        String errorMessage = 'Error desconocido';
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        } else {
          errorMessage = response.statusText ?? errorMessage;
        }
        throw errorMessage;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginResponse> loginWithGoogle(String googleToken) async {
    print('[AuthRepository] Intentando iniciar sesión con token de Google.');
    try {
      final response = await _authProvider.verifyGoogleToken(googleToken);

      if (response.status.hasError) {
        print('[AuthRepository] Error de estado HTTP en login con Google: ${response.statusText}');
        String errorMessage = response.body?.message ?? response.statusText ?? 'Error desconocido';
        throw errorMessage;
      }
      
      final loginResponse = response.body;
      if (loginResponse?.token == null) {
        print('[AuthRepository] Error: La respuesta de Google no incluyó un token de la app.');
        throw 'La respuesta del API no incluyó un token de sesión.';
      }

      print('[AuthRepository] Login con Google exitoso. Token de la app recibido.');
      return loginResponse!;
    } catch (e) {
      print('[AuthRepository] Excepción capturada durante el login con Google: $e');
      rethrow;
    }
  }
}