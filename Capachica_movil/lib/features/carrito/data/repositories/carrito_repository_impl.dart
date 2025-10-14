import '../../domain/entities/carrito.dart';
import '../../domain/entities/carrito_item.dart';
import '../../domain/repositories/carrito_repository.dart';
import '../datasources/carrito_local_data_source.dart';

class CarritoRepositoryImpl implements CarritoRepository {
  final CarritoLocalDataSource localDataSource;

  CarritoRepositoryImpl({required this.localDataSource});

  @override
  Future<Carrito> getCarrito() async {
    return await localDataSource.getCarrito();
  }

  @override
  Future<void> addItemToCarrito(CarritoItem item) async {
    await localDataSource.addItemToCarrito(item);
  }

  @override
  Future<void> removeItemFromCarrito(String itemId) async {
    await localDataSource.removeItemFromCarrito(itemId);
  }

  @override
  Future<void> updateItemInCarrito(CarritoItem item) async {
    await localDataSource.updateItemInCarrito(item);
  }

  @override
  Future<void> clearCarrito() async {
    await localDataSource.clearCarrito();
  }
}


