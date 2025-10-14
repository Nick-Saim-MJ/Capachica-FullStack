import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/carrito/domain/repositories/carrito_repository.dart';
import 'package:dartz/dartz.dart';

class RemoveItemFromCarrito implements UseCase<void, String> {
  final CarritoRepository repository;

  RemoveItemFromCarrito(this.repository);

  @override
  Future<Either<Failure, void>> call(String itemId) async {
    try {
      await repository.removeItemFromCarrito(itemId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}


