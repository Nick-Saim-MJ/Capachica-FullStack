import 'package:flutter/material.dart';
import '../../../data/models/emprendedor_model.dart';

class EmprendedorCard extends StatelessWidget {
  final Emprendedor emprendedor;
  final VoidCallback onTap;

  const EmprendedorCard({
    Key? key,
    required this.emprendedor,
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
                        child: _buildEmprendedorImage(isDark),
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
                    // Chip de tipo de servicio
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          emprendedor.tipoServicio,
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 12
                          ),
                        ),
                      ),
                    ),
                    // Estado
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: emprendedor.estado ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          emprendedor.estado ? 'Activo' : 'Inactivo',
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
                              emprendedor.ubicacion,
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
                        emprendedor.nombre, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          color: isDark ? Colors.white : Color(0xFF1A202C),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      if (emprendedor.descripcion != null && emprendedor.descripcion!.isNotEmpty)
                        Text(
                          emprendedor.descripcion!, 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis, 
                          style: TextStyle(
                            fontSize: 14, 
                            color: isDark ? Colors.white70 : Color(0xFF718096),
                          ),
                        )
                      else
                        Text(
                          'Emprendedor local especializado en ${emprendedor.tipoServicio.toLowerCase()}', 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis, 
                          style: TextStyle(
                            fontSize: 14, 
                            color: isDark ? Colors.white70 : Color(0xFF718096),
                          ),
                        ),
                      SizedBox(height: 12),
                      
                      // Información de contacto
                      if (emprendedor.telefono != null && emprendedor.telefono!.isNotEmpty)
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.phone, 
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
                                    emprendedor.telefono!, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600, 
                                      color: isDark ? Colors.white : Color(0xFF1A202C),
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Teléfono de contacto', 
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: isDark ? Colors.white70 : Color(0xFF718096),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      
                      SizedBox(height: 12),
                      
                      // Servicios disponibles y botón
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.work, 
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
                                  emprendedor.servicios != null && emprendedor.servicios!.isNotEmpty
                                      ? '${emprendedor.servicios!.length} servicio${emprendedor.servicios!.length != 1 ? 's' : ''}'
                                      : 'Servicios disponibles', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600, 
                                    color: isDark ? Colors.white : Color(0xFF1A202C),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Ver detalles', 
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

  Widget _buildEmprendedorImage(bool isDark) {
    String? imagenUrl;
    
    try {
      // Intentar obtener la imagen principal
      if (emprendedor.imagen != null && emprendedor.imagen!.isNotEmpty) {
        imagenUrl = emprendedor.imagen;
      } else if (emprendedor.imagenes != null && emprendedor.imagenes!.isNotEmpty) {
        // Si no hay imagen principal, intentar obtener de la lista de imágenes
        final imgs = emprendedor.imagenes!;
        List<String> lista = [];
        
        if (imgs.startsWith('[') && imgs.endsWith(']')) {
          lista = imgs
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (imgs.contains(',')) {
          lista = imgs.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        } else {
          lista = [imgs];
        }
        
        if (lista.isNotEmpty && lista[0].isNotEmpty) {
          imagenUrl = lista[0];
        }
      }
    } catch (_) {}

    // Validar que la URL sea válida
    bool isValidUrl(String? url) {
      return url != null && (url.startsWith('http://') || url.startsWith('https://'));
    }

    // Si no hay URL válida, usar imagen de asset
    if (!isValidUrl(imagenUrl)) {
      return Image.asset(
        _getAssetImage(emprendedor.id.hashCode),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          width: double.infinity,
          color: isDark ? Color(0xFF334155) : Colors.grey[300],
          child: Icon(
            Icons.store,
            size: 64,
            color: isDark ? Colors.white30 : Colors.grey[600],
          ),
        ),
      );
    }

    // Si hay URL válida, intentar cargar la imagen de red
    return Image.network(
      imagenUrl!,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        _getAssetImage(emprendedor.id.hashCode),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 180,
          width: double.infinity,
          color: isDark ? Color(0xFF334155) : Colors.grey[300],
          child: Icon(
            Icons.store,
            size: 64,
            color: isDark ? Colors.white30 : Colors.grey[600],
          ),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 180,
          width: double.infinity,
          color: isDark ? Color(0xFF334155) : Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
              ),
            ),
          ),
        );
      },
    );
  }
} 