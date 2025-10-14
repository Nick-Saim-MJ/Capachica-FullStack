import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/repositories/asociacion_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteAsociacionUseCase implements UseCase<void, int> {
  final AsociacionRepository repository;

  DeleteAsociacionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    try {
      await repository.deleteAsociacion(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
