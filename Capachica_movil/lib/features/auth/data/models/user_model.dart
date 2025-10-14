import '../../domain/entities/user_entity.dart';


class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.active,
    required super.roles,
    required super.isAdmin,
    super.phone,
    super.fotoPerfil,
    super.country,
    super.birthDate,
    super.address,
    super.gender,
    super.preferredLanguage,
    super.lastLogin,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List?)?.map((e) => e.toString()).toList() ??
        (json['data']?['roles'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];


    return UserModel(
      id: json['id'] ?? json['data']?['id'],
      name: json['name'] ?? json['data']?['name'],
      email: json['email'] ?? json['data']?['email'],
      phone: json['phone'] ?? json['data']?['phone'],
      active: (json['active'] ?? json['data']?['active']) == true,
      fotoPerfil: json['foto_perfil'] ?? json['data']?['foto_perfil'],
      country: json['country'] ?? json['data']?['country'],
      birthDate: json['birth_date'] ?? json['data']?['birth_date'],
      address: json['address'] ?? json['data']?['address'],
      gender: json['gender'] ?? json['data']?['gender'],
      preferredLanguage: json['preferred_language'] ?? json['data']?['preferred_language'],
      lastLogin: json['last_login'] ?? json['data']?['last_login'],
      roles: roles,
      isAdmin: (json['is_admin'] ?? json['data']?['is_admin']) == true || roles.contains('admin'),
    );
  }
}