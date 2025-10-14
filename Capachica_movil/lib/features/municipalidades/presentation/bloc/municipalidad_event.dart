// lib/features/municipalidades/presentation/bloc/municipalidad_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/municipalidad.dart';

abstract class MunicipalidadEvent extends Equatable {
  const MunicipalidadEvent();

  @override
  List<Object?> get props => [];
}

// Cargar todas las municipalidades
class LoadMunicipalidades extends MunicipalidadEvent {}

// Obtener una municipalidad específica
class LoadMunicipalidadById extends MunicipalidadEvent {
  final int id;

  const LoadMunicipalidadById(this.id);

  @override
  List<Object?> get props => [id];
}

// Crear nueva municipalidad
class CreateMunicipalidadEvent extends MunicipalidadEvent {
  final MunicipalidadEntity municipalidad;

  const CreateMunicipalidadEvent(this.municipalidad);

  @override
  List<Object?> get props => [municipalidad];
}

// Actualizar municipalidad
class UpdateMunicipalidadEvent extends MunicipalidadEvent {
  final MunicipalidadEntity municipalidad;

  const UpdateMunicipalidadEvent(this.municipalidad);

  @override
  List<Object?> get props => [municipalidad];
}

// Eliminar municipalidad
class DeleteMunicipalidadEvent extends MunicipalidadEvent {
  final int id;

  const DeleteMunicipalidadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// Buscar municipalidades
class SearchMunicipalidadesEvent extends MunicipalidadEvent {
  final String query;

  const SearchMunicipalidadesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
