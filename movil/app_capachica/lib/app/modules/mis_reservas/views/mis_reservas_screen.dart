import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mis_reservas_controller.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class MisReservasScreen extends GetView<MisReservasController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    
    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : theme.iconTheme.color,
            ),
            onPressed: () => Get.offAllNamed('/home'),
          ),
          title: Text(
            'Mis Reservas',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A202C),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1E3A8A) : theme.appBarTheme.backgroundColor,
          actions: [
            const CartIconWithBadge(),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState(context);
          } else if (controller.error.isNotEmpty) {
            return _buildErrorState(context);
          } else if (controller.reservas.isEmpty) {
            return _buildEmptyState(context);
          } else {
            return _buildReservasContent(context);
          }
        }),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando reservas...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar reservas',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A202C),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.error.value,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.cargarMisReservas,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes reservas',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A202C),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando hagas una reserva, aparecerá aquí',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.offAllNamed('/services-capachica'),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Explorar Servicios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservasContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    
    return RefreshIndicator(
      onRefresh: controller.cargarMisReservas,
      color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.reservas.length,
        itemBuilder: (context, index) {
          final reserva = controller.reservas[index];
          return _buildReservaCard(context, reserva);
        },
      ),
    );
  }

  Widget _buildReservaCard(BuildContext context, Map<String, dynamic> reserva) {
    final isDark = Get.isDarkMode;
    
    return Card(
      elevation: isDark ? 8 : 4,
      shadowColor: isDark 
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.1),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen y título
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del servicio
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/paquete-turistico1.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
                                : [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
                            ),
                          ),
                          child: Icon(
                            Icons.image_rounded,
                            size: 32,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Información del servicio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva['servicio']?['nombre'] ?? 'Servicio',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1A202C),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        reserva['emprendedor']?['nombre'] ?? 'Emprendedor Local',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Estado de la reserva
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? const Color(0xFF3B82F6).withOpacity(0.2)
                            : const Color(0xFFFF6B35).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Confirmada',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Detalles de la reserva
            _buildDetailRow(
              Icons.calendar_today_rounded,
              'Fecha: ${reserva['fechaInicio']}',
              isDark,
            ),
            
            const SizedBox(height: 8),
            
            _buildDetailRow(
              Icons.access_time_rounded,
              'Hora: ${reserva['horaInicio']} - ${reserva['horaFin']}',
              isDark,
            ),
            
            const SizedBox(height: 8),
            
            _buildDetailRow(
              Icons.timer_rounded,
              'Duración: ${reserva['duracionMinutos']} minutos',
              isDark,
            ),
            
            const SizedBox(height: 8),
            
            _buildDetailRow(
              Icons.payment_rounded,
              'Pago: ${reserva['metodoPago'] ?? 'efectivo'}',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white60 : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
} 