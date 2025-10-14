import 'package:equatable/equatable.dart';

class AdminUserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? country;
  final String? address;
  final String? gender;
  final String? birthDate;
  final String? preferredLanguage;
  final bool active;
  final List<String> roles;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.country,
    this.address,
    this.gender,
    this.birthDate,
    this.preferredLanguage,
    required this.active,
    required this.roles,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
        const <String>[];

    return AdminUserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      country: json['country'],
      address: json['address'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      preferredLanguage: json['preferred_language'],
      active: (json['active'] == true) ||
          (json['status']?.toString().toLowerCase() == 'active'),
      roles: roles,
    );
  }

  @override
  List<Object?> get props => [id, name, email, active, roles];
}
