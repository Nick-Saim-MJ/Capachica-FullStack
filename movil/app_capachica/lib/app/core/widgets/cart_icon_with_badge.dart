import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'cart_bottom_sheet.dart';

class CartIconWithBadge extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;

  const CartIconWithBadge({
    Key? key,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: iconColor ?? Colors.white,
            size: iconSize ?? 24,
          ),
          onPressed: () {
            _showCartDialog(context, cartController, isDark);
          },
        ),
        // Badge con contador
        Obx(() {
          if (cartController.items.isEmpty) return const SizedBox.shrink();
          return Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${cartController.items.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showCartDialog(BuildContext context, CartController cartController, bool isDark) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 400,
          ),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]
                      : [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tu Carrito',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Obx(() => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cartController.items.length} items',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close, color: Colors.white, size: 20),
                          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: Obx(() {
                  if (cartController.isLoading.value) {
                    return _buildLoadingState(isDark);
                  }

                  if (cartController.items.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return Column(
                    children: [
                      // Lista de items
                      Flexible(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          shrinkWrap: true,
                          itemCount: cartController.items.length,
                          itemBuilder: (context, index) {
                            final item = cartController.items[index];
                            return _buildCompactCartItem(item, cartController, isDark);
                          },
                        ),
                      ),

                      // Footer con total y botones
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF334155) : Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Color(0xFF1A202C),
                                  ),
                                ),
                                Obx(() => Text(
                                  'S/ ${cartController.total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Botones
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.toNamed('/carrito');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Ver todo',
                                      style: TextStyle(
                                        color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final request = {
                                        'notas': '',
                                        'metodoPago': 'efectivo',
                                      };
                                      cartController.confirmarReserva(request);
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Confirmar',
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
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 200,
      child: Center(
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
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: isDark ? Colors.white30 : Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Tu carrito está vacío',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Agrega algunos servicios',
              style: TextStyle(
                color: isDark ? Colors.white70 : Color(0xFF718096),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCartItem(Map<String, dynamic> item, CartController cartController, bool isDark) {
    final servicio = item['servicio'] as Map<String, dynamic>;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF334155) : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Imagen pequeña
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: isDark ? Color(0xFF475569) : Colors.grey[300],
              child: Icon(
                Icons.image_outlined,
                size: 24,
                color: isDark ? Colors.white30 : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 12),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  servicio['nombre'] ?? 'Sin nombre',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Color(0xFF1A202C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Cant: ${item['cantidad']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Color(0xFF718096),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'S/ ${item['precioTotal']?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Color(0xFF10B981) : Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón eliminar
          IconButton(
            onPressed: () => cartController.eliminarDelCarrito(item),
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: Colors.red,
            ),
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
} 