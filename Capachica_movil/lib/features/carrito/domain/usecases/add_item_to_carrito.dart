import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/carrito/domain/entities/carrito_item.dart';
import 'package:aplicativo_capachica/features/carrito/domain/repositories/carrito_repository.dart';
import 'package:dartz/dartz.dart';

class AddItemToCarrito implements UseCase<void, CarritoItem> {
  final CarritoRepository repository;

  AddItemToCarrito(this.repository);

  @override
  Future<Either<Failure, void>> call(CarritoItem item) async {
    try {
      await repository.addItemToCarrito(item);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}


