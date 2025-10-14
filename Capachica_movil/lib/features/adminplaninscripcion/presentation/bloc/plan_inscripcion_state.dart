import 'package:equatable/equatable.dart';
import '../../data/model/plan_inscripcion_model.dart';

abstract class PlanInscripcionState extends Equatable {
  const PlanInscripcionState();
  @override
  List<Object> get props => [];
}

class PlanInscripcionInitial extends PlanInscripcionState {}
class PlanInscripcionLoading extends PlanInscripcionState {}
class PlanInscripcionOperationInProgress extends PlanInscripcionState {}
class PlanInscripcionOperationSuccess extends PlanInscripcionState {}

class PlanInscripcionLoaded extends PlanInscripcionState {
  final List<PlanInscripcionModel> inscripciones;
  const PlanInscripcionLoaded(this.inscripciones);
  @override
  List<Object> get props => [inscripciones];
}

class PlanInscripcionError extends PlanInscripcionState {
  final String message;
  const PlanInscripcionError(this.message);
  @override
  List<Object> get props => [message];
}