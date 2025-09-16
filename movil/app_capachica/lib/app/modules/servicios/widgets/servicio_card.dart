import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/servicio_model.dart';

class ServicioCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback? onTap;

  const ServicioCard({
    Key? key,
    required this.servicio,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final imageUrl = _extractImageUrl(servicio);
    final nombre = _extractNombre(servicio) ?? 'Servicio';
    final descripcion = _extractDescripcion(servicio) ?? '';
    final emprendedorNombre = _extractEmprendedorNombre(servicio);
    final precioFmt = _extractPrecioFormateado(servicio) ?? 'S/ --';
    final tieneHorarios = _hasHorarios(servicio);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  ),
                )
              else
                _buildPlaceholderImage(),
              const SizedBox(height: 12),

              // Nombre
              Text(
                nombre,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // DescripciÃ³n
              if (descripcion.isNotEmpty)
                Text(
                  descripcion,
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Emprendedor (si existe)
              if (emprendedorNombre != null && emprendedorNombre.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.business_center_outlined,
                      size: 16,
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        emprendedorNombre,
                        style: textTheme.bodySmall?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // Precio + Horarios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    precioFmt,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                  if (tieneHorarios)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text('Ver horarios', style: textTheme.bodySmall),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== Helpers seguros frente a diferencias de modelo =====

  String? _extractImageUrl(Servicio s) {
    final d = s as dynamic;
    try {
      return (d.imagenPrincipal ??
          d.imagenUrl ??
          d.imageUrl ??
          d.coverUrl ??
          d.thumbnail) as String?;
    } catch (_) {
      return null;
    }
  }

  String? _extractNombre(Servicio s) {
    final d = s as dynamic;
    try {
      return (d.nombre ?? d.titulo ?? d.title) as String?;
    } catch (_) {
      return null;
    }
  }

  String? _extractDescripcion(Servicio s) {
    final d = s as dynamic;
    try {
      return (d.descripcion ?? d.descripcionCorta ?? d.description) as String?;
    } catch (_) {
      return null;
    }
  }

  String? _extractEmprendedorNombre(Servicio s) {
    final d = s as dynamic;
    try {
      // intenta objeto -> nombre; si no, un string directo
      if (d.emprendedor != null) {
        final emp = d.emprendedor;
        if (emp is Map && emp['nombre'] != null) return emp['nombre'] as String;
        try {
          final nombre = emp.nombre as String?;
          if (nombre != null) return nombre;
        } catch (_) {}
      }
      return (d.emprendedorNombre ??
          d.nombreEmprendedor ??
          d.ownerName ??
          d.providerName) as String?;
    } catch (_) {
      return null;
    }
  }

  String? _extractPrecioFormateado(Servicio s) {
    final d = s as dynamic;
    try {
      final directo = d.precioFormateado as String?;
      if (directo != null) return directo;

      final p = (d.precio ?? d.price) as num?;
      if (p == null) return null;
      return 'S/ ${p.toStringAsFixed(2)}';
    } catch (_) {
      return null;
    }
  }

  bool _hasHorarios(Servicio s) {
    final d = s as dynamic;
    try {
      if (d.tieneHorarios == true) return true;
      final list = d.horarios as List?;
      return list != null && list.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.work_outline,
        size: 48,
        color: Get.theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}