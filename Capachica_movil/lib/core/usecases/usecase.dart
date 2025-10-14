import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failure.dart';

// Clase base abstracta para los casos de uso.
// Define un contrato para que todos los casos de uso tengan un método `call`.
// Type: El tipo de dato que el caso de uso devuelve en caso de éxito.
// Params: El tipo de dato de los parámetros que el caso de uso necesita.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Clase de parámetros vacía para casos de uso que no necesitan parámetros.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
