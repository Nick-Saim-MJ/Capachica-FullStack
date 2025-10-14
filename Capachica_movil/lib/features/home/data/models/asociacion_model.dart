// lib/features/home/data/models/asociacion_model.dart

import 'package:aplicativo_capachica/features/home/data/models/emprendedor_model.dart';


class AsociacionModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? telefono;
  final String? email;
  final int? municipalidadId;
  final bool estado;
  final String? imagen;
  final double? latitud;
  final double? longitud;
  final String? imagenUrl;
  final List<EmprendedorModel>? emprendedores;

  AsociacionModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.telefono,
    this.email,
    this.municipalidadId,
    required this.estado,
    this.imagen,
    this.latitud,
    this.longitud,
    this.imagenUrl,
    this.emprendedores,
  });

  factory AsociacionModel.fromJson(Map<String, dynamic> json) {
    return AsociacionModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      telefono: json['telefono'],
      email: json['email'],
      municipalidadId: json['municipalidad_id'],
      estado: json['estado'] ?? false,
      imagen: json['imagen'],
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      imagenUrl: json['imagen_url'],
      emprendedores: json['emprendedores'] != null
          ? (json['emprendedores'] as List).map((e) => EmprendedorModel.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'telefono': telefono,
      'email': email,
      'municipalidad_id': municipalidadId,
      'estado': estado,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
      'imagen_url': imagenUrl,
      'emprendedores': emprendedores?.map((e) => e.toJson()).toList(),
    };
  }

  AsociacionModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? telefono,
    String? email,
    int? municipalidadId,
    bool? estado,
    String? imagen,
    double? latitud,
    double? longitud,
    String? imagenUrl,
    List<EmprendedorModel>? emprendedores,
  }) {
    return AsociacionModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      municipalidadId: municipalidadId ?? this.municipalidadId,
      estado: estado ?? this.estado,
      imagen: imagen ?? this.imagen,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      emprendedores: emprendedores ?? this.emprendedores,
    );
  }
}