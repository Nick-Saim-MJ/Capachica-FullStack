// lib/features/asociaciones/presentation/bloc/asociacion_state.dart
import 'package:equatable/equatable.dart';
import 'package:aplicativo_capachica/features/asociaciones/data/models/laravel_paginated.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/asociacion.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/municipalidad.dart';

abstract class AsociacionState extends Equatable {
  const AsociacionState();
  @override
  List<Object?> get props => [];
}

class AsociacionInitial extends AsociacionState {}

// ===== Listado principal =====
class AsociacionesLoading extends AsociacionState {}

class AsociacionesLoaded extends AsociacionState {
  final LaravelPaginated<AsociacionEntity> asociaciones;
  final bool hasReachedMax;
  final DateTime timestamp; // Para forzar actualización de UI
  
  AsociacionesLoaded({
    required this.asociaciones,
    required this.hasReachedMax,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  @override
  List<Object?> get props => [asociaciones, hasReachedMax, timestamp];
}

class AsociacionesError extends AsociacionState {
  final String message;
  const AsociacionesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===== Detalle =====
class AsociacionLoading extends AsociacionState {}

class AsociacionLoaded extends AsociacionState {
  final AsociacionEntity asociacion;
  const AsociacionLoaded(this.asociacion);
  @override
  List<Object?> get props => [asociacion];
}

class AsociacionError extends AsociacionState {
  final String message;
  const AsociacionError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===== Emprendedores por asociación =====
class EmprendedoresLoading extends AsociacionState {}

class EmprendedoresLoaded extends AsociacionState {
  final List<EmprendedorEntity> emprendedores;
  final int asociacionId;
  const EmprendedoresLoaded({
    required this.emprendedores,
    required this.asociacionId,
  });
  @override
  List<Object?> get props => [emprendedores, asociacionId];
}

class EmprendedoresError extends AsociacionState {
  final String message;
  const EmprendedoresError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===== Asociaciones por municipalidad =====
class AsociacionesByMunicipalidadLoading extends AsociacionState {}

class AsociacionesByMunicipalidadLoaded extends AsociacionState {
  final List<AsociacionEntity> asociaciones;
  final int municipalidadId;
  const AsociacionesByMunicipalidadLoaded({
    required this.asociaciones,
    required this.municipalidadId,
  });
  @override
  List<Object?> get props => [asociaciones, municipalidadId];
}

class AsociacionesByMunicipalidadError extends AsociacionState {
  final String message;
  const AsociacionesByMunicipalidadError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===== Búsqueda por ubicación =====
class AsociacionesByLocationLoading extends AsociacionState {}

class AsociacionesByLocationLoaded extends AsociacionState {
  final List<AsociacionEntity> asociaciones;
  final double latitud;
  final double longitud;
  final double distancia;
  const AsociacionesByLocationLoaded({
    required this.asociaciones,
    required this.latitud,
    required this.longitud,
    required this.distancia,
  });
  @override
  List<Object?> get props => [asociaciones, latitud, longitud, distancia];
}

class AsociacionesByLocationError extends AsociacionState {
  final String message;
  const AsociacionesByLocationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===== Filtro local =====
class AsociacionesFiltered extends AsociacionState {
  final List<AsociacionEntity> filteredAsociaciones;
  final String query;
  const AsociacionesFiltered({
    required this.filteredAsociaciones,
    required this.query,
  });
  @override
  List<Object?> get props => [filteredAsociaciones, query];
}

// ===== CRUD Operations =====
class AsociacionCreating extends AsociacionState {}

class AsociacionCreated extends AsociacionState {
  final AsociacionEntity asociacion;
  const AsociacionCreated(this.asociacion);
  @override
  List<Object?> get props => [asociacion];
}

class AsociacionUpdating extends AsociacionState {}

class AsociacionUpdated extends AsociacionState {
  final AsociacionEntity asociacion;
  const AsociacionUpdated(this.asociacion);
  @override
  List<Object?> get props => [asociacion];
}

class AsociacionDeleting extends AsociacionState {}

class AsociacionDeleted extends AsociacionState {
  final int id;
  const AsociacionDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class AsociacionCrudError extends AsociacionState {
  final String message;
  const AsociacionCrudError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===== Municipalidades =====
class MunicipalidadesLoading extends AsociacionState {}

class MunicipalidadesLoaded extends AsociacionState {
  final List<MunicipalidadEntity> municipalidades;
  const MunicipalidadesLoaded(this.municipalidades);
  @override
  List<Object?> get props => [municipalidades];
}

class MunicipalidadesError extends AsociacionState {
  final String message;
  const MunicipalidadesError(this.message);
  @override
  List<Object?> get props => [message];
}