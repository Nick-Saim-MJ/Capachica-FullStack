import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/carrito/domain/repositories/carrito_repository.dart';
import 'package:dartz/dartz.dart';

class ClearCarrito implements UseCase<void, NoParams> {
  final CarritoRepository repository;

  ClearCarrito(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await repository.clearCarrito();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}


