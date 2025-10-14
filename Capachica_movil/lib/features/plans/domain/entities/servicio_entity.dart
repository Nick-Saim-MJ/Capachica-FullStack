// lib/features/plans/domain/entities/servicio_entity.dart

import 'package:equatable/equatable.dart';

class ServicioEntity extends Equatable {
  final int id;
  final String nombre;
  final String descripcion;
  final double? precio; // <-- CAMBIADO: Coincide con el JSON de la API

  const ServicioEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.precio, // <-- CAMBIADO
  });

  @override
  List<Object?> get props => [id, nombre, precio];
}