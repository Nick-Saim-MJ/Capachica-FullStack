import 'package:dio/dio.dart'; // Necesario para usar FormData y MultipartFile de Dio
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/core/network/api_client.dart'; // Tu cliente Dio
import 'package:http/http.dart' as http; // Mantener solo si el parámetro 'foto' es http.MultipartFile

class AuthRemoteDataSource {
  final ApiClient api;
  AuthRemoteDataSource(this.api);


  // --- 1. LOGIN (POST) ---
  // Cambios: 'body' -> 'data' y usar 'res.data'
  Future<Map<String, dynamic>> login(
      String email,
      String password, {
        String? twoFactorCode,
      }) async {
    final res = await api.post(
      BackendConfig.login,
      data: {
        'email': email,
        'password': password,
        if (twoFactorCode != null) 'two_factor_code': twoFactorCode,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  // 2FA: iniciar (trae QR y otpauth)
  Future<Map<String, dynamic>> twoFASetup() async {
    final res = await api.get(BackendConfig.twoFASetup);
    return res.data as Map<String, dynamic>;
  }

  // 2FA: confirmar TOTP
  Future<Map<String, dynamic>> twoFAConfirm(String code) async {
    final res = await api.post(BackendConfig.twoFAConfirm, data: {'code': code});
    return res.data as Map<String, dynamic>;
  }

  // 2FA: deshabilitar
  Future<void> twoFADisable() async {
    await api.post(BackendConfig.twoFADisable);
  }


  // --- 2. REGISTER (POST MULTIPART) ---
  // Cambios: Recibir http.MultipartFile si es necesario, construir FormData, usar 'res.data'.
  // NOTA: Para este ejemplo, asumiremos que recibes el http.MultipartFile
  // y lo convertiremos al tipo File de Dio para la petición.
  Future<Map<String, dynamic>> register(Map<String, String> fields, {http.MultipartFile? foto}) async {

    // Crear el objeto FormData
    final FormData formData = FormData.fromMap(fields);

    if (foto != null) {
      // Convertir http.MultipartFile a Dio.MultipartFile, que requiere una ruta o bytes
      // Asumiremos que tenemos acceso a la ruta del archivo o los bytes para crear Dio.MultipartFile.
      // Si solo tienes el objeto http.MultipartFile, esta conversión requiere más pasos.
      // La forma más simple es trabajar con File/Uint8List y usar MultipartFile.fromBytes o fromFile.
      // --- Usaremos una conversión simple de ejemplo con bytes ---
      final fileBytes = await foto.finalize().toBytes();
      formData.files.add(MapEntry(
        'foto_perfil', // Nombre del campo en el servidor
        MultipartFile.fromBytes(
          fileBytes,
          filename: foto.filename, // Usar el nombre de archivo original
        ),
      ));
    }

    // La firma de postMultipart en ApiClient es: postMultipart(String path, FormData data, ...)
    final res = await api.postMultipart(
      BackendConfig.register,
      formData,
    );

    // De nuevo, usar res.data
    return res.data as Map<String, dynamic>;
  }


  // --- 3. PROFILE (GET) ---
  // Cambios: Eliminar 'auth: true' y usar 'res.data'.
  Future<Map<String, dynamic>> profile() async {
    // La autenticación se maneja automáticamente en el Interceptor de ApiClient, no se necesita 'auth: true'.
    final res = await api.get(BackendConfig.profile);
    return res.data as Map<String, dynamic>;
  }


  // --- 4. LOGOUT (POST) ---
  // Cambios: Eliminar 'auth: true'.
  Future<void> logout() async {
    // La autenticación se maneja automáticamente en el Interceptor de ApiClient, no se necesita 'auth: true'.
    await api.post(BackendConfig.logout);
  }
}
