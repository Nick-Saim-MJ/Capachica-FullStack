// lib/core/usecases/usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Clase base abstracta para los Casos de Uso (Use Cases).
/// Define una estructura estándar para todas las operaciones de negocio.
///
/// [Type]: Define el tipo de dato que el caso de uso devolverá en caso de éxito.
/// [Params]: Define el tipo de objeto que se pasará como parámetro para ejecutar el caso de uso.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Clase de utilidad que se puede usar cuando un caso de uso no necesita parámetros.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

abstract class NoParamsUseCase<Type> {
  Future<Type> call();
}