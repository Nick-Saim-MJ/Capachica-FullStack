import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../controllers/emprendedores_controller.dart';
import 'emprendedor_card.dart';

class EmprendedoresScreen extends GetView<EmprendedoresController> {
  const EmprendedoresScreen({Key? key}) : super(key: key);

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
          'Emprendedores',
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
          // Barra de búsqueda
          _buildSearchBar(isDark),
          
          // Filtros
          _buildFilters(isDark),
          
          // Información de paginación
          _buildPaginationInfo(isDark),
          
          // Contenido principal
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(isDark);
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState(isDark);
              }

              if (controller.emprendedores.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return _buildEmprendedoresList(isDark);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.white60 : Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchEmprendedores(value),
              decoration: InputDecoration(
                hintText: 'Buscar emprendedores...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey[600],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                suffixIcon: Obx(() {
                  if (controller.hasActiveSearch) {
                    return IconButton(
                      icon: Icon(Icons.clear, size: 20),
                      onPressed: () => controller.clearSearch(),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Filtro por categoría
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedCategoria.value.isEmpty ? null : controller.selectedCategoria.value,
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white30 : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white30 : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                  ),
                ),
                filled: true,
                fillColor: isDark ? Color(0xFF1E293B) : Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              dropdownColor: isDark ? Color(0xFF1E293B) : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text('Todas las categorías'),
                ),
                ...controller.categorias.map((categoria) => DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                )),
              ],
              onChanged: (value) => controller.filterByCategoria(value ?? ''),
            )),
          ),
          
          SizedBox(width: 8),
          
          // Filtro por ubicación
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedUbicacion.value.isEmpty ? null : controller.selectedUbicacion.value,
              decoration: InputDecoration(
                labelText: 'Ubicación',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white30 : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white30 : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                  ),
                ),
                filled: true,
                fillColor: isDark ? Color(0xFF1E293B) : Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              dropdownColor: isDark ? Color(0xFF1E293B) : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text('Todas las ubicaciones'),
                ),
                ...controller.ubicaciones.map((ubicacion) => DropdownMenuItem<String>(
                  value: ubicacion,
                  child: Text(ubicacion),
                )),
              ],
              onChanged: (value) => controller.filterByUbicacion(value ?? ''),
            )),
          ),
          
          SizedBox(width: 8),
          
          // Botón limpiar filtros
          Obx(() {
            if (controller.hasActiveFilters || controller.hasActiveSearch) {
              return IconButton(
                onPressed: () => controller.clearAll(),
                icon: Icon(
                  Icons.clear_all,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
                tooltip: 'Limpiar filtros',
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildPaginationInfo(bool isDark) {
    return Obx(() {
      if (controller.totalItems.value == 0) return SizedBox.shrink();
      
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.paginationInfo,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              controller.pageInfo,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmprendedoresList(bool isDark) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshEmprendedores(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              controller.canLoadMore) {
            controller.loadMoreEmprendedores();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.emprendedores.length + (controller.canLoadMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.emprendedores.length) {
              // Mostrar indicador de carga al final
              return _buildLoadMoreIndicator(isDark);
            }
            
            final emprendedor = controller.emprendedores[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EmprendedorCard(
                emprendedor: emprendedor,
                onTap: () => controller.navigateToDetail(emprendedor),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isDark) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cargando más...',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      return SizedBox.shrink();
    });
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
            'Cargando emprendedores...',
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
                    'Error al cargar emprendedores',
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
                    onPressed: () => controller.refreshEmprendedores(),
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
                    Icons.business_outlined,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay emprendedores disponibles',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pronto tendremos más emprendedores para ti',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshEmprendedores(),
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text('Recargar', style: TextStyle(color: Colors.white)),
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