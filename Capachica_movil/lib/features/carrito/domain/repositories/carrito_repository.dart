import '../entities/carrito.dart';
import '../entities/carrito_item.dart';

abstract class CarritoRepository {
  Future<Carrito> getCarrito();
  Future<void> addItemToCarrito(CarritoItem item);
  Future<void> removeItemFromCarrito(String itemId);
  Future<void> updateItemInCarrito(CarritoItem item);
  Future<void> clearCarrito();
}


