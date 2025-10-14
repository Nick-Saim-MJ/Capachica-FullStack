// lib/features/plans/domain/entities/dia_entity.dart

import 'package:equatable/equatable.dart';
import 'servicio_entity.dart';

class DiaEntity extends Equatable {
  // final int id; // <-- QUITADO: No viene en el JSON de la ruta pública
  final int numeroDia;
  final String titulo;
  final String descripcion;
  final List<ServicioEntity> servicios;

  const DiaEntity({
    required this.numeroDia,
    required this.titulo,
    required this.descripcion,
    this.servicios = const [],
  });

  @override
  List<Object?> get props => [numeroDia, titulo, servicios];
}