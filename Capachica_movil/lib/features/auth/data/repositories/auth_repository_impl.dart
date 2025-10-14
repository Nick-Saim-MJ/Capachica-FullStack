import 'package:aplicativo_capachica/core/error/failures.dart';
import 'package:aplicativo_capachica/core/errors/exceptions.dart';
import 'package:aplicativo_capachica/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:aplicativo_capachica/features/auth/domain/entities/user_entity.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:aplicativo_capachica/core/storage/secure_storage.dart';
import 'package:aplicativo_capachica/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:aplicativo_capachica/features/auth/data/models/user_model.dart';
import 'package:aplicativo_capachica/features/auth/domain/repositories/auth_repository.dart';


// NOTA: Asumimos que AuthRepository, UserModel, AuthResult y AppSecureStorage están definidos.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AppSecureStorage storage;

  AuthRepositoryImpl({required this.remote, required this.storage});

  @override
  Future<AuthResult> login(String email, String password, {String? twoFactorCode}) async {
    try {
      final map = await remote.login(email, password, twoFactorCode: twoFactorCode);
      final data = map['data'] as Map<String, dynamic>;

      final user  = UserModel.fromJson(data['user']);
      final token = data['access_token'] as String;
      final roles = (data['roles'] as List).map((e) => e.toString()).toList();
      final emailVerified = (data['email_verified'] == true);
      final twoFAEnabled  = (data['two_factor_enabled'] == true) || (user.roles).isNotEmpty; // o como venga

      await storage.saveToken(token);
      await storage.saveRoles(roles);
      await storage.setEmailVerified(emailVerified);
      await storage.setTwoFAEnabled(twoFAEnabled);

      return AuthResult(
        user: user,
        accessToken: token,
        emailVerified: emailVerified,
        roles: roles,
        administraEmprendimientos: data['administra_emprendimientos'] == true,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final body   = (e.response?.data as Map?) ?? const {};
      if (status == 403 && body['data']?['requires_2fa'] == true) {
        // Indica reto 2FA (tenemos que pedir el código)
        throw RequiresTwoFA(email, password);
      }
      rethrow;
    }
  }


  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? country,
    String? birthDate,
    String? address,
    String? gender,
    String? preferredLanguage,
    String? fotoPerfilPath,
  }) async {
    final fields = <String, String>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      if (phone != null) 'phone': phone,
      if (country != null) 'country': country,
      if (birthDate != null) 'birth_date': birthDate,
      if (address != null) 'address': address,
      if (gender != null) 'gender': gender,
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
    };

    http.MultipartFile? foto;
    if (fotoPerfilPath != null) {
      foto = await http.MultipartFile.fromPath('foto_perfil', fotoPerfilPath);
    }

    final map  = await remote.register(fields, foto: foto);
    final data = map['data'] as Map<String, dynamic>;

    // Si backend dijo que debe configurar 2FA, lanzamos excepción para ir a pantalla de setup
    if (data['must_setup_2fa'] == true) {
      // puedes guardar aquí token temporal si devuelves alguno; si no, después de login lo pides
      throw MustSetupTwoFA();
    }

    // flujo normal (si decides permitir sin 2FA inmediato)
    final user  = UserModel.fromJson(data['user']);
    final token = data['access_token'] as String;
    final roles = (data['roles'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final emailVerified = data['email_verified'] == true;

    await storage.saveToken(token);
    await storage.saveRoles(roles);
    await storage.setEmailVerified(emailVerified);
    await storage.setTwoFAEnabled(false);

    return AuthResult(
      user: user,
      accessToken: token,
      emailVerified: emailVerified,
      roles: roles,
      administraEmprendimientos: data['administra_emprendimientos'] == true,
    );
  }

  // 2FA helpers para UI
  Future<Map<String, dynamic>> startTwoFASetup() => remote.twoFASetup();
  Future<void> confirmTwoFA(String code) async {
    final res = await remote.twoFAConfirm(code);
    final enabled = (res['data']?['two_factor_enabled'] == true);
    await storage.setTwoFAEnabled(enabled);
  }

  Future<void> disableTwoFA() async {
    await remote.twoFADisable();
    await storage.setTwoFAEnabled(false);
  }

  @override
  Future<UserEntity> getProfile() async {
    final map = await remote.profile();
    final data = map['data'] as Map<String, dynamic>;

    // El backend puede enviar el usuario bajo la clave 'user' o como objeto raíz
    final user = UserModel.fromJson(data['user'] ?? data);

    final roles = (data['roles'] as List?)?.map((e) => e.toString()).toList() ?? [];
    await storage.saveRoles(roles);
    return user;
  }
  // 🛑 IMPLEMENTACIÓN DEL MÉTODO REQUERIDO POR EL REPOSITORY INTERFACE
  @override
  Future<void> cleanLocalData() async {
    // Usamos el método existente 'clearAll' de AppSecureStorage para
    // eliminar el token, roles e email_verified.
    await storage.clearAll();
  }

  // Tu método logout() ahora está limpio y usa la nueva función.
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // 1. Intentar cerrar sesión en el servidor
      await remote.logout();
    } catch (e) {
      // Ignoramos la falla del servidor (ej. 401)
    }

    // 2. Siempre limpia la sesión local usando la función que llama a clearAll()
    await cleanLocalData();

    return const Right(null);
  }
}
