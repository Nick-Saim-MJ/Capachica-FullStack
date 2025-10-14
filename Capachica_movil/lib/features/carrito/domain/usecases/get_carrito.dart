import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/core/errors/failures.dart';
import 'package:aplicativo_capachica/features/carrito/domain/entities/carrito.dart';
import 'package:aplicativo_capachica/features/carrito/domain/repositories/carrito_repository.dart';
import 'package:dartz/dartz.dart';

class GetCarrito implements UseCase<Carrito, NoParams> {
  final CarritoRepository repository;

  GetCarrito(this.repository);

  @override
  Future<Either<Failure, Carrito>> call(NoParams params) async {
    try {
      final carrito = await repository.getCarrito();
      return Right(carrito);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}


