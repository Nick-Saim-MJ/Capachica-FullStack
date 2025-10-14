# Selectores de Coordenadas para Asociaciones

Este directorio contiene tres implementaciones diferentes para seleccionar coordenadas geográficas en el formulario de asociaciones:

## 1. MapCoordinateSelector (MapBox)

**Archivo:** `map_coordinate_selector.dart`

**Características:**
- Usa MapBox Maps Flutter
- Interfaz más moderna y profesional
- Marcadores personalizados
- Animaciones suaves
- Mayor precisión en el renderizado

**Dependencias requeridas:**
```yaml
mapbox_maps_flutter: ^2.10.0
```

**Uso:**
```dart
import '../widgets/map_coordinate_selector.dart';

// En tu widget
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MapCoordinateSelector(
      initialLatitude: currentLat,
      initialLongitude: currentLng,
      onCoordinatesSelected: (latitude, longitude) {
        // Actualizar campos
        _latitudController.text = latitude.toStringAsFixed(6);
        _longitudController.text = longitude.toStringAsFixed(6);
      },
    ),
  ),
);
```

## 2. SimpleMapCoordinateSelector (MapBox Simplificado)

**Archivo:** `simple_map_coordinate_selector.dart`

**Características:**
- Usa MapBox Maps Flutter (versión simplificada)
- Solo funcionalidad de ubicación GPS
- Sin selección por tapping (más estable)
- Interfaz más simple y confiable

**Dependencias requeridas:**
```yaml
mapbox_maps_flutter: ^2.10.0
```

**Uso:**
```dart
import '../widgets/simple_map_coordinate_selector.dart';

// En tu widget
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SimpleMapCoordinateSelector(
      initialLatitude: currentLat,
      initialLongitude: currentLng,
      onCoordinatesSelected: (latitude, longitude) {
        // Actualizar campos
        _latitudController.text = latitude.toStringAsFixed(6);
        _longitudController.text = longitude.toStringAsFixed(6);
      },
    ),
  ),
);
```

## 3. FlutterMapCoordinateSelector (Flutter Map)

**Archivo:** `flutter_map_coordinate_selector.dart`

**Características:**
- Usa Flutter Map con OpenStreetMap
- Más ligero y rápido
- Menos dependencias externas
- Interfaz más simple

**Dependencias requeridas:**
```yaml
flutter_map: ^6.1.0
latlong2: ^0.8.1
```

**Uso:**
```dart
import '../widgets/flutter_map_coordinate_selector.dart';

// En tu widget
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FlutterMapCoordinateSelector(
      initialLatitude: currentLat,
      initialLongitude: currentLng,
      onCoordinatesSelected: (latitude, longitude) {
        // Actualizar campos
        _latitudController.text = latitude.toStringAsFixed(6);
        _longitudController.text = longitude.toStringAsFixed(6);
      },
    ),
  ),
);
```

## Funcionalidades Comunes

Ambos selectores incluyen:

### ✅ Selección por Tapping
- Toca en el mapa para seleccionar una ubicación
- Marcador visual en la posición seleccionada

### ✅ Ubicación Actual
- Botón para obtener la ubicación GPS actual
- Manejo de permisos automático
- Diálogos informativos para configuración

### ✅ Validación de Permisos
- Verificación automática de permisos de ubicación
- Guía al usuario para habilitar servicios de ubicación
- Manejo de errores robusto

### ✅ Interfaz Intuitiva
- Coordenadas mostradas en tiempo real
- Botón de confirmación
- Navegación fácil de usar

## Recomendaciones

### Usa MapCoordinateSelector cuando:
- Necesitas la máxima calidad visual
- Quieres selección por tapping en el mapa
- Tu aplicación maneja muchas ubicaciones
- Tienes presupuesto para servicios de MapBox

### Usa SimpleMapCoordinateSelector cuando:
- Quieres usar MapBox pero con mayor estabilidad
- Solo necesitas funcionalidad de ubicación GPS
- Prefieres una interfaz más simple
- Quieres evitar problemas con la API de tapping

### Usa FlutterMapCoordinateSelector cuando:
- Quieres una solución gratuita
- Necesitas una implementación rápida
- Tu aplicación es simple
- Prefieres menos dependencias externas

## Configuración de Permisos

Para que funcione la ubicación actual, asegúrate de tener estos permisos en tu `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Y en tu `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta aplicación necesita acceso a la ubicación para seleccionar coordenadas en el mapa.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Esta aplicación necesita acceso a la ubicación para seleccionar coordenadas en el mapa.</string>
```

## Integración en el Formulario

El formulario de asociaciones ya está configurado para usar `MapCoordinateSelector`. Para cambiar a Flutter Map:

1. Cambia el import en `asociacion_form_page.dart`:
```dart
// De:
import '../widgets/map_coordinate_selector.dart';
// A:
import '../widgets/flutter_map_coordinate_selector.dart';
```

2. Cambia la clase en el método `_selectCoordinates`:
```dart
// De:
MapCoordinateSelector(...)
// A:
FlutterMapCoordinateSelector(...)
```

¡Listo! Tu formulario ahora usará el selector alternativo.
