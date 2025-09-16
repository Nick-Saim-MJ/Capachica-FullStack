class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? country;
  final DateTime? birthDate;
  final String? address;
  final String? gender;
  final String? preferredLanguage;
  final DateTime? lastLogin;
  final bool active;
  final String? avatar;
  final String? fotoPerfil;
  final String? fotoPerfilUrl;
  final String? googleId;
  final DateTime? emailVerifiedAt;

  // Roles (con permisos)
  final List<Role>? roles;

  // Estadísticas planes usuario (opcional)
  final EstadisticasPlanesUsuario? estadisticasPlanesUsuario;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.country,
    this.birthDate,
    this.address,
    this.gender,
    this.preferredLanguage,
    this.lastLogin,
    required this.active,
    this.avatar,
    this.fotoPerfil,
    this.fotoPerfilUrl,
    this.googleId,
    this.emailVerifiedAt,
    this.roles,
    this.estadisticasPlanesUsuario,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      print("❌ JSON inválido, falta 'id': $json");
      throw Exception("El campo 'id' es requerido pero es null");
    }
    return ProfileModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      country: json['country'],
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'])
          : null,
      address: json['address'],
      gender: json['gender'],
      preferredLanguage: json['preferred_language'],
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
      active: json['active'] ?? false,
      avatar: json['avatar'],
      fotoPerfil: json['foto_perfil'],
      fotoPerfilUrl: json['foto_perfil_url'],
      googleId: json['google_id'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      roles: json['roles'] != null
          ? List<Role>.from(
          json['roles'].map((roleJson) => Role.fromJson(roleJson)))
          : null,
      estadisticasPlanesUsuario: json['estadisticas_planes_usuario'] != null
          ? EstadisticasPlanesUsuario.fromJson(json['estadisticas_planes_usuario'])
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'birth_date': birthDate?.toIso8601String(),
      'address': address,
      'gender': gender,
      'preferred_language': preferredLanguage,
      'last_login': lastLogin?.toIso8601String(),
      'active': active,
      'avatar': avatar,
      'foto_perfil': fotoPerfil,
      'foto_perfil_url': fotoPerfilUrl,
      'google_id': googleId,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'roles': roles?.map((r) => r.toJson()).toList(),
      'estadisticas_planes_usuario': estadisticasPlanesUsuario?.toJson(),
    };
  }
}

class Role {
  final int? id;
  final String name;
  final List<String>? permissions;

  Role({
    this.id,
    required this.name,
    this.permissions,
  });

  factory Role.fromJson(dynamic json) {
    if (json is String) {
      // Handle the case where the role is just a string, e.g., "admin"
      return Role(name: json);
    } else if (json is Map<String, dynamic>) {
      // Handle the case where the role is a map with details
      List<String>? perms;
      if (json['permissions'] != null) {
        perms = List<String>.from(json['permissions'].map((perm) {
          if (perm is String) {
            return perm;
          } else if (perm is Map<String, dynamic> && perm['name'] != null) {
            return perm['name'];
          }
          return '';
        }).where((p) => p.isNotEmpty));
      }
      return Role(
        id: json['id'],
        name: json['name'] ?? '',
        permissions: perms,
      );
    }
    // Fallback for unexpected types
    throw Exception("Invalid type for role: ${json.runtimeType}");
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions,
    };
  }
}

class EstadisticasPlanesUsuario {
  final int planesCreados;
  final int planesActivosCreados;
  final int totalInscripciones;
  final int inscripcionesConfirmadas;
  final int inscripcionesPendientes;
  final int proximasInscripciones;
  final int inscripcionesEnProgreso;
  final double totalGastado;

  EstadisticasPlanesUsuario({
    required this.planesCreados,
    required this.planesActivosCreados,
    required this.totalInscripciones,
    required this.inscripcionesConfirmadas,
    required this.inscripcionesPendientes,
    required this.proximasInscripciones,
    required this.inscripcionesEnProgreso,
    required this.totalGastado,
  });

  factory EstadisticasPlanesUsuario.fromJson(Map<String, dynamic> json) {
    return EstadisticasPlanesUsuario(
      planesCreados: json['planes_creados'] ?? 0,
      planesActivosCreados: json['planes_activos_creados'] ?? 0,
      totalInscripciones: json['total_inscripciones'] ?? 0,
      inscripcionesConfirmadas: json['inscripciones_confirmadas'] ?? 0,
      inscripcionesPendientes: json['inscripciones_pendientes'] ?? 0,
      proximasInscripciones: json['proximas_inscripciones'] ?? 0,
      inscripcionesEnProgreso: json['inscripciones_en_progreso'] ?? 0,
      totalGastado: (json['total_gastado'] != null)
          ? (json['total_gastado'] is int
          ? (json['total_gastado'] as int).toDouble()
          : json['total_gastado'])
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planes_creados': planesCreados,
      'planes_activos_creados': planesActivosCreados,
      'total_inscripciones': totalInscripciones,
      'inscripciones_confirmadas': inscripcionesConfirmadas,
      'inscripciones_pendientes': inscripcionesPendientes,
      'proximas_inscripciones': proximasInscripciones,
      'inscripciones_en_progreso': inscripcionesEnProgreso,
      'total_gastado': totalGastado,
    };
  }
}
