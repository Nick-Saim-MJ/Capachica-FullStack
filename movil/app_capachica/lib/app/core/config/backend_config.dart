import 'dart:io';
import 'package:flutter/foundation.dart';

class BackendConfig {
  /// IP local de tu PC en la red Wi-Fi/LAN
  static const String localNetworkIP = '172.22.13.34'; // Cambia según tu red

  /// Timeout para peticiones HTTP
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  /// Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Modo de prueba local
  static const bool testMode = false;

  /// Respuesta simulada para login
  static const Map<String, dynamic> testLoginResponse = {
    'token': 'test_token_123456789',
    'message': 'Login exitoso',
    'user': {
      'id': 1,
      'name': 'Usuario de Prueba',
      'email': 'test@example.com'
    },
    'success': true
  };

  /// Simulación de URL de login con Google
  static const Map<String, dynamic> testGoogleAuthUrl = {
    'data': {
      'url':
      'https://accounts.google.com/o/oauth2/auth?client_id=test&redirect_uri=test&response_type=code&scope=email%20profile'
    },
    'success': true
  };

  /// Detecta automáticamente la mejor URL para conectar con el backend
  static String getBaseUrl() {
    if (testMode) {
      return 'http://localhost:8000/api';
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    if (Platform.isAndroid) {
      // Emulador Android usa 10.0.2.2
      // Dispositivo físico usa la IP local de la PC
      return _isRunningOnEmulator()
          ? 'http://10.0.2.2:8000/api'
          : 'http://$localNetworkIP:8000/api';
    }

    if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'http://localhost:8000/api';
    }

    // Fallback general
    return 'http://$localNetworkIP:8000/api';
  }

  /// Detecta si se está ejecutando en un emulador Android
  static bool _isRunningOnEmulator() {
    final env = Platform.environment;
    // Algunas variables de entorno indican emulador
    return env.containsKey('ANDROID_EMULATOR') || env.containsKey('EMULATOR_DEVICE');
  }

  /// Indica si estamos en modo debug
  static bool isDebugMode() => kDebugMode;
}
