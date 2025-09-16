import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/services_capachica_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import 'service_detail_screen.dart';
import 'service_card.dart';

class ServicesCapachicaScreen extends GetView<ServicesCapachicaController> {
  const ServicesCapachicaScreen({super.key});

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
          'Servicios Capachica',
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
          const CartIconWithBadge(),
          const ThemeToggleButton(),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          _buildSearchAndFilters(context, isDark),
          
          // Contenido principal
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(isDark);
              } else if (controller.error.isNotEmpty) {
                return _buildErrorState(context, isDark);
              } else if (controller.serviciosFiltrados.isEmpty) {
                return _buildEmptyState(context, isDark);
              } else {
                return _buildServicesList(context, isDark);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          TextField(
            onChanged: controller.buscarServicios,
            style: TextStyle(
              color: isDark ? Colors.white : Color(0xFF1A202C),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar servicios...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade500,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                size: 20,
              ),
              suffixIcon: Obx(() {
                if (controller.searchQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                      size: 20,
                    ),
                    onPressed: controller.limpiarFiltros,
                  );
                }
                return const SizedBox.shrink();
              }),
              filled: true,
              fillColor: isDark 
                ? Color(0xFF334155).withValues(alpha: 0.3)
                : Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),

          const SizedBox(height: 16),

          // Filtros de categorías
          Obx(() {
            final categorias = controller.getCategoriasUnicas();
            if (categorias.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No hay categorías disponibles',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Color(0xFF718096),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrar por categoría:',
                  style: TextStyle(
                    color: isDark ? Colors.white : Color(0xFF374151),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Botón "Todas"
                      _buildFilterChip(
                        'Todas',
                        controller.categoriaSeleccionada.value == 0,
                        () => controller.limpiarFiltros(),
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      // Categorías
                      ...categorias.map((categoria) {
                        final isSelected = controller.categoriaSeleccionada.value > 0 &&
                            controller.servicios.any((servicio) =>
                                servicio.categorias.any((cat) => cat.nombre == categoria && cat.id == controller.categoriaSeleccionada.value));

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            categoria,
                            isSelected,
                            () {
                              final servicio = controller.servicios.firstWhere(
                                (s) => s.categorias.any((cat) => cat.nombre == categoria),
                                orElse: () => controller.servicios.first,
                              );
                              if (servicio.categorias.isNotEmpty) {
                                final categoriaId = servicio.categorias
                                    .firstWhere((cat) => cat.nombre == categoria)
                                    .id;
                                controller.filtrarPorCategoria(categoriaId);
                              }
                            },
                            isDark,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35))
              : (isDark ? Color(0xFF334155) : Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35))
                : (isDark ? Colors.white10 : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : Color(0xFF374151)),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark 
            ? Color(0xFF2D3748).withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
              ),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando servicios...',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Obteniendo servicios disponibles',
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

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'Error al cargar servicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(0xFF1A202C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.error.value,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshServicios,
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.search_off_rounded, 
                size: 48, 
                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron servicios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(0xFF1A202C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'No hay servicios disponibles en este momento',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.searchQuery.value.isNotEmpty) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.limpiarFiltros,
                icon: Icon(Icons.clear_rounded, size: 20),
                label: Text('Limpiar filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshServicios();
      },
      color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
      child: Obx(() {
        if (controller.serviciosFiltrados.isEmpty) {
          return _buildEmptyState(context, isDark);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.serviciosFiltrados.length,
          itemBuilder: (context, index) {
            final servicio = controller.serviciosFiltrados[index];
            
            return ServiceCard(
              servicio: servicio,
              onTap: () {
                Get.to(() => ServiceDetailScreen(servicio: servicio));
              },
            );
          },
        );
      }),
    );
  }
}