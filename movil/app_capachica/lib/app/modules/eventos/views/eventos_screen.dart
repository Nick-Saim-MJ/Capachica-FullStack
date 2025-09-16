import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/eventos_controller.dart';
import 'evento_card.dart';
import '../../../core/widgets/cart_bottom_sheet.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';

class EventosScreen extends GetView<EventosController> {
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
          'Eventos',
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
          Container(
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
                    decoration: InputDecoration(
                      hintText: 'Buscar eventos...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filtros de categorías
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todos', 0, isDark),
                _buildFilterChip('Próximos', 1, isDark),
                _buildFilterChip('Activos', 2, isDark),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Contenido de las pestañas
          Expanded(
            child: Obx(() {
              switch (controller.selectedTab.value) {
                case 0:
                  return _buildTodosTab(isDark);
                case 1:
                  return _buildProximosTab(isDark);
                case 2:
                  return _buildActivosTab(isDark);
                default:
                  return _buildTodosTab(isDark);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isDark) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == index;
      return Container(
        margin: EdgeInsets.only(right: 12),
        child: FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : Colors.grey[700]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) => controller.onTabChanged(index),
          backgroundColor: isDark ? Color(0xFF1E293B) : Colors.grey[200],
          selectedColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected 
                ? (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35))
                : Colors.transparent,
              width: 1,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTodosTab(bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState(isDark);
      }
      
      if (controller.error.value != null) {
        return _buildErrorState(isDark, controller.error.value!, () => controller.loadEventos());
      }
      
      if (controller.eventos.isEmpty) {
        return _buildEmptyState(isDark, 'No hay eventos disponibles');
      }
      
      return RefreshIndicator(
        onRefresh: controller.refreshEventos,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.eventos.length,
          itemBuilder: (context, index) {
            final evento = controller.eventos[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: EventoCard(
                evento: evento,
                onTap: () => controller.onEventoTap(evento),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildProximosTab(bool isDark) {
    return Obx(() {
      if (controller.isLoadingProximos.value) {
        return _buildLoadingState(isDark);
      }
      
      if (controller.errorProximos.value != null) {
        return _buildErrorState(isDark, controller.errorProximos.value!, () => controller.loadEventosProximos());
      }
      
      if (controller.eventosProximos.isEmpty) {
        return _buildEmptyState(isDark, 'No hay próximos eventos');
      }
      
      return RefreshIndicator(
        onRefresh: controller.refreshProximos,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.eventosProximos.length,
          itemBuilder: (context, index) {
            final evento = controller.eventosProximos[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: EventoCard(
                evento: evento,
                onTap: () => controller.onEventoTap(evento),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildActivosTab(bool isDark) {
    return Obx(() {
      if (controller.isLoadingActivos.value) {
        return _buildLoadingState(isDark);
      }
      
      if (controller.errorActivos.value != null) {
        return _buildErrorState(isDark, controller.errorActivos.value!, () => controller.loadEventosActivos());
      }
      
      if (controller.eventosActivos.isEmpty) {
        return _buildEmptyState(isDark, 'No hay eventos activos');
      }
      
      return RefreshIndicator(
        onRefresh: controller.refreshActivos,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.eventosActivos.length,
          itemBuilder: (context, index) {
            final evento = controller.eventosActivos[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: EventoCard(
                evento: evento,
                onTap: () => controller.onEventoTap(evento),
              ),
            );
          },
        ),
      );
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
            'Cargando eventos...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error, VoidCallback onRetry) {
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
                    Icons.error_outline_rounded,
                    size: 64,
                    color: isDark ? Colors.red[400] : Colors.red[600],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar eventos',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    error,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(Icons.refresh_rounded, color: Colors.white),
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

  Widget _buildEmptyState(bool isDark, String message) {
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
                    Icons.event_busy_rounded,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pronto tendremos nuevos eventos para ti',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
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