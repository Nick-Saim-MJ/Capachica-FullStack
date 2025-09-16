import 'municipalidad_model.dart';

class Servicio {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? imagenUrl;
  final double? precio;
  final bool isActive;

  Servicio({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    this.precio,
    required this.isActive,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      imagenUrl: json['imagen_url'] ?? json['imagenUrl'],
      precio: json['precio']?.toDouble(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen_url': imagenUrl,
      'precio': precio,
      'is_active': isActive,
    };
  }
}

class Negocio {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? imagenUrl;
  final String? ubicacion;
  final String? telefono;
  final String? email;
  final bool isActive;

  Negocio({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.imagenUrl,
    this.ubicacion,
    this.telefono,
    this.email,
    required this.isActive,
  });

  factory Negocio.fromJson(Map<String, dynamic> json) {
    return Negocio(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      imagenUrl: json['imagen_url'] ?? json['imagenUrl'],
      ubicacion: json['ubicacion'],
      telefono: json['telefono'],
      email: json['email'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagen_url': imagenUrl,
      'ubicacion': ubicacion,
      'telefono': telefono,
      'email': email,
      'is_active': isActive,
    };
  }
}

class MunicipalidadDetalle {
  final Municipalidad municipalidad;
  final List<Servicio> servicios;
  final List<Negocio> negocios;
  final Map<String, dynamic>? estadisticas;

  MunicipalidadDetalle({
    required this.municipalidad,
    required this.servicios,
    required this.negocios,
    this.estadisticas,
  });

  factory MunicipalidadDetalle.fromJson(Map<String, dynamic> json) {
    return MunicipalidadDetalle(
      municipalidad: Municipalidad.fromJson(json['municipalidad'] ?? json),
      servicios: (json['servicios'] as List<dynamic>?)
          ?.map((e) => Servicio.fromJson(e))
          .toList() ?? [],
      negocios: (json['negocios'] as List<dynamic>?)
          ?.map((e) => Negocio.fromJson(e))
          .toList() ?? [],
      estadisticas: json['estadisticas'] != null 
          ? Map<String, dynamic>.from(json['estadisticas']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'municipalidad': municipalidad.toJson(),
      'servicios': servicios.map((e) => e.toJson()).toList(),
      'negocios': negocios.map((e) => e.toJson()).toList(),
      'estadisticas': estadisticas,
    };
  }
} 