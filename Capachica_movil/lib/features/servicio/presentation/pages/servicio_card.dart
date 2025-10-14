import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_bloc.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceCard extends StatelessWidget {
  final ServiceEntity servicio;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final bool isAdmin;
  final bool isEmprendedor;
  final bool isMod;

  const ServiceCard({Key? key,
    required this.servicio,
    required this.onTap,
    required this.onEdit,
    required this.isAdmin,
    required this.isEmprendedor,
    required this.isMod,
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

    String capitalizeFirst(String s) {
      if (s.isEmpty) return s;
      return s[0].toUpperCase() + s.substring(1).toLowerCase();
    }

    // Obtener categoría principal
    final categoria = servicio.categorias.isNotEmpty ? servicio.categorias[0].nombre : 'Servicio';

    // Días disponibles
    final dias = servicio.horarios.map((h) {
      final dia = h.diaSemana;
      final shortDay = dia.length >= 3 ? dia.substring(0, 3) : dia;
      return capitalizeFirst(shortDay);
    }).toSet().toList();

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
                          _getAssetImage(servicio.id.hashCode),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 180,
                            width: double.infinity,
                            color: isDark ? Color(0xFF334155) : Colors.grey[300],
                            child: Icon(
                              Icons.image,
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
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          categoria,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                          ),
                        ),
                      ),
                    ),
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
                          'S/. ${servicio.precioReferencial}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                          ),
                        ),
                      ),
                    ),
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
                              servicio.ubicacionReferencia,
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
                        servicio.nombre,
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
                        servicio.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Color(0xFF718096),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Información del emprendedor
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber[800]!.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                                Icons.person,
                                color: Colors.amber[800],
                                size: 16
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  servicio.emprendedor.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Color(0xFF1A202C),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Emprendedor local',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : Color(0xFF718096),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Disponibilidad
                      if (dias.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.schedule, color: Colors.amber[800], size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Disponible:',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                children: dias.take(3).map((d) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                        color: Colors.amber[900],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10
                                    ),
                                  ),
                                )).toList()
                                  ..addAll(dias.length > 3 ? [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? Color(0xFF334155) : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '+${dias.length - 3}',
                                        style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10
                                        ),
                                      ),
                                    ),
                                  ] : []),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],

                      // Botón de acción
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          icon: Icon(Icons.info_outline, size: 18),
                          label: Text(
                            'Ver Detalles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          onPressed: onTap,
                        ),
                      ),

                      // ---------------------------------------------
                      // 💡 BOTONES DE ACCIÓN RÁPIDA AÑADIDOS
                      // ---------------------------------------------
                      const SizedBox(height: 12), // Espacio entre el botón principal y los de acción
                      if(isAdmin || isEmprendedor || isMod)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Editar
                          _buildActionButton(
                            context,
                            icon: Icons.edit,
                            label: 'Editar',
                            color: Colors.amber[800]!,
                            onPressed: () {
                              print('Editar servicio ${servicio.id}');
                              onEdit();
                            },
                          ),

                          // 2. Activar/Desactivar (Usamos el estado 'activo' del servicio)
                          _buildActionButton(
                            context,
                            icon: servicio.estado ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            label: servicio.estado ? 'Desactivar' : 'Activar',
                            color: servicio.estado ? Colors.red : Colors.amber[800]!,
                            onPressed: () {
                              print('${servicio.estado ? "Desactivar" : "Activar"} servicio ${servicio.id}');
                              context.read<ServicioBloc>().add(ToggleEstadoServicio(servicio));
                            },
                          ),

                          // 3. Ver Reservas
                          _buildActionButton(
                            context,
                            icon: Icons.calendar_month,
                            label: 'Reservas',
                            color: Colors.purple,
                            onPressed: () {
                              // TODO: Implementar navegación a la pantalla de reservas
                              print('Ver reservas de servicio ${servicio.id}');
                            },
                          ),

                          // 4. Eliminar
                          _buildActionButton(
                            context,
                            icon: Icons.delete_outline,
                            label: 'Eliminar',
                            color: Colors.grey.shade600,
                            onPressed: () {
                              _confirmDelete(context, servicio);
                            },
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
  void _confirmDelete(BuildContext context, ServiceEntity servicio) {
    final servicioBloc = context.read<ServicioBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el servicio "${servicio.nombre}"? Esta acción es irreversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Intentando eliminar "${servicio.nombre}"...')),
                );
                servicioBloc.add(DeleteServicioEvent(servicio.id));
              },
            ),
          ],
        );
      },
    );
  }
}
Widget _buildActionButton(
    BuildContext context, {
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed,
    }) {
  // Usamos Expanded para que los 4 botones ocupen el mismo ancho
  return Expanded(
    child: Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 20),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}