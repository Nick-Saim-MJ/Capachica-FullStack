import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UbicacionMapaWidget extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(double lat, double lng) onLocationChanged;

  const UbicacionMapaWidget({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationChanged,
  });

  @override
  State<UbicacionMapaWidget> createState() => _UbicacionMapaWidgetState();
}

class _UbicacionMapaWidgetState extends State<UbicacionMapaWidget> {
  late LatLng _currentPosition;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    // Inicializar la posición con las coordenadas que vienen del formulario
    _currentPosition = LatLng(widget.initialLat, widget.initialLng);
    _mapController = MapController();
  }

  // --- Lógica de Interacción ---

  void _handleMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _currentPosition = latlng;
    });
    // Notificar al widget padre (el formulario) sobre el cambio de coordenadas
    widget.onLocationChanged(_currentPosition.latitude, _currentPosition.longitude);
  }

  // Si quieres que el marcador sea arrastrable (más complejo, pero mejor UX)
  void _handleMarkerDrag(DragUpdateDetails details, LatLng position) {
    setState(() {
      _currentPosition = position;
    });
    widget.onLocationChanged(_currentPosition.latitude, _currentPosition.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Muestra las coordenadas seleccionadas
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Lat: ${_currentPosition.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // 💡 Contenedor del Mapa
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 16.0, // Zoom apropiado para mostrar una ubicación específica
              onTap: _handleMapTap, // Permite seleccionar tocando el mapa
            ),
            children: [
              // 1. Capa de Tiles (Usamos OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.capachica.app',
              ),

              // 2. Capa de Marcadores (el punto de ubicación)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                    // Se puede agregar un GestureDetector para hacer el marcador arrastrable
                    // y usar el método _handleMarkerDrag
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}