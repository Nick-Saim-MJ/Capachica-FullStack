// Archivo: lib/presentation/widgets/map_card_widget.dart

import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapCardWidget extends StatelessWidget {
  final ServiceEntity servicio;

  const MapCardWidget({
    super.key,
    required this.servicio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double? lat = double.tryParse(servicio.latitud);
    final double? lng = double.tryParse(servicio.longitud);

    final bool coordinatesValid = lat != null && lng != null;

    if (!coordinatesValid) {
      return const SizedBox.shrink();
    }

    final LatLng coordinates = LatLng(lat, lng);
    const double initialZoom = 16.0; // Zoom inicial para la vista del mapa

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación del Emprendimiento',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: coordinates,
                    initialZoom: initialZoom,
                    interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all // Permite pan, zoom, etc.
                    ),
                  ),
                  children: [
                    // 1. Capa de Tiles (El mapa base)
                    TileLayer(
                      // Usaremos OpenStreetMap como proveedor
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.aplicativo_capachica',
                      // Manejar la inversión de color para el modo oscuro (Opcional)
                      tileBuilder: isDark ? (context, tileWidget, tile) => ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.black, // Color para oscurecer/invertir
                          BlendMode.saturation,
                        ),
                        child: tileWidget,
                      ) : null,
                    ),

                    // 2. Marcador de Ubicación
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: coordinates,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: isDark ? Colors.redAccent : Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Texto de ubicación de referencia
            if (servicio.ubicacionReferencia.isNotEmpty)
              Text(
                'Referencia: ${servicio.ubicacionReferencia}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final mapsUrl = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
                  );
                  final webFallbackUrl = mapsUrl;

                  bool launched = false;
                  if (await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
                    launched = true;
                  }
                  else if (await launchUrl(webFallbackUrl, mode: LaunchMode.platformDefault)) {
                    launched = true;
                  }

                  if (!launched) {
                    _showSnackBar(context, 'No se pudo abrir Google Maps. Intenta instalar la aplicación o verifica tu conexión.',
                        backgroundColor: Colors.red, textColor: Colors.white);
                  }
                },
                icon: const Icon(Icons.pin_drop_outlined),
                label: const Text(
                  'Ir a Google Maps',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.amber[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {Color? backgroundColor, Color? textColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor ?? Colors.white)),
        backgroundColor: backgroundColor ?? Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}