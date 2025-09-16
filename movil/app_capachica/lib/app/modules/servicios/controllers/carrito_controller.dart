import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/carrito_model.dart';
import '../../../services/carrito_service.dart';
import '../../../services/auth_service.dart';

class CarritoController extends GetxController {
  final CarritoService _carritoService = CarritoService();
  final AuthService _authService = Get.find<AuthService>();

  // Estados principales
  final RxList<CarritoItem> items = <CarritoItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Estados de operaciones
  final RxBool isRemovingItem = false.obs;
  final RxBool isProcessingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🛒 CarritoController: Inicializando...');
    loadCarrito();
  }

  /// Cargar carrito
  Future<void> loadCarrito() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('🛒 CarritoController: Cargando carrito...');

      final carritoData = await _carritoService.getCarrito();
      items.value = carritoData.items;

      debugPrint('✅ CarritoController: Carrito cargado con ${items.length} items');
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('❌ CarritoController: Error cargando carrito: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar item del carrito
  Future<void> eliminarItem(int itemId) async {
    try {
      isRemovingItem.value = true;

      debugPrint('🗑️ CarritoController: Eliminando item ID: $itemId');

      await _carritoService.eliminarItemDelCarrito(itemId);

      // Remover el item de la lista local
      items.removeWhere((item) => item.id == itemId);

      Get.snackbar(
        'Item eliminado',
        'El servicio ha sido eliminado del carrito',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      debugPrint('✅ CarritoController: Item eliminado exitosamente');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el item: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      debugPrint('❌ CarritoController: Error eliminando item: $e');
    } finally {
      isRemovingItem.value = false;
    }
  }

  /// Actualizar cantidad de un item
  Future<void> actualizarCantidad(int itemId, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await eliminarItem(itemId);
      return;
    }

    try {
      debugPrint('🔄 CarritoController: Actualizando cantidad del item ID: $itemId a $nuevaCantidad');

      await _carritoService.actualizarCantidadItem(itemId, nuevaCantidad);

      // Actualizar la cantidad en la lista local
      final idx = items.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        final item = items[idx];
        items[idx] = item.copyWith(cantidad: nuevaCantidad);
      }

      debugPrint('✅ CarritoController: Cantidad actualizada exitosamente');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la cantidad: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      debugPrint('❌ CarritoController: Error actualizando cantidad: $e');
    }
  }

  /// Proceder al pago
  Future<void> procederAlPago() async {
    if (!_authService.isLoggedIn) {
      Get.snackbar(
        'Autenticación requerida',
        'Debes iniciar sesión para proceder al pago',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    if (items.isEmpty) {
      Get.snackbar(
        'Carrito vacío',
        'Agrega algunos servicios antes de proceder al pago',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      isProcessingPayment.value = true;

      debugPrint('💳 CarritoController: Procediendo al pago...');

      Get.snackbar(
        'Procesando pago',
        'Redirigiendo al sistema de pago...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      await Future.delayed(const Duration(seconds: 2));

      await _carritoService.limpiarCarrito();
      items.clear();

      Get.snackbar(
        'Pago exitoso',
        'Tu reserva ha sido confirmada',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      debugPrint('✅ CarritoController: Pago procesado exitosamente');
    } catch (e) {
      Get.snackbar(
        'Error en el pago',
        'No se pudo procesar el pago: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      debugPrint('❌ CarritoController: Error procesando pago: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Refrescar datos del carrito
  Future<void> refreshData() async {
    await loadCarrito();
  }

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => _authService.isLoggedIn;

  /// Total del carrito (sin usar `precioTotal` del item)
  double get total {
    return items.fold<double>(0.0, (sum, item) {
      // 👇 Ajusta "precio" si en tu modelo se llama "precioUnitario" u otro
      final double precioUnit = item.precio;
      return sum + (precioUnit * item.cantidad);
    });
  }

  String get totalFormateado => 'S/ ${total.toStringAsFixed(2)}';
  bool get isEmpty => items.isEmpty;
  bool get hasItems => items.isNotEmpty;

  int get cantidadTotalItems =>
      items.fold<int>(0, (sum, item) => sum + item.cantidad);

  bool get puedeProcederAlPago =>
      isAuthenticated && hasItems && !isProcessingPayment.value;

  String get resumenCarrito =>
      isEmpty ? 'Carrito vacío' : '$cantidadTotalItems ${cantidadTotalItems == 1 ? 'servicio' : 'servicios'} - $totalFormateado';
}