class UserEntity {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool active;
  final String? fotoPerfil;
  final String? country;
  final String? birthDate; // ISO yyyy-mm-dd
  final String? address;
  final String? gender;
  final String? preferredLanguage;
  final String? lastLogin; // ISO
  final List<String> roles;
  final bool isAdmin;


  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.active,
    required this.roles,
    required this.isAdmin,
    this.phone,
    this.fotoPerfil,
    this.country,
    this.birthDate,
    this.address,
    this.gender,
    this.preferredLanguage,
    this.lastLogin,
  });
}