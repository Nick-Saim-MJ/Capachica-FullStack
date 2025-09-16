import 'package:flutter/material.dart';
import '../../../data/models/plan_model.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onTap;

  const PlanCard({super.key, required this.plan, required this.onTap});

  // Lista de imágenes de assets para asignar rotativamente
  static const List<String> _assetImages = [
    'assets/paquete-turistico1.jpg',
    'assets/paquete-turistico2.jpg',
    'assets/paquete-turistico3.jpg',
    'assets/paquete-turistico4.jpg',
    'assets/paquete-turistico-line1-1.jpg',
    'assets/paquete-turistico-line1-2.jpg',
    'assets/paquete-turistico-line2-1.jpg',
    'assets/paquete-turistico-line2-2.jpg',
    'assets/paquete-turistico-line3-1.jpg',
    'assets/paquete-turistico-line3-2.jpg',
    'assets/paquete-turistico-line4-1.jpg',
    'assets/paquete-turistico-line4-2.jpg',
  ];

  String _getAssetImage(int index) {
    return _assetImages[index % _assetImages.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.3)
              : Color(0xFFFF6B35).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1A2332) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen con overlay y badge de precio
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: Image.asset(
                        _getAssetImage(plan.id.hashCode),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          _buildPlaceholderImage(isDark),
                      ),
                    ),
                    // Gradiente overlay
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                    // Badge de precio
                    if (plan.precio != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark 
                                ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                                : [Color(0xFFFF6B35), Color(0xFFFF8E53)], // Naranja para modo claro
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isDark 
                                  ? Color(0xFF1E3A8A).withValues(alpha: 0.4)
                                  : Color(0xFFFF6B35).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.attach_money_rounded, 
                                   color: Colors.white, size: 18),
                              Text(
                                plan.precio!.toStringAsFixed(0),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Badge de duración
                    if (plan.duracion != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, 
                                   color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), size: 16),
                              SizedBox(width: 4),
                                                              Text(
                                  '${plan.duracion} días',
                                  style: TextStyle(
                                    color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    // Rating badge
                    if (plan.rating != null)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFC107).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, 
                                   color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                plan.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // Contenido del card
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del plan
                      Text(
                        plan.titulo,
                        style: TextStyle(
                          color: isDark ? Colors.white : Color(0xFF1A202C),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      // Ubicación si está disponible
                      if (plan.ubicacion != null && plan.ubicacion!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                plan.ubicacion!,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Color(0xFF718096),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 12),
                      // Descripción
                      if (plan.descripcion != null && plan.descripcion!.isNotEmpty)
                        Text(
                          plan.descripcion!,
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.9) : Color(0xFF4A5568),
                            fontSize: 15,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 16),
                      // Botón de acción moderno
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                              ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                              : [Color(0xFFFF6B35), Color(0xFFFF8E53)], // Naranja para modo claro
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                ? Color(0xFF1E3A8A).withValues(alpha: 0.3)
                                : Color(0xFFFF6B35).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.visibility_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ver detalles',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B35).withValues(alpha: 0.3),
            Color(0xFFFF8E53).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            SizedBox(height: 8),
            Text(
              'Imagen no disponible',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 