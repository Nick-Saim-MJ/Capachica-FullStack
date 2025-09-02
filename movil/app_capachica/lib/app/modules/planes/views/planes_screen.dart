import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/planes_controller.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import 'plan_card.dart';

class PlanesScreen extends GetView<PlanesController> {
  const PlanesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F1419) : Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header moderno con gradiente
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 16, 
              right: 16, 
              top: MediaQuery.of(context).padding.top + 8, 
              bottom: 24
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                  : [Color(0xFFFF6B35), Color(0xFFFF8E53)], // Naranja para modo claro
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Color(0xFF1E3A8A).withValues(alpha: 0.3)
                    : Color(0xFFFF6B35).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra de navegación
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Planes Turísticos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Descubre experiencias únicas',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CartIconWithBadge(iconColor: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        onPressed: () => controller.refreshPlanes(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ThemeToggleButton(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Barra de búsqueda elegante
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: controller.filterByQuery,
                    decoration: InputDecoration(
                      hintText: '🔍 Buscar planes turísticos...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      prefixIcon: Container(
                        margin: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B35).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.search_rounded, 
                          color: Color(0xFFFF6B35),
                          size: 20,
                        ),
                      ),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return Container(
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.clear_rounded, color: Colors.grey[600], size: 18),
                              onPressed: () => controller.filterByQuery(''),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filtros modernos
          _buildModernFilters(isDark),
          // Contenido principal
          Expanded(
            child: Obx(() {
              if (controller.isCurrentlyLoading) {
                return _buildLoadingState(isDark);
              } else if (controller.hasError) {
                return _buildErrorState(isDark);
              } else if (!controller.hasPlanes) {
                return _buildEmptyState(isDark);
              } else {
                return _buildPlanesList();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilters(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Filtrar por categoría',
            style: TextStyle(
              color: isDark ? Colors.white : Color(0xFF1A202C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.categorias.map((categoria) {
                return Obx(() {
                  final isSelected = controller.selectedCategoria.value == categoria;
                  return Container(
                    margin: EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        if (isSelected) {
                          controller.filterByCategoria('');
                        } else {
                          controller.filterByCategoria(categoria);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                            ? LinearGradient(
                                colors: isDark 
                                  ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                                  : [Color(0xFFFF6B35), Color(0xFFFF8E53)], // Naranja para modo claro
                              )
                            : null,
                          color: isSelected 
                            ? null 
                            : isDark 
                              ? Color(0xFF2D3748).withValues(alpha: 0.6)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                              ? Colors.transparent
                              : isDark 
                                ? Color(0xFF3B82F6).withValues(alpha: 0.3)
                                : Color(0xFFFF6B35).withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: isDark 
                                ? Color(0xFF1E3A8A).withValues(alpha: 0.3)
                                : Color(0xFFFF6B35).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          categoria,
                          style: TextStyle(
                            color: isSelected 
                              ? Colors.white
                              : isDark 
                                ? Colors.white
                                : Color(0xFF1A202C),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ),
          // Botón para limpiar filtros
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty || 
                (controller.selectedCategoria.value.isNotEmpty && controller.selectedCategoria.value != 'Todas')) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InkWell(
                  onTap: controller.clearFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Color(0xFF3B82F6).withValues(alpha: 0.1)
                        : Color(0xFFFF6B35).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark 
                          ? Color(0xFF3B82F6).withValues(alpha: 0.3)
                          : Color(0xFFFF6B35).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.clear_all_rounded, 
                             size: 16, color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)),
                        SizedBox(width: 6),
                        Text(
                          'Limpiar filtros',
                          style: TextStyle(
                            color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
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
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
                  ),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Cargando planes turísticos...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Color(0xFF1A202C),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Descubre las mejores experiencias',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Color(0xFF718096),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark 
            ? Color(0xFF2D3748).withValues(alpha: 0.5)
            : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.2),
            width: 1,
          ),
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
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Error al cargar planes',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              style: TextStyle(
                color: isDark ? Colors.white70 : Color(0xFF718096),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            )),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.refreshPlanes(),
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark 
            ? Color(0xFF2D3748).withValues(alpha: 0.5)
            : Colors.white,
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
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: Color(0xFFFF6B35),
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron planes',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Intenta ajustar tus filtros de búsqueda o explora otras categorías.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Color(0xFF718096),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.clearFilters(),
              icon: Icon(Icons.clear_all_rounded, size: 20),
              label: Text('Limpiar filtros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildPlanesList() {
    return RefreshIndicator(
      onRefresh: controller.refreshPlanes,
      color: Color(0xFFFF6B35),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.planesFiltrados.length,
        itemBuilder: (context, index) {
          final plan = controller.planesFiltrados[index];
          return PlanCard(
            plan: plan,
            onTap: () => controller.navigateToPlanDetalle(plan),
          );
        },
      ),
    );
  }
} 