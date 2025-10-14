import 'package:equatable/equatable.dart';

abstract class PlanInscripcionEvent extends Equatable {
  const PlanInscripcionEvent();
  @override
  List<Object> get props => [];
}

class LoadInscripciones extends PlanInscripcionEvent {}

class UpdateEstado extends PlanInscripcionEvent {
  final int id;
  final String nuevoEstado;
  const UpdateEstado(this.id, this.nuevoEstado);
  @override
  List<Object> get props => [id, nuevoEstado];
}