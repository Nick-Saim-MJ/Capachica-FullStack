import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/login_model.dart';
import '../core/config/backend_config.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  static String _baseUrl = BackendConfig.defaultBaseUrl;
  
  final currentUser = Rxn<User>();
  final token = Rxn<String>();
  final isLoggedInRx = false.obs;

  bool get isLoggedIn => token.value != null;
  bool get isAuthenticated => currentUser.value != null;
  
  // Getter para obtener la URL actual
  String get baseUrl => _baseUrl;
  
  // Método para cambiar la URL del backend
  void setBaseUrl(String url) {
    _baseUrl = url;
    print('[AuthService] URL del backend cambiada a: $_baseUrl');
  }

  @override
  void onInit() {
    super.onInit();
    ever(token, (_) {
      isLoggedInRx.value = token.value != null;
    });
    isLoggedInRx.value = token.value != null;
  }

  Future<AuthService> init() async {
    token.value = _storage.read('token');
    final userJson = _storage.read<Map<String, dynamic>>('user');
    if (userJson != null) {
      currentUser.value = User.fromJson(userJson);
    }
    return this;
  }

  // POST /api/register
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toMap()),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(responseData);
        if (authResponse.success && authResponse.token != null) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      } else {
        throw _handleErrorResponse(responseData, response.statusCode);
      }
    } catch (e) {
      if (e is FormatException) {
        throw 'Error de formato en la respuesta del servidor';
      }
      rethrow;
    }
  }

  // POST /api/login
  Future<AuthResponse> login(String email, String password) async {
    print('[AuthService] Iniciando login para: $email');
    print('[AuthService] URL del backend: $_baseUrl/login');
    
    // Modo de prueba - simular respuesta del backend
    if (BackendConfig.testMode) {
      print('[AuthService] Usando modo de prueba - simulando respuesta del backend');
      await Future.delayed(Duration(seconds: 2)); // Simular delay de red
      
      final testResponse = Map<String, dynamic>.from(BackendConfig.testLoginResponse);
      testResponse['user'] = {
        'id': 1,
        'name': 'Usuario de Prueba',
        'email': email
      };
      testResponse['message'] = 'Login exitoso para $email';
      
      print('[AuthService] Respuesta de prueba: $testResponse');
      
      final authResponse = AuthResponse.fromJson(testResponse);
      if (authResponse.token != null) {
        await _saveAuthData(authResponse);
      }
      return authResponse;
    }
    
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final requestBody = jsonEncode(loginRequest.toJson());
      print('[AuthService] Request body: $requestBody');
      
      print('[AuthService] Enviando petición HTTP...');
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: BackendConfig.defaultHeaders,
        body: requestBody,
      ).timeout(
        BackendConfig.requestTimeout,
        onTimeout: () {
          print('[AuthService] Timeout en la petición HTTP');
          throw 'Timeout: La petición tardó demasiado en responder';
        },
      );

      print('[AuthService] Respuesta recibida - Status: ${response.statusCode}');
      print('[AuthService] Response body: ${response.body}');
      
      if (response.body.isEmpty) {
        print('[AuthService] Error: Respuesta vacía del servidor');
        throw 'Error: El servidor no respondió con datos';
      }

      final responseData = jsonDecode(response.body);
      print('[AuthService] Response data decodificado: $responseData');
      
      if (response.statusCode == 200) {
        print('[AuthService] Status 200 - Procesando respuesta exitosa');
        final authResponse = AuthResponse.fromJson(responseData);
        print('[AuthService] AuthResponse creado: ${authResponse.toJson()}');
        
        if (authResponse.token != null) {
          print('[AuthService] Token encontrado, guardando datos de autenticación');
          await _saveAuthData(authResponse);
          print('[AuthService] Datos de autenticación guardados exitosamente');
        } else {
          print('[AuthService] Warning: No se recibió token en la respuesta');
        }
        return authResponse;
      } else {
        print('[AuthService] Error HTTP ${response.statusCode}');
        final errorMessage = _handleErrorResponse(responseData, response.statusCode);
        print('[AuthService] Error message: $errorMessage');
        throw errorMessage;
      }
    } catch (e) {
      print('[AuthService] Excepción capturada: $e');
      if (e is FormatException) {
        print('[AuthService] Error de formato JSON: $e');
        throw 'Error de formato en la respuesta del servidor: $e';
      }
      if (e.toString().contains('SocketException')) {
        print('[AuthService] Error de conexión: $e');
        throw 'Error de conexión: No se pudo conectar con el servidor. Verifica que el backend esté ejecutándose en http://127.0.0.1:8000';
      }
      rethrow;
    }
  }

  // POST /api/logout
  Future<void> logout() async {
    try {
      final currentToken = token.value;
      if (currentToken == null) {
        await _clearAuthData();
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      // Siempre limpiar los datos locales, independientemente de la respuesta del servidor
      await _clearAuthData();
      
      if (response.statusCode != 200) {
        print('Warning: Logout request failed with status ${response.statusCode}');
      }
    } catch (e) {
      // Aún limpiar los datos locales en caso de error
      await _clearAuthData();
      print('Error during logout: $e');
    }
  }

  // POST /api/forgot-password
  Future<AuthResponse> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        throw _handleErrorResponse(responseData, response.statusCode);
      }
    } catch (e) {
      if (e is FormatException) {
        throw 'Error de formato en la respuesta del servidor';
      }
      rethrow;
    }
  }

  // POST /api/reset-password
  Future<AuthResponse> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String token,
  }) async {
    try {
      final request = ResetPasswordRequest(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        token: token,
      );
      
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        throw _handleErrorResponse(responseData, response.statusCode);
      }
    } catch (e) {
      if (e is FormatException) {
        throw 'Error de formato en la respuesta del servidor';
      }
      rethrow;
    }
  }

  // GET /api/email/verify/{id}/{hash}
  Future<AuthResponse> verifyEmail(String id, String hash) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/email/verify/$id/$hash'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        throw _handleErrorResponse(responseData, response.statusCode);
      }
    } catch (e) {
      if (e is FormatException) {
        throw 'Error de formato en la respuesta del servidor';
      }
      rethrow;
    }
  }

  // POST /api/email/verification-notification
  Future<AuthResponse> sendEmailVerification() async {
    try {
      final currentToken = token.value;
      if (currentToken == null) {
        throw 'No hay token de autenticación disponible';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/email/verification-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        throw _handleErrorResponse(responseData, response.statusCode);
      }
    } catch (e) {
      if (e is FormatException) {
        throw 'Error de formato en la respuesta del servidor';
      }
      rethrow;
    }
  }

  // Método para manejar login con Google usando LoginResponse existente
  Future<void> loginWithGoogleResponse(LoginResponse loginResponse) async {
    if (loginResponse.token != null) {
      await _saveAuthData(AuthResponse(
        token: loginResponse.token,
        message: loginResponse.message,
        user: loginResponse.user,
        success: true,
      ));
    } else {
      throw 'No se recibió token de sesión del servidor';
    }
  }

  // Métodos auxiliares privados
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    token.value = authResponse.token;
    currentUser.value = authResponse.user;
    await _storage.write('token', authResponse.token);
    if (authResponse.user != null) {
      await _storage.write('user', authResponse.user!.toJson());
    }
  }

  Future<void> _clearAuthData() async {
    token.value = null;
    currentUser.value = null;
    await _storage.remove('token');
    await _storage.remove('user');
  }

  String _handleErrorResponse(Map<String, dynamic> responseData, int statusCode) {
    if (responseData['message'] != null && responseData['errors'] == null) {
      return responseData['message'];
    }

    if (responseData['errors'] != null) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        // Concatenar todos los mensajes de error de todos los campos
        final allMessages = errors.values
            .expand((e) => e is List ? e : [e])
            .join('\n');
        return allMessages;
      }
    }

    switch (statusCode) {
      case 401:
        return 'Credenciales inválidas';
      case 422:
        return 'Datos de entrada inválidos';
      case 500:
        return 'Error interno del servidor';
      default:
        return 'Error de conexión (Código: $statusCode)';
    }
  }

  // Método para probar diferentes formatos de respuesta
  Future<void> testResponseFormats() async {
    print('[AuthService] Probando diferentes formatos de respuesta...');
    
    // Formato 1: Respuesta directa
    final response1 = {
      'token': 'test_token_123',
      'message': 'Login exitoso',
      'user': {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com'
      },
      'success': true
    };
    
    // Formato 2: Respuesta con data wrapper
    final response2 = {
      'data': {
        'token': 'test_token_456',
        'message': 'Login exitoso',
        'user': {
          'id': 2,
          'name': 'Test User 2',
          'email': 'test2@example.com'
        }
      },
      'success': true
    };
    
    // Formato 3: Respuesta con access_token
    final response3 = {
      'access_token': 'test_token_789',
      'message': 'Login exitoso',
      'user': {
        'id': 3,
        'name': 'Test User 3',
        'email': 'test3@example.com'
      }
    };
    
    try {
      print('[AuthService] Probando formato 1...');
      final auth1 = AuthResponse.fromJson(response1);
      print('[AuthService] Formato 1 - Token: ${auth1.token}, Success: ${auth1.success}');
      
      print('[AuthService] Probando formato 2...');
      final auth2 = AuthResponse.fromJson(response2);
      print('[AuthService] Formato 2 - Token: ${auth2.token}, Success: ${auth2.success}');
      
      print('[AuthService] Probando formato 3...');
      final auth3 = AuthResponse.fromJson(response3);
      print('[AuthService] Formato 3 - Token: ${auth3.token}, Success: ${auth3.success}');
      
    } catch (e) {
      print('[AuthService] Error en test de formatos: $e');
    }
  }

  // Método para probar la conectividad con el backend
  Future<bool> testConnection() async {
    print('[AuthService] Probando conectividad con el backend...');
    
    // Modo de prueba - simular conectividad exitosa
    if (BackendConfig.testMode) {
      print('[AuthService] Modo de prueba activado - simulando conectividad exitosa');
      return true;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(BackendConfig.connectionTimeout);
      
      print('[AuthService] Test de conectividad - Status: ${response.statusCode}');
      print('[AuthService] Test de conectividad - Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('[AuthService] Error en test de conectividad: $e');
      return false;
    }
  }

  // Método para probar diferentes URLs del backend
  Future<String?> findBackendUrl() async {
    print('[AuthService] Buscando URL del backend...');
    
    // Modo de prueba - simular que encontramos el backend
    if (BackendConfig.testMode) {
      print('[AuthService] Modo de prueba activado - simulando backend encontrado');
      setBaseUrl('http://127.0.0.1:8000/api');
      return 'http://127.0.0.1:8000/api';
    }
    
    for (final url in BackendConfig.possibleUrls) {
      print('[AuthService] Probando URL: $url');
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: BackendConfig.defaultHeaders,
        ).timeout(BackendConfig.connectionTimeout);
        
        print('[AuthService] Respuesta de $url - Status: ${response.statusCode}');
        
        if (response.statusCode == 200 || response.statusCode == 404) {
          print('[AuthService] URL encontrada: $url');
          setBaseUrl(url);
          return url;
        }
      } catch (e) {
        print('[AuthService] Error con $url: $e');
      }
    }
    
    print('[AuthService] No se encontró ninguna URL válida');
    return null;
  }

  // Método para probar el endpoint de Google específicamente
  Future<bool> testGoogleEndpoint() async {
    print('[AuthService] Probando endpoint de Google...');
    
    // Modo de prueba - simular endpoint disponible
    if (BackendConfig.testMode) {
      print('[AuthService] Modo de prueba activado - simulando endpoint de Google disponible');
      return true;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/google'),
        headers: BackendConfig.defaultHeaders,
      ).timeout(BackendConfig.connectionTimeout);
      
      print('[AuthService] Respuesta del endpoint Google - Status: ${response.statusCode}');
      print('[AuthService] Respuesta del endpoint Google - Body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('[AuthService] Error en endpoint Google: $e');
      return false;
    }
  }
} 