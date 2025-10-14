// lib/features/municipalidades/presentation/widgets/municipalidad_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/municipalidad.dart';

class MunicipalidadCard extends StatelessWidget {
  final MunicipalidadEntity municipalidad;
  final VoidCallback? onTap;
  final VoidCallback? onEdit; // ✅ Nuevo callback

  const MunicipalidadCard({
    super.key,
    required this.municipalidad,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Título + botón Editar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Text(
                      municipalidad.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, size: 18, color: Colors.amber[800]),
                  label: const Text(
                    'Editar',
                    style: TextStyle(),
                  ),
                  style: TextButton.styleFrom(foregroundColor: Colors.amber[800]),
                ),
              ],
            ),

            const SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              child: Text(
                municipalidad.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                if (municipalidad.redFacebook != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.facebook, color: Colors.amber[800]),
                  ),
                if (municipalidad.redInstagram != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.camera_alt, color: Colors.amber[800]),
                  ),
                if (municipalidad.redYoutube != null)
                  Icon(Icons.play_circle_fill, color: Colors.amber[800]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
