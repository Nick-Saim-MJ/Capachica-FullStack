// lib/features/plans/data/models/servicio_model.dart

import 'package:aplicativo_capachica/features/plans/domain/entities/plan.dart';

class ServicioModel extends ServicioEntity {
  const ServicioModel({
    required int id,
    required String nombre,
    required String descripcion,
    double? precio, // <-- CORREGIDO
  }) : super(
    id: id,
    nombre: nombre,
    descripcion: descripcion,
    precioAdicional: precio, // <-- CORREGIDO
  );

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num?)?.toDouble(), // <-- CORREGIDO
    );
  }
}