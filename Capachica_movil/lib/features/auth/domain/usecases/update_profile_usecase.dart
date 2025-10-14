// lib/features/auth/domain/usecases/update_profile_usecase.dart
import 'package:aplicativo_capachica/features/auth/data/models/user_model.dart';
import 'package:aplicativo_capachica/features/auth/domain/repositories/profile_repository.dart';

import '../../data/repositories/profile_repository_impl.dart';

class UpdateProfileParams {
  final String? name;
  final String? email;
  final String? phone;
  final String? country;
  final String? birthDate;
  final String? address;
  final String? gender;
  final String? preferredLanguage;
  final String? fotoPerfilPath;

  UpdateProfileParams({
    this.name,
    this.email,
    this.phone,
    this.country,
    this.birthDate,
    this.address,
    this.gender,
    this.preferredLanguage,
    this.fotoPerfilPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'birth_date': birthDate,
      'address': address,
      'gender': gender,
      'preferred_language': preferredLanguage,
      // 'birth_date': ... si lo usas, agrégalo aquí
    }..removeWhere((k, v) => v == null);
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<UserModel> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}
