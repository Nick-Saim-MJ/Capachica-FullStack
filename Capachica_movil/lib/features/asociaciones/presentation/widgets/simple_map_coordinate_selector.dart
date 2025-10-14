import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SimpleMapCoordinateSelector extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude) onCoordinatesSelected;

  const SimpleMapCoordinateSelector({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onCoordinatesSelected,
  });

  @override
  State<SimpleMapCoordinateSelector> createState() => _SimpleMapCoordinateSelectorState();
}

class _SimpleMapCoordinateSelectorState extends State<SimpleMapCoordinateSelector> {
  mapbox.MapboxMap? mapboxMap;
  double? selectedLatitude;
  double? selectedLongitude;
  mapbox.PointAnnotationManager? pointAnnotationManager;
  mapbox.PointAnnotation? currentMarker;

  @override
  void initState() {
    super.initState();
    selectedLatitude = widget.initialLatitude;
    selectedLongitude = widget.initialLongitude;
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
          mapbox.MapWidget(
            styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
            cameraOptions: mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(
                  selectedLongitude ?? -15.5, // Longitud por defecto (Perú)
                  selectedLatitude ?? -12.0,  // Latitud por defecto (Perú)
                ),
              ),
              zoom: selectedLatitude != null ? 15.0 : 10.0,
            ),
            onMapCreated: (controller) async {
              mapboxMap = controller;
              await _createMarker();
            },
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
                      'Latitud: ${selectedLatitude?.toStringAsFixed(6) ?? 'No seleccionada'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Longitud: ${selectedLongitude?.toStringAsFixed(6) ?? 'No seleccionada'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Ubicación Actual'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: selectedLatitude != null && selectedLongitude != null
                                ? _confirmSelection
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('Confirmar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createMarker() async {
    if (mapboxMap != null && selectedLatitude != null && selectedLongitude != null) {
      pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
      await _updateMarker(selectedLatitude!, selectedLongitude!);
    }
  }

  Future<void> _updateMarker(double lat, double lng) async {
    if (pointAnnotationManager != null) {
      // Eliminar marcador anterior si existe
      if (currentMarker != null) {
        await pointAnnotationManager!.delete(currentMarker!);
      }

      // Crear nuevo marcador
      currentMarker = await pointAnnotationManager!.create(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(coordinates: mapbox.Position(lng, lat)),
          image: await _createMarkerImage(),
          iconSize: 1.0,
        ),
      );
    }
  }

  Future<Uint8List> _createMarkerImage() async {
    // Crear una imagen simple para el marcador
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(const Offset(20, 20), 15, paint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(40, 40);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
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

      setState(() {
        selectedLatitude = position.latitude;
        selectedLongitude = position.longitude;
      });

      // Actualizar cámara del mapa
      await mapboxMap?.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(coordinates: mapbox.Position(position.longitude, position.latitude)),
          zoom: 15.0,
        ),
        mapbox.MapAnimationOptions(duration: 1000),
      );

      // Actualizar marcador
      await _updateMarker(position.latitude, position.longitude);

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
    if (selectedLatitude != null && selectedLongitude != null) {
      widget.onCoordinatesSelected(selectedLatitude!, selectedLongitude!);
      Navigator.of(context).pop();
    }
  }
}
