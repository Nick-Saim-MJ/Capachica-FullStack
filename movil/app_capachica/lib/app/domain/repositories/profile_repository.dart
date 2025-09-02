import '../../data/models/profile_model.dart';
import 'dart:io';

abstract class ProfileRepository {
  /// Obtiene el perfil completo del usuario
  Future<ProfileModel> getProfile();

  /// Actualiza el perfil del usuario
  /// El parámetro [data] contiene los campos a actualizar
  /// El parámetro opcional [fotoPerfil] es la imagen del perfil a subir
  Future<ProfileModel> updateProfile(Map<String, dynamic> data, {File? fotoPerfil});
}
