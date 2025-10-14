import 'package:aplicativo_capachica/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repo;
  RegisterUseCase(this.repo);
  Future<AuthResult> call({required String name, required String email, required String password, String? phone, String? country, String? birthDate, String? address, String? gender, String? preferredLanguage, String? fotoPerfilPath}) =>
      repo.register(name: name, email: email, password: password, phone: phone, country: country, birthDate: birthDate, address: address, gender: gender, preferredLanguage: preferredLanguage, fotoPerfilPath: fotoPerfilPath);
}