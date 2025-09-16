import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/eventos_controller.dart';
import '../../../data/models/evento_model.dart';
import 'evento_card.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import '../../../core/widgets/theme_toggle_button.dart';

class EventoDetailScreen extends GetView<EventosController> {
  final Evento? evento;

  const EventoDetailScreen({Key? key, this.evento}) : super(key: key);

  // Lista de imágenes de assets para asignar rotativamente
  static const List<String> _assetImages = [
    'assets/lugar-turistico1.jpg',
    'assets/lugar-turistico2.jpg',
    'assets/lugar-turistico3.jpg',
    'assets/lugar-turistico4.jpg',
    'assets/lugar-turistico5.jpg',
    'assets/lugar-turistico6.jpg',
    'assets/lugar-turistico-line1-1.jpg',
    'assets/lugar-turistico-line1-2.jpg',
    'assets/lugar-turistico-line2-1.jpg',
    'assets/lugar-turistico-line2-2.jpg',
    'assets/lugar-turistico-line3-1.jpg',
    'assets/lugar-turistico-line3-2.jpg',
    'assets/lugar-turistico-line4-1.jpg',
    'assets/lugar-turistico-line4-2.jpg',
    'assets/lugar-turistico-line5-1.jpg',
    'assets/lugar-turistico-line5-2.jpg',
  ];

  String _getAssetImage(int index) {
    return _assetImages[index % _assetImages.length];
  }

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
          'Detalle del Evento',
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
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareEvento(evento),
          ),
          const CartIconWithBadge(),
          const ThemeToggleButton(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetalle.value) {
          return _buildLoadingState(isDark);
        }
        
        if (controller.errorDetalle.value != null) {
          return _buildErrorState(isDark);
        }
        
        final evento = this.evento ?? controller.eventoSeleccionado.value;
        if (evento == null) {
          return _buildNotFoundState(isDark);
        }
        
        return _buildEventoDetail(isDark, evento);
      }),
    );
  }

  Widget _buildEventoDetail(bool isDark, Evento evento) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen principal optimizada
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 240,
              width: double.infinity,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Image.asset(
                    _getAssetImage(evento.id.hashCode),
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Contenido principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y precio
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                evento.titulo,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Color(0xFF1A202C),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                evento.precio != null && evento.precio! > 0
                                    ? 'S/ ${evento.precio!.toStringAsFixed(0)}'
                                    : 'Gratis',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatusChip(isDark, evento),
                            SizedBox(width: 10),
                            if (evento.categoria != null)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  evento.categoria!,
                                  style: TextStyle(
                                    color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Información del evento
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Evento',
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1A202C),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Fecha',
                          evento.fecha,
                          isDark,
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.access_time,
                          'Hora',
                          evento.hora,
                          isDark,
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on,
                          'Ubicación',
                          evento.ubicacion,
                          isDark,
                        ),
                        if (evento.capacidadMaxima != null) ...[
                          SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.people,
                            'Capacidad',
                            '${evento.capacidadMaxima} personas',
                            isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Descripción
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripción',
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1A202C),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          evento.descripcion,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Color(0xFF718096),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Organizador
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organizador',
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1A202C),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.person,
                                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    evento.emprendedorNombre,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Color(0xFF1A202C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Organizador del evento',
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
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Color(0xFF718096),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Color(0xFF1A202C),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isDark, Evento evento) {
    Color chipColor;
    Color textColor;
    String text;
    IconData icon;

    if (evento.isActivo && evento.isProximo) {
      chipColor = Colors.green;
      textColor = Colors.white;
      text = 'Próximo';
      icon = Icons.upcoming;
    } else if (evento.isActivo) {
      chipColor = isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35);
      textColor = Colors.white;
      text = 'Activo';
      icon = Icons.play_circle_outline;
    } else {
      chipColor = Colors.grey;
      textColor = Colors.white;
      text = 'Finalizado';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
            'Cargando evento...',
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
                    'Error al cargar el evento',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.errorDetalle.value ?? 'Error desconocido',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (evento != null) {
                        controller.loadEventoDetalle(evento!.id);
                      }
                    },
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

  Widget _buildNotFoundState(bool isDark) {
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
                    Icons.event_busy,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Evento no encontrado',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'El evento que buscas no existe o ha sido eliminado',
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

  void _shareEvento(Evento? evento) {
    Get.snackbar(
      'Compartir',
      'Funcionalidad de compartir próximamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: (Get.isDarkMode ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }
} 