import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/asociacion.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/repositories/asociacion_repository.dart';
import 'package:dartz/dartz.dart';

class CreateAsociacionParams {
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? telefono;
  final String? email;
  final double? latitud;
  final double? longitud;
  final int municipalidadId;
  final bool? estado;
  final String? imagen;

  CreateAsociacionParams({
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.telefono,
    this.email,
    this.latitud,
    this.longitud,
    required this.municipalidadId,
    this.estado,
    this.imagen,
  });
}

class CreateAsociacionUseCase implements UseCase<AsociacionEntity, CreateAsociacionParams> {
  final AsociacionRepository repository;

  CreateAsociacionUseCase(this.repository);

  @override
  Future<Either<Failure, AsociacionEntity>> call(CreateAsociacionParams params) async {
    try {
      final result = await repository.createAsociacion(params);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
