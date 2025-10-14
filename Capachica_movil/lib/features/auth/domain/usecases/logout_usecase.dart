import 'package:aplicativo_capachica/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repo;
  LogoutUseCase(this.repo);
  Future<void> call() => repo.logout();
  Future<void> cleanLocalSession() async {
    // Lógica de limpieza sin llamar al servidor
    // 🛑 CORRECCIÓN: Usar 'repo' en lugar de 'repository'
    await repo.cleanLocalData();
  }

}