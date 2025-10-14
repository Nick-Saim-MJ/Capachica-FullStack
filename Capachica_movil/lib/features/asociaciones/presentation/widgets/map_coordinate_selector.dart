import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapCoordinateSelector extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude) onCoordinatesSelected;

  const MapCoordinateSelector({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onCoordinatesSelected,
  });

  @override
  State<MapCoordinateSelector> createState() => _MapCoordinateSelectorState();
}

class _MapCoordinateSelectorState extends State<MapCoordinateSelector> {
  // Coordenadas por defecto: Llachon de Capachica, Puno, Perú
  static const double _defaultLatitude = -15.7251808;
  static const double _defaultLongitude = -69.7867735;
  
  mapbox.MapboxMap? mapboxMap;
  double? selectedLatitude;
  double? selectedLongitude;
  mapbox.PointAnnotationManager? pointAnnotationManager;
  mapbox.PointAnnotation? currentMarker;

  @override
  void initState() {
    super.initState();
    // Si hay coordenadas iniciales, usarlas; si no, usar Llachon
    selectedLatitude = widget.initialLatitude ?? _defaultLatitude;
    selectedLongitude = widget.initialLongitude ?? _defaultLongitude;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Seleccionar Ubicación',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
                  : [Colors.lightBlue.shade400, Colors.lightBlue.shade600],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location_rounded),
              tooltip: 'Mi ubicación',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          mapbox.MapWidget(
            styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
            cameraOptions: mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(
                  selectedLongitude ?? _defaultLongitude,
                  selectedLatitude ?? _defaultLatitude,
                ),
              ),
              zoom: 14.0, // Zoom más cercano para ver mejor la zona
            ),
            onMapCreated: (controller) async {
              mapboxMap = controller;
              await _createMarker();
            },
            onTapListener: (point) async {
              final coordinates = point.point.coordinates;
              setState(() {
                selectedLatitude = coordinates.lat.toDouble();
                selectedLongitude = coordinates.lng.toDouble();
              });
              await _updateMarker(coordinates.lat.toDouble(), coordinates.lng.toDouble());
              _showSuccessFeedback();
            },
          ),
          
          // Instrucciones superiores
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF1A1F2E).withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlue.shade400,
                          Colors.lightBlue.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Toca el mapa para seleccionar la ubicación',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Card de información inferior
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlue.shade400,
                          Colors.lightBlue.shade600,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Coordenadas Seleccionadas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Latitud
                        _CoordinateRow(
                          icon: Icons.north_rounded,
                          label: 'Latitud',
                          value: selectedLatitude?.toStringAsFixed(6) ?? 'No seleccionada',
                          color: Colors.blue,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        // Longitud
                        _CoordinateRow(
                          icon: Icons.east_rounded,
                          label: 'Longitud',
                          value: selectedLongitude?.toStringAsFixed(6) ?? 'No seleccionada',
                          color: Colors.green,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        
                        // Botón confirmar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: selectedLatitude != null && selectedLongitude != null
                                ? _confirmSelection
                                : null,
                            icon: const Icon(Icons.check_circle_rounded, size: 22),
                            label: const Text(
                              'Confirmar Ubicación',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: Colors.lightBlue.withOpacity(0.4),
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
        ],
      ),
    );
  }
  
  void _showSuccessFeedback() {
    // Vibración suave (si está disponible)
    // HapticFeedback.lightImpact();
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
    // Crear un marcador personalizado más atractivo
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 60.0;
    final centerX = size / 2;
    final centerY = size / 2;
    
    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(centerX + 2, centerY + 2), 18, shadowPaint);
    
    // Círculo exterior (borde blanco)
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 20, outerPaint);
    
    // Círculo interior (light blue gradient simulado)
    final innerPaint = Paint()
      ..color = Colors.lightBlue.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 16, innerPaint);
    
    // Círculo central (más oscuro)
    final centralPaint = Paint()
      ..color = Colors.lightBlue.shade600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 8, centralPaint);
    
    // Punto central blanco
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 4, dotPaint);
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
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
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                ),
                SizedBox(height: 16),
                Text(
                  'Obteniendo ubicación...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.location_off_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Permisos de Ubicación'),
          ],
        ),
        content: const Text(
          'Para usar tu ubicación actual, necesitamos acceso a los servicios de ubicación. '
          'Puedes habilitarlo en la configuración de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.gps_off_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Servicios de Ubicación'),
          ],
        ),
        content: const Text(
          'Los servicios de ubicación están deshabilitados. '
          'Por favor, habilítalos en la configuración del dispositivo.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Entendido'),
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

// Widget para mostrar una fila de coordenadas
class _CoordinateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _CoordinateRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withOpacity(0.05)
            : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
