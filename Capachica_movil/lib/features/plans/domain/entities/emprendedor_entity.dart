// lib/features/plans/domain/entities/emprendedor_entity.dart

import 'package:equatable/equatable.dart';

class EmprendedorEntity extends Equatable {
  final int id;
  final String nombre;
  final String? ubicacion;
  final String? telefono;
  final String? email;
  // final String? rol; // <-- QUITADO: No viene en el JSON de esta ruta
  // final bool? esOrganizadorPrincipal; // <-- QUITADO: Se maneja en el objeto `organizadorPrincipal` del Plan

  const EmprendedorEntity({
    required this.id,
    required this.nombre,
    this.ubicacion,
    this.telefono,
    this.email,
  });

  @override
  List<Object?> get props => [id, nombre];
}