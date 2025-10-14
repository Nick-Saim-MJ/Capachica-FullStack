// lib/features/municipalidades/presentation/bloc/municipalidad_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/municipalidad.dart';

abstract class MunicipalidadState extends Equatable {
  const MunicipalidadState();

  @override
  List<Object?> get props => [];
}

class MunicipalidadInitial extends MunicipalidadState {}

class MunicipalidadLoading extends MunicipalidadState {}

class MunicipalidadLoaded extends MunicipalidadState {
  final List<MunicipalidadEntity> municipalidades;

  const MunicipalidadLoaded(this.municipalidades);

  @override
  List<Object?> get props => [municipalidades];
}

class MunicipalidadLoadedSingle extends MunicipalidadState {
  final MunicipalidadEntity municipalidad;

  const MunicipalidadLoadedSingle(this.municipalidad);

  @override
  List<Object?> get props => [municipalidad];
}

class MunicipalidadError extends MunicipalidadState {
  final String message;

  const MunicipalidadError(this.message);

  @override
  List<Object?> get props => [message];
}

class MunicipalidadSuccess extends MunicipalidadState {
  final String message;

  const MunicipalidadSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
