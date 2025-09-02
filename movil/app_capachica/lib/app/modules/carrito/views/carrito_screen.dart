import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../core/widgets/cart_card.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class CarritoScreen extends GetView<CartController> {
  const CarritoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F1419) : Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Mi Carrito',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                : [Color(0xFFFF6B35), Color(0xFFFF8E53)], // Naranja para modo claro
            ),
          ),
        ),
        actions: [
          // Botón para vaciar carrito
          Obx(() {
            if (controller.items.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: isDark ? Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Vaciar carrito',
                      style: TextStyle(
                        color: isDark ? Colors.white : Color(0xFF1A202C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      '¿Estás seguro de que deseas vaciar el carrito?',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Color(0xFF718096),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.vaciarCarrito();
                        },
                        child: Text(
                          'Vaciar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          const ThemeToggleButton(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(isDark);
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState(isDark);
        }

        if (controller.items.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return Column(
          children: [
            // Lista de items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CartCard(
                      reserva: item,
                      onEliminar: () => controller.eliminarDelCarrito(item),
                      onEditar: () => controller.editarReserva(item),
                    ),
                  );
                },
              ),
            ),

            // Resumen y botón de confirmar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Color(0xFF1A202C),
                        ),
                      ),
                      Text(
                        'S/ ${controller.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón confirmar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final request = {
                          'notas': '',
                          'metodoPago': 'efectivo',
                        };
                        controller.confirmarReserva(request);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Confirmar Reservas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando carrito...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.red[400] : Colors.red[600],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar el carrito',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.error.value,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.sincronizarCarritoConBackend(),
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text('Reintentar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agrega algunos servicios para continuar',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text('Volver a servicios', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 