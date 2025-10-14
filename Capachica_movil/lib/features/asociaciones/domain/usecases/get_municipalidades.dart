import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/municipalidad.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/repositories/asociacion_repository.dart';
import 'package:dartz/dartz.dart';

class GetMunicipalidades implements UseCase<List<MunicipalidadEntity>, NoParams> {
  final AsociacionRepository repository;

  GetMunicipalidades(this.repository);

  @override
  Future<Either<Failure, List<MunicipalidadEntity>>> call(NoParams params) async {
    try {
      final result = await repository.getMunicipalidades();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

