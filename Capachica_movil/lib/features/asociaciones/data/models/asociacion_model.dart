// lib/features/asociaciones/data/models/asociacion_model.dart
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/asociacion.dart';
import 'municipalidad_model.dart';

class AsociacionModel {
  final int id;
  final String nombre;
  final String? descripcion;

  final String? telefono;
  final String? email;

  final bool? estado;
  final double? latitud;
  final double? longitud;

  final String? imagen;     // ruta relativa si viene
  final String? imagenUrl;  // url absoluta si viene

  final int? municipalidadId;
  final MunicipalidadModel? municipalidad;

  final String? createdAt;
  final String? updatedAt;

  AsociacionModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.telefono,
    this.email,
    this.estado,
    this.latitud,
    this.longitud,
    this.imagen,
    this.imagenUrl,
    this.municipalidadId,
    this.municipalidad,
    this.createdAt,
    this.updatedAt,
  });

  factory AsociacionModel.fromJson(Map<String, dynamic> json) {
    return AsociacionModel(
      id: asInt(json['id']) ?? 0,
      nombre: asString(json['nombre']),
      descripcion: json['descripcion']?.toString(),
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      estado: asBool(json['estado']),
      latitud: asDouble(json['latitud']),
      longitud: asDouble(json['longitud']),
      imagen: json['imagen']?.toString(),
      imagenUrl: json['imagen_url']?.toString(),
      municipalidadId: asInt(json['municipalidad_id']),
      municipalidad: (json['municipalidad'] is Map)
          ? MunicipalidadModel.fromJson(
          Map<String, dynamic>.from(json['municipalidad']))
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'telefono': telefono,
    'email': email,
    'estado': estado,
    'latitud': latitud,
    'longitud': longitud,
    'imagen': imagen,
    'imagen_url': imagenUrl,
    'municipalidad_id': municipalidadId,
    'municipalidad': municipalidad?.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  // Método para convertir a entidad
  AsociacionEntity toEntity() {
    return AsociacionEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion ?? '',
      direccion: null, // No está en el modelo de BD según especificaciones
      telefono: telefono,
      email: email,
      logo: null, // No está en el modelo de BD
      imagen: imagen,
      estado: estado,
      latitud: latitud,
      longitud: longitud,
      municipalidadId: municipalidadId,
      municipalidadNombre: municipalidad?.nombre,
      fechaCreacion: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      fechaActualizacion: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}
