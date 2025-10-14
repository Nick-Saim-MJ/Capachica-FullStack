import '../entities/user_entity.dart';


// either<L, R> is omitted; using simple Results for brevity.


class AuthResult {
  final UserEntity user;
  final String accessToken;
  final bool emailVerified;
  final List<String> roles;
  final bool administraEmprendimientos;
  const AuthResult({required this.user, required this.accessToken, required this.emailVerified, required this.roles, required this.administraEmprendimientos});
}


abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register({required String name, required String email, required String password, String? phone, String? country, String? birthDate, String? address, String? gender, String? preferredLanguage, String? fotoPerfilPath});
  Future<UserEntity> getProfile();
  Future<void> cleanLocalData();
  Future<void> logout();
}