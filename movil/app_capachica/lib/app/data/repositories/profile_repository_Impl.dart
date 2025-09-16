import '../../domain/repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../services/profile_service.dart';
import 'dart:io';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl(this._profileService);

  /// Obtiene el perfil completo del usuario
  @override
  Future<ProfileModel> getProfile() async {
    return await _profileService.getProfile();
  }

  /// Actualiza el perfil del usuario, con posibilidad de enviar foto de perfil
  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> data, {File? fotoPerfil}) async {
    return await _profileService.updateProfile(data, fotoPerfil: fotoPerfil);
  }
}
