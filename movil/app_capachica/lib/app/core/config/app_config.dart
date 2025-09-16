import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// Configuración centralizada de la aplicación
class AppConfig {
  AppConfig._();

  /// Configuración por flavor/entorno
  static const String _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'development');

  /// URLs base por entorno
  static const Map<String, String> _baseUrls = {
    'development': 'http://127.0.0.1:8000/api',
    'staging': 'http://staging-api.capachica.com/api',
    'production': 'https://api.capachica.com/api',
  };

  /// URLs para diferentes plataformas en desarrollo
  static const Map<String, String> _devPlatformUrls = {
    'android_emulator': 'http://10.0.2.2:8000/api',
    'ios_simulator': 'http://localhost:8000/api',
    'web': 'http://localhost:8000/api',
    'desktop': 'http://localhost:8000/api',
    'device': 'http://172.22.13.34:8000/api', // IP local de red
  };

  /// Obtener URL base según el entorno y plataforma
  static String get baseUrl {
    if (_flavor == 'development') {
      return _getDevelopmentUrl();
    }
    return _baseUrls[_flavor] ?? _baseUrls['development']!;
  }

  /// Obtener URL para desarrollo según plataforma
  static String _getDevelopmentUrl() {
    if (kIsWeb) return _devPlatformUrls['web']!;

    if (Platform.isAndroid) {
      // Emulador vs dispositivo físico
      return _isEmulator()
          ? _devPlatformUrls['android_emulator']!
          : _devPlatformUrls['device']!;
    }

    if (Platform.isIOS) {
      return _isSimulator()
          ? _devPlatformUrls['ios_simulator']!
          : _devPlatformUrls['device']!;
    }

    // Desktop (Windows, macOS, Linux)
    return _devPlatformUrls['desktop']!;
  }

  /// Detectar si está ejecutándose en emulador Android
  static bool _isEmulator() {
    try {
      final root = Platform.environment['ANDROID_ROOT'];
      return root != null && root.contains('sdk');
    } catch (_) {
      return false;
    }
  }

  /// Detectar si está ejecutándose en simulador iOS
  static bool _isSimulator() {
    try {
      return Platform.environment['SIMULATOR_DEVICE_NAME'] != null;
    } catch (_) {
      return false;
    }
  }

  /// Timeouts de red
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  /// Configuración de cache
  static const Duration cacheTTL = Duration(minutes: 15);
  static const Duration shortCacheTTL = Duration(minutes: 5);

  /// Configuración de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Configuración de reintentos
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  /// Modo de prueba (para desarrollo)
  static bool get isTestMode => _flavor == 'development' && kDebugMode;

  /// Configuración de logging
  static bool get enableLogging => _flavor != 'production' || kDebugMode;

  /// Configuración de analytics y crash reporting
  static bool get enableAnalytics => _flavor == 'production';
  static bool get enableCrashReporting => _flavor == 'production';

  /// Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'CapachicaApp/1.0.0',
  };

  /// Configuración de imágenes
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  /// Configuración de validación
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;

  /// URLs de endpoints específicos
  // OJO: el tipo correcto es Map<String, Map<String, String>>
  static const Map<String, Map<String, String>> endpoints = {
    'auth': {
      'login': '/auth/login',
      'register': '/auth/register',
      'logout': '/auth/logout',
      'forgotPassword': '/auth/forgot-password',
      'resetPassword': '/auth/reset-password',
      'verifyEmail': '/auth/email/verify',
      'resendVerification': '/auth/email/verification-notification',
      'googleAuth': '/auth/google',
    },
    'services': {
      'list': '/servicios',
      'detail': '/servicios',
      'byCategory': '/servicios/categoria',
      'byEmprendedor': '/servicios/emprendedor',
    },
    'reservas': {
      'cart': '/reservas/carrito',
      'addToCart': '/reservas/carrito/agregar',
      'removeFromCart': '/reservas/carrito/servicio',
      'clearCart': '/reservas/carrito/vaciar',
      'confirm': '/reservas/carrito/confirmar',
      'myReservas': '/reservas/mis-reservas',
    },
    'planes': {
      'list': '/planes',
      'detail': '/planes',
      'public': '/public/planes',
    },
    'eventos': {
      'list': '/eventos',
      'detail': '/eventos',
      'byEmprendedor': '/eventos/emprendedor',
    },
    'emprendedores': {
      'list': '/emprendedores',
      'detail': '/emprendedores',
      'byCategory': '/emprendedores/categoria',
    },
    'municipalidad': {
      'list': '/municipalidad',
      'detail': '/municipalidad',
      'withRelations': '/municipalidad',
    },
    'sliders': {
      'list': '/sliders',
    },
  };

  /// Obtener endpoint completo
  static String getEndpoint(String category, String action) {
    final Map<String, String>? categoryEndpoints = endpoints[category];
    if (categoryEndpoints == null) {
      throw ArgumentError('Categoría de endpoint no encontrada: $category');
    }

    final String? endpoint = categoryEndpoints[action];
    if (endpoint == null) {
      throw ArgumentError('Endpoint no encontrado: $category.$action');
    }

    return endpoint;
  }

  /// Información de debug
  static Map<String, dynamic> get debugInfo => {
    'flavor': _flavor,
    'baseUrl': baseUrl,
    'platform': kIsWeb ? 'web' : Platform.operatingSystem,
    'isWeb': kIsWeb,
    'isDebug': kDebugMode,
    'isTestMode': isTestMode,
  };
}