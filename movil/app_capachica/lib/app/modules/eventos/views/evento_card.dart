import 'package:flutter/material.dart';
import '../../../data/models/evento_model.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onTap;

  const EventoCard({
    Key? key,
    required this.evento,
    required this.onTap,
  }) : super(key: key);

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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen y chips
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        child: Image.asset(
                          _getAssetImage(evento.id.hashCode),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            width: double.infinity,
                            color: isDark ? Color(0xFF334155) : Colors.grey[300],
                            child: Icon(
                              Icons.event,
                              size: 64,
                              color: isDark ? Colors.white30 : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    // Chip de estado
                    Positioned(
                      left: 16,
                      top: 16,
                      child: _buildStatusChip(isDark),
                    ),
                    // Precio
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          evento.precio != null && evento.precio! > 0
                              ? 'S/ ${evento.precio!.toStringAsFixed(0)}'
                              : 'Gratis',
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 12
                          ),
                        ),
                      ),
                    ),
                    // Ubicación
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              evento.ubicacion,
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 12,
                                shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.titulo, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          color: isDark ? Colors.white : Color(0xFF1A202C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        evento.descripcion, 
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis, 
                        style: TextStyle(
                          fontSize: 14, 
                          color: isDark ? Colors.white70 : Color(0xFF718096),
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Fecha y hora
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today, 
                              color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                              size: 16
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evento.fecha, 
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600, 
                                    color: isDark ? Colors.white : Color(0xFF1A202C),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  evento.hora, 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: isDark ? Colors.white70 : Color(0xFF718096),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Información del emprendedor
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person, 
                              color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                              size: 16
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evento.emprendedorNombre, 
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600, 
                                    color: isDark ? Colors.white : Color(0xFF1A202C),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Organizador', 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    color: isDark ? Colors.white70 : Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón de detalles
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Ver más',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isDark) {
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
} 