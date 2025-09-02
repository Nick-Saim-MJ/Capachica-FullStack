import 'package:flutter/material.dart';

class CartCard extends StatelessWidget {
  final Map<String, dynamic> reserva;
  final VoidCallback onEliminar;
  final VoidCallback onEditar;

  const CartCard({
    Key? key,
    required this.reserva,
    required this.onEliminar,
    required this.onEditar,
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
    final servicio = reserva['servicio'] as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
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
              // Imagen y detalles principales
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del servicio
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        child: _buildServiceImage(servicio, isDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Detalles del servicio
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            servicio['nombre'] ?? 'Sin nombre',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Color(0xFF1A202C),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Cantidad: ${reserva['cantidad']}',
                              style: TextStyle(
                                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'S/ ${reserva['precioTotal']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Color(0xFF10B981) : Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Separador
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 16),
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
              ),
              
              // Fecha y hora
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha y hora',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Color(0xFF718096),
                            ),
                          ),
                          Text(
                            '${reserva['fechaInicio']} ${reserva['horaInicio']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Color(0xFF1A202C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Separador
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 16),
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
              ),
              
              // Botones de acción
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botón Editar
                    Container(
                      decoration: BoxDecoration(
                        color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: onEditar,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                        ),
                        label: Text(
                          'Editar',
                          style: TextStyle(
                            color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón Eliminar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: onEliminar,
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildServiceImage(Map<String, dynamic> servicio, bool isDark) {
    String? imagenUrl = servicio['imagenUrl'];
    
    // Validar que la URL sea válida
    bool isValidUrl(String? url) {
      return url != null && url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));
    }

    // Si no hay URL válida, usar imagen de asset
    if (!isValidUrl(imagenUrl)) {
      return Image.asset(
        _getAssetImage((servicio['nombre'] ?? '').hashCode),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: isDark ? Color(0xFF334155) : Colors.grey[300],
          child: Icon(
            Icons.image_outlined,
            size: 32,
            color: isDark ? Colors.white30 : Colors.grey[600],
          ),
        ),
      );
    }

    // Si hay URL válida, intentar cargar la imagen de red
    return Image.network(
      imagenUrl!,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        _getAssetImage((servicio['nombre'] ?? '').hashCode),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: isDark ? Color(0xFF334155) : Colors.grey[300],
          child: Icon(
            Icons.image_outlined,
            size: 32,
            color: isDark ? Colors.white30 : Colors.grey[600],
          ),
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 80,
          height: 80,
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