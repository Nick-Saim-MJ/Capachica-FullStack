/// Configuración de flavors para diferentes entornos
class Flavors {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  
  /// Obtener flavor actual desde variables de entorno
  static String get current {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: development);
    return flavor;
  }
  
  /// Verificar si estamos en desarrollo
  static bool get isDevelopment => current == development;
  
  /// Verificar si estamos en staging
  static bool get isStaging => current == staging;
  
  /// Verificar si estamos en producción
  static bool get isProduction => current == production;
  
  /// Obtener configuración específica del flavor
  static Map<String, dynamic> get config {
    switch (current) {
      case development:
        return {
          'apiUrl': 'http://127.0.0.1:8000/api',
          'enableLogging': true,
          'enableAnalytics': false,
          'enableCrashReporting': false,
          'cacheTTL': 5, // 5 minutos en desarrollo
        };
      case staging:
        return {
          'apiUrl': 'http://staging-api.capachica.com/api',
          'enableLogging': true,
          'enableAnalytics': true,
          'enableCrashReporting': true,
          'cacheTTL': 10, // 10 minutos en staging
        };
      case production:
        return {
          'apiUrl': 'https://api.capachica.com/api',
          'enableLogging': false,
          'enableAnalytics': true,
          'enableCrashReporting': true,
          'cacheTTL': 15, // 15 minutos en producción
        };
      default:
        return {
          'apiUrl': 'http://127.0.0.1:8000/api',
          'enableLogging': true,
          'enableAnalytics': false,
          'enableCrashReporting': false,
          'cacheTTL': 5,
        };
    }
  }
}
