import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/carrito_item.dart';
import '../../domain/entities/carrito.dart';

abstract class CarritoLocalDataSource {
  Future<Carrito> getCarrito();
  Future<void> saveCarrito(Carrito carrito);
  Future<void> addItemToCarrito(CarritoItem item);
  Future<void> removeItemFromCarrito(String itemId);
  Future<void> updateItemInCarrito(CarritoItem item);
  Future<void> clearCarrito();
}

class CarritoLocalDataSourceImpl implements CarritoLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _carritoKey = 'carrito_items';

  CarritoLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Carrito> getCarrito() async {
    final String? carritoJson = sharedPreferences.getString(_carritoKey);
    if (carritoJson == null || carritoJson.isEmpty) {
      return Carrito.empty();
    }
    try {
      final List<dynamic> itemsJson = json.decode(carritoJson);
      final List<CarritoItem> items = itemsJson
          .map((itemJson) => CarritoItem.fromJson(itemJson as Map<String, dynamic>))
          .toList();
      return Carrito.fromItems(items);
    } catch (_) {
      return Carrito.empty();
    }
  }

  @override
  Future<void> saveCarrito(Carrito carrito) async {
    final String carritoJson = json.encode(
      carrito.items.map((item) => item.toJson()).toList(),
    );
    await sharedPreferences.setString(_carritoKey, carritoJson);
  }

  @override
  Future<void> addItemToCarrito(CarritoItem item) async {
    final Carrito currentCarrito = await getCarrito();
    final existingItemIndex = currentCarrito.items.indexWhere((existingItem) =>
        existingItem.servicio.id == item.servicio.id &&
        existingItem.fechaSeleccionada.day == item.fechaSeleccionada.day &&
        existingItem.fechaSeleccionada.month == item.fechaSeleccionada.month &&
        existingItem.fechaSeleccionada.year == item.fechaSeleccionada.year &&
        existingItem.horaInicio == item.horaInicio &&
        existingItem.horaFin == item.horaFin);

    List<CarritoItem> updatedItems = List.from(currentCarrito.items);
    if (existingItemIndex != -1) {
      final existingItem = updatedItems[existingItemIndex];
      updatedItems[existingItemIndex] = existingItem.copyWith(
        cantidad: existingItem.cantidad + item.cantidad,
      );
    } else {
      updatedItems.add(item);
    }
    final updatedCarrito = Carrito.fromItems(updatedItems);
    await saveCarrito(updatedCarrito);
  }

  @override
  Future<void> removeItemFromCarrito(String itemId) async {
    final Carrito currentCarrito = await getCarrito();
    final updatedItems = currentCarrito.items.where((item) => item.id != itemId).toList();
    final updatedCarrito = Carrito.fromItems(updatedItems);
    await saveCarrito(updatedCarrito);
  }

  @override
  Future<void> updateItemInCarrito(CarritoItem item) async {
    final Carrito currentCarrito = await getCarrito();
    final updatedItems = currentCarrito.items.map((existingItem) {
      if (existingItem.id == item.id) {
        return item;
      }
      return existingItem;
    }).toList();
    final updatedCarrito = Carrito.fromItems(updatedItems);
    await saveCarrito(updatedCarrito);
  }

  @override
  Future<void> clearCarrito() async {
    await sharedPreferences.remove(_carritoKey);
  }
}


