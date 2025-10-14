
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:equatable/equatable.dart';

abstract class ServiciosRelacionadosState extends Equatable {
  const ServiciosRelacionadosState();

  @override
  List<Object> get props => [];
}

class ServiciosRelacionadosInitial extends ServiciosRelacionadosState {}

class ServiciosRelacionadosLoading extends ServiciosRelacionadosState {}

class ServiciosRelacionadosLoaded extends ServiciosRelacionadosState {
  final List<ServiceEntity> servicios;

  const ServiciosRelacionadosLoaded(this.servicios);

  @override
  List<Object> get props => [servicios];
}

class ServiciosRelacionadosError extends ServiciosRelacionadosState {
  final String message;

  const ServiciosRelacionadosError(this.message);

  @override
  List<Object> get props => [message];
}