import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class FlutterMapCoordinateSelector extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude) onCoordinatesSelected;

  const FlutterMapCoordinateSelector({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onCoordinatesSelected,
  });

  @override
  State<FlutterMapCoordinateSelector> createState() => _FlutterMapCoordinateSelectorState();
}

class _FlutterMapCoordinateSelectorState extends State<FlutterMapCoordinateSelector> {
  late MapController mapController;
  LatLng? selectedPosition;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    selectedPosition = widget.initialLatitude != null && widget.initialLongitude != null
        ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Ubicación actual',
          ),
          IconButton(
            onPressed: _confirmSelection,
            icon: const Icon(Icons.check),
            tooltip: 'Confirmar',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedPosition ?? const LatLng(-12.0, -15.5), // Perú por defecto
              initialZoom: selectedPosition != null ? 15.0 : 10.0,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedPosition = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.aplicativo_capachica',
              ),
              if (selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedPosition!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Coordenadas seleccionadas:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latitud: ${selectedPosition?.latitude.toStringAsFixed(6) ?? 'No seleccionada'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Longitud: ${selectedPosition?.longitude.toStringAsFixed(6) ?? 'No seleccionada'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: selectedPosition != null ? _confirmSelection : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar Ubicación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton.small(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }

      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        selectedPosition = newPosition;
      });

      // Actualizar cámara del mapa
      mapController.move(newPosition, 15.0);

    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (mounted) Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener ubicación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos de Ubicación'),
        content: const Text(
          'Para usar tu ubicación actual, necesitamos acceso a los servicios de ubicación. '
          'Puedes habilitarlo en la configuración de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Servicios de Ubicación'),
        content: const Text(
          'Los servicios de ubicación están deshabilitados. '
          'Por favor, habilítalos en la configuración del dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    if (selectedPosition != null) {
      widget.onCoordinatesSelected(selectedPosition!.latitude, selectedPosition!.longitude);
      Navigator.of(context).pop();
    }
  }
}
