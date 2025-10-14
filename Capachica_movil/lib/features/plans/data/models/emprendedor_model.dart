// lib/features/plans/data/models/emprendedor_model.dart

import 'package:aplicativo_capachica/features/plans/domain/entities/emprendedor_entity.dart';

class EmprendedorModel extends EmprendedorEntity {
  const EmprendedorModel({
    required int id,
    required String nombre,
    String? ubicacion,
    String? telefono,
    String? email,
  }) : super(
    id: id,
    nombre: nombre,
    ubicacion: ubicacion,
    telefono: telefono,
    email: email,
  );

  factory EmprendedorModel.fromJson(Map<String, dynamic> json) {
    return EmprendedorModel(
      id: json['id'],
      nombre: json['nombre'],
      ubicacion: json['ubicacion'],
      telefono: json['telefono'],
      email: json['email'],
      // rol y esOrganizadorPrincipal se quitan porque no están en este JSON
    );
  }
}