import 'dart:io';
import 'package:flutter/foundation.dart';

class BackendConfig {
  /// Dirección IP local de tu PC en la red Wi-Fi
  static const String localNetworkIP = '172.22.13.34'; // Cambia según tu red

  /// URL por defecto para uso en otros archivos
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api';

  /// Lista de posibles URLs si necesitas probar conexiones
  static const List<String> possibleUrls = [
    'http://10.0.2.2:8000/api', // Emulador Android
    'http://localhost:8000/api', // Web y escritorio
    'http://127.0.0.1:8000/api', // Alternativa local
    'http://172.22.13.34:8000/api', // IP LAN (dispositivo físico)
  ];

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
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Para emulador Android
    }

    if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'http://localhost:8000/api'; // Escritorio o simulador
    }

    // Fallback para dispositivos reales (Android/iOS)
    return 'http://$localNetworkIP:8000/api';
  }

  /// Indica si estamos en modo debug
  static bool isDebugMode() {
    return kDebugMode;
  }
}
