import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final int id;
  final String nombre;
  final String descripcion;
  final int duracionDias;
  final int capacidad;
  final int cuposDisponibles;
  final double? precioTotal;
  final String? dificultad;
  final String? queIncluye;
  final String? imagenPrincipalUrl;
  final String? estado; // 👈 AGREGADO: Soluciona el error
  final List<EmprendedorEntity> emprendedores; // AGREGADO
  final List<DiaEntity> dias;
  final DateTime? createdAt;
  final DateTime? updatedAt;// AGREGADO

  const PlanEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.duracionDias,
    required this.capacidad,
    required this.cuposDisponibles,
    this.precioTotal,
    this.dificultad,
    this.queIncluye,
    this.imagenPrincipalUrl,
    this.estado, // 👈 AGREGADO
    this.emprendedores = const [], // AGREGADO
    this.dias = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    duracionDias,
    capacidad,
    cuposDisponibles,
    precioTotal,
    dificultad,
    queIncluye,
    imagenPrincipalUrl,
    estado,
    emprendedores,
    dias,
    createdAt,
    updatedAt,
  ];
}

// =============================
// 👇 Entidades relacionadas
// =============================

class EmprendedorEntity extends Equatable {
  final int id;
  final String nombre;
  final String? ubicacion;
  final String? telefono;
  final String? email;
  final String? rol;
  final bool? esOrganizadorPrincipal;

  const EmprendedorEntity({
    required this.id,
    required this.nombre,
    this.ubicacion,
    this.telefono,
    this.email,
    this.rol,
    this.esOrganizadorPrincipal,
  });

  @override
  List<Object?> get props =>
      [id, nombre, ubicacion, telefono, email, rol, esOrganizadorPrincipal];
}

class DiaEntity extends Equatable {
  final int id;
  final int numeroDia;
  final String titulo;
  final String descripcion;
  final List<ServicioEntity> servicios;

  const DiaEntity({
    required this.id,
    required this.numeroDia,
    required this.titulo,
    required this.descripcion,
    this.servicios = const [],
  });

  @override
  List<Object?> get props => [id, numeroDia, titulo, descripcion, servicios];
}

class ServicioEntity extends Equatable {
  final int id;
  final String nombre;
  final String descripcion;
  final double? precioAdicional;

  const ServicioEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.precioAdicional,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, precioAdicional];
}