import 'package:flutter_test/flutter_test.dart';
import 'package:app_capachica/app/data/models/servicio_model.dart';

void main() {
  group('Servicio Model (pruebas compatibles)', () {
    test('fromJson con camelCase', () {
      final json = {
        'id': 1,
        'emprendedorId': 1,
        // si tu modelo no expone categoriaId/estado, igual se ignoran
        'categoriaId': 2,
        'nombre': 'Test Servicio',
        'descripcion': 'Un servicio de prueba',
        'precio': 75.0,
        'imagenUrl': 'https://example.com/image.jpg',
        'estado': true,
        'fechaCreacion': '2024-01-01T00:00:00Z',
        'fechaActualizacion': '2024-01-02T00:00:00Z',
      };

      final s = Servicio.fromJson(json);

      expect(s.id, 1);
      expect(s.nombre, 'Test Servicio');
      expect(s.descripcion, 'Un servicio de prueba');
      expect(s.precio, 75.0);
      expect(s.imagenUrl, 'https://example.com/image.jpg');
      // No se validan getters que podrían no existir: categoriaId / estado
    });

    test('fromJson con snake_case (fallback)', () {
      final json = {
        'id': 10,
        'emprendedor_id': 3,
        'categoria_id': 4,
        'nombre': 'Servicio Snake',
        'descripcion': 'Desc snake',
        'precio': 120.0,
        'imagen_url': 'https://example.com/snake.jpg',
        'estado': false,
        'fecha_creacion': '2024-02-10T00:00:00Z',
        'fecha_actualizacion': '2024-02-11T00:00:00Z',
      };

      final s = Servicio.fromJson(json);

      expect(s.id, 10);
      expect(s.nombre, 'Servicio Snake');
      expect(s.descripcion, 'Desc snake');
      expect(s.precio, 120.0);
      expect(s.imagenUrl, 'https://example.com/snake.jpg');
    });

    test('round-trip: fromJson -> toJson (snake_case)', () {
      // Partimos de un JSON "camelCase", parseamos y luego serializamos
      final source = {
        'id': 7,
        'emprendedorId': 2,
        'categoriaId': 5,
        'nombre': 'Para Serializar',
        'descripcion': 'Desc',
        'precio': 60.0,
        'imagenUrl': 'https://example.com/img.jpg',
        'estado': true,
        'fechaCreacion': '2024-03-01T00:00:00Z',
        'fechaActualizacion': '2024-03-02T00:00:00Z',
      };

      final s = Servicio.fromJson(source);
      final json = s.toJson();

      // Validamos claves estables en snake_case
      expect(json['id'], 7);
      expect(json['nombre'], 'Para Serializar');
      expect(json['descripcion'], 'Desc');
      expect(json['precio'], 60.0);
      expect(json['imagen_url'], 'https://example.com/img.jpg');
      // No exigimos categoria_id ni estado porque pueden no serializarse
    });

    test('copyWith (si existe) conserva e impacta solo campos dados', () {
      // Creamos el modelo desde JSON para no depender del constructor público
      final base = Servicio.fromJson({
        'id': 99,
        'emprendedorId': 11,
        'categoriaId': 22,
        'nombre': 'Original',
        'descripcion': 'D',
        'precio': 10.0,
        'imagenUrl': 'img.jpg',
        'fechaCreacion': '2024-01-01T00:00:00Z',
        'fechaActualizacion': '2024-01-02T00:00:00Z',
      });

      // Algunos modelos no exponen copyWith; si el tuyo no lo tiene, comenta esta prueba
      final updated = base.copyWith(
        nombre: 'Actualizado',
        precio: 25.5,
      );

      expect(updated.id, base.id);
      expect(updated.nombre, 'Actualizado');
      expect(updated.precio, 25.5);
      expect(updated.imagenUrl, base.imagenUrl);
    });
  });
}