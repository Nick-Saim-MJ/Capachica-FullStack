import 'package:aplicativo_capachica/features/auth/domain/entities/user_entity.dart';
import 'package:aplicativo_capachica/features/auth/domain/repositories/auth_repository.dart';

class GetProfileUseCase {
  final AuthRepository repo;
  GetProfileUseCase(this.repo);
  Future<UserEntity> call() => repo.getProfile();
}

