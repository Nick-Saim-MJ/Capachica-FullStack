import 'package:aplicativo_capachica/core/config/backend_config.dart';

class ApiConfig {
  // lee de --dart-define si lo pasas; si no, usa 10.0.2.2 (emulador Android → tu PC)
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: BackendConfig.baseUrl,
  );

  static Map<String, String> defaultHeaders = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}

