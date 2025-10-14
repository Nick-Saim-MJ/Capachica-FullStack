import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';


class LoginUseCase {
  final AuthRepository repo;
  LoginUseCase(this.repo);
  Future<AuthResult> call(String email, String password) => repo.login(email, password);
}