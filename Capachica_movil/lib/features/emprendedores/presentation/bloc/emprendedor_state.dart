
// emprendedor_state.dart
// presentation/bloc/emprendedor_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/emprendedor.dart';

abstract class EmprendedorState extends Equatable {
  const EmprendedorState();

  @override
  List<Object?> get props => [];
}

class EmprendedorInitial extends EmprendedorState {}

class EmprendedorLoading extends EmprendedorState {}

class EmprendedorLoaded extends EmprendedorState {
  final List<EmprendedorEntity> emprendedores;

  const EmprendedorLoaded(this.emprendedores);

  @override
  List<Object?> get props => [emprendedores];
}

class EmprendedorError extends EmprendedorState {
  final String message;

  const EmprendedorError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmprendedorSuccess extends EmprendedorState{
  final String message;

  const EmprendedorSuccess(this.message);

  @override
  List<Object?> get props => [message];
}