class BackendConfig {
  static const String baseUrlnoApi = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '$baseUrlnoApi/api',
  );

  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
  static String get profile => '$baseUrl/profile';
  static String get logout => '$baseUrl/logout';
  static String get emprendedores => '$baseUrl/emprendedores';
  static String get asociaciones => '$baseUrl/asociaciones';
  static String get eventos => '$baseUrl/eventos';
  static String get planes => '$baseUrl/planes';
  static String get servicios => '$baseUrl/servicios';
  static String get inscripciones => '$baseUrl/admin/planes/inscripciones/todas';

  // ✅ NUEVO: endpoints 2FA protegidos con Bearer
  static String get twoFASetup   => '$baseUrl/2fa/setup';    // GET => { otpauth_url, qr_svg, secret }
  static String get twoFAConfirm => '$baseUrl/2fa/confirm';  // POST { code }
  static String get twoFADisable => '$baseUrl/2fa/disable';  // POST {}

  static String getBaseUrl() => baseUrl;

  static Map<String, String> get defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}

// No lo sabías gato
//   ___
//  /   \
// | o o |
// |  ^  |
// | '-' |
//  \___/
// Yo siempre estuve ahi