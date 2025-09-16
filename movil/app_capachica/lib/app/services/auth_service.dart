// lib/app/services/auth_service.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/models/login_model.dart';
import '../core/config/app_config.dart';
import '../core/http/http_client.dart';
import '../core/services/base_service.dart';

/// Servicio de autenticación unificado sobre AppHttpClient
class AuthService extends BaseService {
  final _storage = GetStorage();
  final _httpClient = AppHttpClient.instance;

  /// Estado
  final currentUser = Rxn<User>();
  final token = Rxn<String>();
  final isLoggedInRx = false.obs;

  bool get isLoggedIn => token.value != null;
  bool get isAuthenticated => currentUser.value != null;

  /// URL actual del cliente (debug)
  String get baseUrl => _httpClient.baseUrl;

  @override
  void onInit() {
    super.onInit();
    ever(token, (_) => isLoggedInRx.value = token.value != null);
    isLoggedInRx.value = token.value != null;
  }

  /// Inicializa leyendo storage y cliente HTTP
  Future<AuthService> init() async {
    await _httpClient.init();

    final storedToken = _storage.read<String>('token');
    if (storedToken != null && storedToken.isNotEmpty) {
      token.value = storedToken;
    }

    final userJson = _storage.read('user');
    if (userJson is Map<String, dynamic>) {
      currentUser.value = User.fromJson(userJson);
    }
    return this;
  }

  // -----------------------------
  // Autenticación
  // -----------------------------

  /// POST /auth/register
  Future<AuthResponse> register(RegisterRequest request) async {
    final result = await executeWithStates<AuthResponse>(() async {
      // Modo prueba
      if (AppConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        final fake = AuthResponse(
          token: 'test_token_register',
          message: 'Registro exitoso',
          user: User(id: 1, name: request.name, email: request.email),
          success: true,
        );
        await _saveAuthData(fake);
        return fake;
      }

      final resp = await _httpClient.post<AuthResponse>(
        AppConfig.getEndpoint('auth', 'register'),
        // RegisterRequest no tiene toJson() -> usamos toMap()
        body: request.toMap(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (resp.success && resp.data != null) {
        final auth = resp.data!;
        if (auth.token != null) await _saveAuthData(auth);
        return auth;
      }
      throw resp.message;
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  /// POST /auth/login
  Future<AuthResponse> login(String email, String password) async {
    final result = await executeWithStates<AuthResponse>(() async {
      if (AppConfig.isTestMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        final fake = AuthResponse(
          token: 'test_token_login',
          message: 'Login exitoso para $email',
          user: User(id: 1, name: 'Usuario Prueba', email: email),
          success: true,
        );
        await _saveAuthData(fake);
        return fake;
      }

      final req = LoginRequest(email: email, password: password);
      final resp = await _httpClient.post<AuthResponse>(
        AppConfig.getEndpoint('auth', 'login'),
        body: req.toJson(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (resp.success && resp.data != null) {
        final auth = resp.data!;
        if (auth.token != null) await _saveAuthData(auth);
        return auth;
      }
      throw resp.message;
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  /// POST /auth/logout
  Future<void> logout() async {
    try {
      final resp = await _httpClient.post(
        AppConfig.getEndpoint('auth', 'logout'),
      );
      // Limpia local siempre, incluso si el backend falla
      await _clearAuthData();
      if (!resp.success) {
        // ignore: avoid_print
        print('Logout request failed: ${resp.message}');
      }
    } catch (_) {
      await _clearAuthData();
    }
  }

  // -----------------------------
  // Recuperación / verificación
  // -----------------------------

  /// POST /auth/forgot-password
  Future<AuthResponse> forgotPassword(String email) async {
    final result = await executeWithStates<AuthResponse>(() async {
      final req = ForgotPasswordRequest(email: email);
      final resp = await _httpClient.post<AuthResponse>(
        AppConfig.getEndpoint('auth', 'forgotPassword'),
        body: req.toJson(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (resp.success && resp.data != null) return resp.data!;
      throw resp.message;
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  /// POST /auth/reset-password
  Future<AuthResponse> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String token,
  }) async {
    final result = await executeWithStates<AuthResponse>(() async {
      final req = ResetPasswordRequest(
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        token: token,
      );
      final resp = await _httpClient.post<AuthResponse>(
        AppConfig.getEndpoint('auth', 'resetPassword'),
        body: req.toJson(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (resp.success && resp.data != null) return resp.data!;
      throw resp.message;
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  /// GET /auth/email/verify/{id}/{hash}
  Future<AuthResponse> verifyEmail(String id, String hash) async {
    final result = await executeWithStates<AuthResponse>(() async {
      final url = '${AppConfig.getEndpoint('auth', 'verifyEmail')}/$id/$hash';

      final resp = await _httpClient.get<AuthResponse>(
        url,
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (resp.success && resp.data != null) return resp.data!;
      throw resp.message;
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  /// POST /auth/email/verification-notification
  Future<AuthResponse> resendVerification() async {
    final result = await executeWithStates<AuthResponse>(() async {
      final resp = await _httpClient.post<AuthResponse>(
        AppConfig.getEndpoint('auth', 'resendVerification'),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (resp.success && resp.data != null) return resp.data!;
      throw resp.message;
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  /// Guardar credenciales en storage y estado
  Future<void> _saveAuthData(AuthResponse auth) async {
    token.value = auth.token;
    currentUser.value = auth.user;
    if (auth.token != null) await _storage.write('token', auth.token);
    if (auth.user != null) await _storage.write('user', auth.user!.toJson());
  }

  /// Limpiar credenciales
  Future<void> _clearAuthData() async {
    token.value = null;
    currentUser.value = null;
    await _storage.remove('token');
    await _storage.remove('user');
  }

  // -----------------------------
  // Google (usa LoginResponse ya parseado)
  // -----------------------------
  Future<void> loginWithGoogleResponse(LoginResponse loginResponse) async {
    if (loginResponse.token == null) {
      throw 'No se recibió token de sesión del servidor';
    }
    await _saveAuthData(AuthResponse(
      token: loginResponse.token,
      message: loginResponse.message,
      user: loginResponse.user,
      success: true,
    ));
  }
}