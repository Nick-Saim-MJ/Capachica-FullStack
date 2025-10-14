import 'package:equatable/equatable.dart';
import 'carrito_item.dart';

class Carrito extends Equatable {
  final List<CarritoItem> items;
  final int totalItems;
  final int totalServiciosUnicos;

  const Carrito({
    required this.items,
    required this.totalItems,
    required this.totalServiciosUnicos,
  });

  factory Carrito.empty() {
    return const Carrito(
      items: [],
      totalItems: 0,
      totalServiciosUnicos: 0,
    );
  }

  factory Carrito.fromItems(List<CarritoItem> items) {
    return Carrito(
      items: items,
      totalItems: items.fold(0, (sum, item) => sum + item.cantidad),
      totalServiciosUnicos: items.length,
    );
  }

  Carrito copyWith({
    List<CarritoItem>? items,
  }) {
    return Carrito.fromItems(items ?? this.items);
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [items, totalItems, totalServiciosUnicos];
}


