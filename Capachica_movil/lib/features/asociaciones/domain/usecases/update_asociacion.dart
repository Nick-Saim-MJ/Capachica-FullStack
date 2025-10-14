import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/asociacion.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/repositories/asociacion_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateAsociacionParams {
  final int id;
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

  UpdateAsociacionParams({
    required this.id,
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

class UpdateAsociacionUseCase implements UseCase<AsociacionEntity, UpdateAsociacionParams> {
  final AsociacionRepository repository;

  UpdateAsociacionUseCase(this.repository);

  @override
  Future<Either<Failure, AsociacionEntity>> call(UpdateAsociacionParams params) async {
    try {
      final result = await repository.updateAsociacion(params);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
