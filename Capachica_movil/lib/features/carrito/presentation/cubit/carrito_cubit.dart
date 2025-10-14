import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/carrito.dart';
import '../../domain/entities/carrito_item.dart';
import '../../domain/usecases/get_carrito.dart';
import '../../domain/usecases/add_item_to_carrito.dart' as use_case;
import '../../domain/usecases/remove_item_from_carrito.dart' as use_case;
import '../../domain/usecases/clear_carrito.dart' as use_case;
import '../../../../core/usecase/usecase.dart';
import 'carrito_event.dart';
import 'carrito_state.dart';

class CarritoCubit extends Bloc<CarritoEvent, CarritoState> {
  final GetCarrito getCarrito;
  final use_case.AddItemToCarrito addItemToCarrito;
  final use_case.RemoveItemFromCarrito removeItemFromCarrito;
  final use_case.ClearCarrito clearCarrito;

  CarritoCubit({
    required this.getCarrito,
    required this.addItemToCarrito,
    required this.removeItemFromCarrito,
    required this.clearCarrito,
  }) : super(CarritoInitial()) {
    on<LoadCarrito>(_onLoadCarrito);
    on<AddItemToCarrito>(_onAddItemToCarrito);
    on<RemoveItemFromCarrito>(_onRemoveItemFromCarrito);
    on<ClearCarrito>(_onClearCarrito);
  }

  Future<void> _onLoadCarrito(LoadCarrito event, Emitter<CarritoState> emit) async {
    emit(CarritoLoading());
    final result = await getCarrito(NoParams());
    result.fold(
      (failure) => emit(CarritoError('Ocurrió un error al cargar el carrito')),
      (carrito) => emit(CarritoLoaded(carrito)),
    );
  }

  Future<void> _onAddItemToCarrito(AddItemToCarrito event, Emitter<CarritoState> emit) async {
    final result = await addItemToCarrito(event.item);
    result.fold(
      (failure) => emit(CarritoError('No se pudo agregar el item')),
      (_) {
        emit(ItemAddedToCarrito(event.item));
        if (!isClosed) {
          try {
            add(LoadCarrito());
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _onRemoveItemFromCarrito(RemoveItemFromCarrito event, Emitter<CarritoState> emit) async {
    final result = await removeItemFromCarrito(event.itemId);
    result.fold(
      (failure) => emit(CarritoError('No se pudo eliminar el item')),
      (_) {
        emit(ItemRemovedFromCarrito(event.itemId));
        if (!isClosed) {
          try {
            add(LoadCarrito());
          } catch (_) {}
        }
      },
    );
  }

  Future<void> _onClearCarrito(ClearCarrito event, Emitter<CarritoState> emit) async {
    final result = await clearCarrito(NoParams());
    result.fold(
      (failure) => emit(CarritoError('No se pudo limpiar el carrito')),
      (_) {
        emit(CarritoCleared());
        if (!isClosed) {
          try {
            add(LoadCarrito());
          } catch (_) {}
        }
      },
    );
  }
}


