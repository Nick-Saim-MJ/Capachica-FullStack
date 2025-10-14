// lib/features/asociaciones/data/models/municipalidad_model.dart

import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/municipalidad.dart';

class MunicipalidadModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? provincia;
  final String? region;
  final String? redFacebook;
  final String? redInstagram;
  final double? coordenadasX;
  final double? coordenadasY;

  MunicipalidadModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.provincia,
    this.region,
    this.redFacebook,
    this.redInstagram,
    this.coordenadasX,
    this.coordenadasY,
  });

  factory MunicipalidadModel.fromJson(Map<String, dynamic> json) {
    return MunicipalidadModel(
      id: asInt(json['id']) ?? 0,
      nombre: asString(json['nombre']),
      descripcion: json['descripcion']?.toString(),
      provincia: json['provincia']?.toString(),
      region: json['region']?.toString(),
      redFacebook: json['red_facebook']?.toString(),
      redInstagram: json['red_instagram']?.toString(),
      coordenadasX: asDouble(json['coordenadas_x']),
      coordenadasY: asDouble(json['coordenadas_y']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    if (descripcion != null) 'descripcion': descripcion,
    if (provincia != null) 'provincia': provincia,
    if (region != null) 'region': region,
    if (redFacebook != null) 'red_facebook': redFacebook,
    if (redInstagram != null) 'red_instagram': redInstagram,
    if (coordenadasX != null) 'coordenadas_x': coordenadasX,
    if (coordenadasY != null) 'coordenadas_y': coordenadasY,
  };

  MunicipalidadEntity toEntity() {
    return MunicipalidadEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      provincia: provincia,
      region: region,
    );
  }
}


