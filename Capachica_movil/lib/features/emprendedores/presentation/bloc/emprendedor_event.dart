// municipalidad_event.dart
// presentation/bloc/municipalidad_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/emprendedor.dart';
// emprendedor_event.dart
// presentation/bloc/emprendedor_event.dart
import 'package:equatable/equatable.dart';

abstract class EmprendedorEvent extends Equatable {
  const EmprendedorEvent();

  @override

  List<Object?> get props => [];
}

class LoadEmprendedores extends EmprendedorEvent {
  const LoadEmprendedores();
}

/// Crear
class CreateEmprendedorEvent extends EmprendedorEvent {
  final EmprendedorEntity emprendedor;
  const CreateEmprendedorEvent(this.emprendedor);

  @override
  List<Object?> get props => [emprendedor];
}

/// Actualizar
class UpdateEmprendedorEvent extends EmprendedorEvent {
  final EmprendedorEntity emprendedor;
  const UpdateEmprendedorEvent(this.emprendedor);

  @override
  List<Object?> get props => [emprendedor];
}

/// Eliminar
class DeleteEmprendedorEvent extends EmprendedorEvent {
  final int id;
  const DeleteEmprendedorEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Buscar
class SearchEmprendedoresEvent extends EmprendedorEvent {
  final String query;
  const SearchEmprendedoresEvent(this.query);

  @override
  List<Object?> get props => [query];
}
