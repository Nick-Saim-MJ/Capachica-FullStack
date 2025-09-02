import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/reserva_service.dart';

class CartController extends GetxController {
  final ReservaService _reservaService = Get.find<ReservaService>();
  
  final items = <Map<String, dynamic>>[].obs;
  final total = 0.0.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    sincronizarCarritoConBackend();
  }

  Future<void> sincronizarCarritoConBackend() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final carritoResponse = await _reservaService.obtenerCarrito();
      items.assignAll(carritoResponse['items'] ?? []);
      total.value = carritoResponse['total'] ?? 0.0;
    } catch (e) {
      error.value = e.toString();
      print('[CartController] Error sincronizando carrito: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> agregarAlCarrito(Map<String, dynamic> request) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _reservaService.agregarAlCarrito(request);
      
      if (response['success'] == true) {
        // Sincronizar con el backend
        await sincronizarCarritoConBackend();
        
        Get.snackbar(
          '¡Agregado!',
          'Servicio agregado al carrito exitosamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      } else {
        throw response['message'] ?? 'Error agregando al carrito';
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo agregar al carrito: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> eliminarDelCarrito(Map<String, dynamic> reserva) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _reservaService.eliminarDelCarrito(reserva);
      
      if (response['success'] == true) {
        // Sincronizar con el backend
        await sincronizarCarritoConBackend();
        
        Get.snackbar(
          'Eliminado',
          'Servicio eliminado del carrito',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
        );
      } else {
        throw response['message'] ?? 'Error eliminando del carrito';
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo eliminar del carrito: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editarReserva(Map<String, dynamic> reservaEditada) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Primero eliminar la reserva actual
      await _reservaService.eliminarDelCarrito(reservaEditada);
      
      // Luego agregar la reserva editada
      await _reservaService.agregarAlCarrito(reservaEditada);
      
      // Sincronizar con el backend
      await sincronizarCarritoConBackend();
      
      Get.snackbar(
        'Actualizado',
        'Plan actualizado correctamente',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo actualizar el plan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> vaciarCarrito() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _reservaService.vaciarCarrito();
      
      if (response['success'] == true) {
        // Sincronizar con el backend
        await sincronizarCarritoConBackend();
        
        Get.snackbar(
          'Carrito vaciado',
          'Se han eliminado todos los servicios del carrito',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.remove_shopping_cart_outlined, color: Colors.white),
        );
      } else {
        throw response['message'] ?? 'Error vaciando carrito';
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo vaciar el carrito: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmarReserva(Map<String, dynamic> request) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await _reservaService.confirmarReserva(request);
      
      if (response['success'] == true) {
        // Sincronizar con el backend
        await sincronizarCarritoConBackend();
        
        Get.snackbar(
          '¡Reserva confirmada!',
          'Tu reserva ha sido confirmada exitosamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
        
        // Navegar a mis reservas
        Get.offAllNamed('/mis-reservas');
      } else {
        throw response['message'] ?? 'Error confirmando reserva';
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'No se pudo confirmar la reserva: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> agregarReserva(Map<String, dynamic> reserva) async {
    await agregarAlCarrito(reserva);
  }

  void mostrarDialogoConfirmacion() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de éxito
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              
              // Título
              Text(
                '¡Agregado al carrito!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Colors.white : const Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 8),
              
              // Mensaje
              Text(
                'Has agregado el item al carrito exitosamente',
                style: TextStyle(
                  fontSize: 14,
                  color: Get.isDarkMode ? Colors.white70 : const Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Cerrar diálogo
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Get.isDarkMode ? Colors.white30 : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        'Seguir navegando',
                        style: TextStyle(
                          color: Get.isDarkMode ? Colors.white : const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Cerrar diálogo
                        Get.toNamed('/carrito'); // Navegar al carrito
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.isDarkMode ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ver carrito',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
} 