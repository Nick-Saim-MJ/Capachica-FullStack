import '../../domain/entities/carrito_item.dart';

abstract class CarritoEvent {}

class LoadCarrito extends CarritoEvent {}

class AddItemToCarrito extends CarritoEvent {
  final CarritoItem item;
  AddItemToCarrito(this.item);
}

class RemoveItemFromCarrito extends CarritoEvent {
  final String itemId;
  RemoveItemFromCarrito(this.itemId);
}

class ClearCarrito extends CarritoEvent {}


