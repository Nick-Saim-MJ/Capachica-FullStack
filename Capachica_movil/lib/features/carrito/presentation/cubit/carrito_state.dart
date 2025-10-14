import 'package:equatable/equatable.dart';
import '../../domain/entities/carrito.dart';
import '../../domain/entities/carrito_item.dart';

abstract class CarritoState extends Equatable {
  const CarritoState();
  @override
  List<Object?> get props => [];
}

class CarritoInitial extends CarritoState {}
class CarritoLoading extends CarritoState {}

class CarritoLoaded extends CarritoState {
  final Carrito carrito;
  const CarritoLoaded(this.carrito);
  @override
  List<Object?> get props => [carrito];
}

class CarritoError extends CarritoState {
  final String message;
  const CarritoError(this.message);
  @override
  List<Object?> get props => [message];
}

class ItemAddedToCarrito extends CarritoState {
  final CarritoItem item;
  const ItemAddedToCarrito(this.item);
  @override
  List<Object?> get props => [item];
}

class ItemRemovedFromCarrito extends CarritoState {
  final String itemId;
  const ItemRemovedFromCarrito(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CarritoCleared extends CarritoState {}


