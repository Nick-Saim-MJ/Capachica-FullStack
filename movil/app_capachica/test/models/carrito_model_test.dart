// test/models/carrito_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_capachica/app/data/models/carrito_model.dart';

void main() {
  group('CarritoItem Model', () {
    test('fromJson con camelCase', () {
      final json = {
        'id': 1,
        'servicioId': 7,
        'nombre': 'Servicio X',
        'descripcion': 'Desc',
        'precio': 50.0,
        'imagenUrl': 'img.jpg',
        'cantidad': 2,
        'fechaReserva': '2024-01-01T00:00:00Z',
        'horaReserva': '10:00',
        'notas': 'Notas',
        'fechaCreacion': '2024-01-01T08:00:00Z',
      };

      final item = CarritoItem.fromJson(json);

      expect(item.id, 1);
      expect(item.servicioId, 7);
      expect(item.nombre, 'Servicio X');
      expect(item.descripcion, 'Desc');
      expect(item.precio, 50.0);
      expect(item.imagenUrl, 'img.jpg');
      expect(item.cantidad, 2);
      expect(item.fechaReserva, DateTime.parse('2024-01-01T00:00:00Z'));
      expect(item.horaReserva, '10:00');
      expect(item.notas, 'Notas');
      expect(item.subtotal, 100.0); // 50 * 2
    });

    test('fromJson con snake_case (fallback)', () {
      final json = {
        'id': 2,
        'servicio_id': 9,
        'nombre': 'Servicio Y',
        'descripcion': 'Otra desc',
        'precio': 80.0,
        'imagen_url': 'img2.jpg',
        'cantidad': 3,
        'fecha_reserva': '2024-02-01T00:00:00Z',
        'hora_reserva': '11:00',
        'notas': 'Notas 2',
        'fecha_creacion': '2024-02-01T08:00:00Z',
      };

      final item = CarritoItem.fromJson(json);

      expect(item.id, 2);
      expect(item.servicioId, 9);
      expect(item.nombre, 'Servicio Y');
      expect(item.descripcion, 'Otra desc');
      expect(item.precio, 80.0);
      expect(item.imagenUrl, 'img2.jpg');
      expect(item.cantidad, 3);
      expect(item.fechaReserva, DateTime.parse('2024-02-01T00:00:00Z'));
      expect(item.horaReserva, '11:00');
      expect(item.notas, 'Notas 2');
      expect(item.subtotal, 240.0); // 80 * 3
    });

    test('toJson (acepta camelCase o snake_case al validar)', () {
      final item = CarritoItem(
        id: 3,
        servicioId: 5,
        nombre: 'Servicio Z',
        descripcion: 'Desc Z',
        precio: 25.0,
        imagenUrl: 'img3.jpg',
        cantidad: 4,
        fechaReserva: DateTime.parse('2024-03-10T00:00:00Z'),
        horaReserva: '12:30',
        notas: 'Notas Z',
        fechaCreacion: DateTime.parse('2024-03-10T08:00:00Z'), // <-- agregado
      );

      final json = item.toJson();

      expect(json['id'], 3);
      expect(json['servicio_id'] ?? json['servicioId'], 5);
      expect(json['nombre'], 'Servicio Z');
      expect(json['descripcion'], 'Desc Z');
      expect((json['precio'] as num).toDouble(), 25.0);

      final img = json['imagen_url'] ?? json['imagenUrl'] ?? json['imagen'];
      expect(img, 'img3.jpg');

      expect(json['cantidad'], 4);

      final fechaStr = json['fecha_reserva'] ?? json['fechaReserva'];
      expect(DateTime.parse(fechaStr).toUtc(),
          DateTime.parse('2024-03-10T00:00:00Z'));

      final hora = json['hora_reserva'] ?? json['horaReserva'];
      expect(hora, '12:30');

      expect(json['notas'], 'Notas Z');
    });

    test('copyWith actualiza campos y respeta inmutabilidad', () {
      final original = CarritoItem(
        id: 10,
        servicioId: 77,
        nombre: 'Base',
        descripcion: 'D',
        precio: 10.0,
        imagenUrl: 'img.jpg',
        cantidad: 2,
        fechaReserva: DateTime.parse('2024-01-01T00:00:00Z'),
        horaReserva: '09:00',
        fechaCreacion: DateTime.parse('2024-01-01T08:00:00Z'), // <-- agregado
      );

      final updated = original.copyWith(
        cantidad: 5,
        notas: 'Actualizadas',
      );

      expect(updated.id, original.id);
      expect(updated.servicioId, original.servicioId);
      expect(updated.cantidad, 5);
      expect(updated.notas, 'Actualizadas');
      expect(updated.subtotal, 50.0); // 10 * 5
      expect(original.cantidad, 2);   // original intacto
    });
  });

  group('CarritoResponse Model', () {
    test('fromJson combina items y totales', () {
      final json = {
        'items': [
          {
            'id': 1,
            'servicioId': 1,
            'nombre': 'A',
            'descripcion': 'x',
            'precio': 40.0,
            'cantidad': 2,
          },
          {
            'id': 2,
            'servicioId': 2,
            'nombre': 'B',
            'descripcion': 'y',
            'precio': 10.0,
            'cantidad': 1,
          },
        ],
        'subtotal': 90.0,
        'total': 90.0,
        'totalItems': 3,
        'fechaCreacion': '2024-01-01T00:00:00Z',
      };

      final resp = CarritoResponse.fromJson(json);

      expect(resp.items.length, 2);
      expect(resp.subtotal, 90.0);
      expect(resp.total, 90.0);
      expect(resp.totalItems, 3);
    });

    test('toJson devuelve estructura con equivalencias de claves', () {
      final item = CarritoItem(
        id: 1,
        servicioId: 1,
        nombre: 'A',
        descripcion: 'x',
        precio: 40.0,
        cantidad: 2,
        fechaCreacion: DateTime.parse('2024-01-01T08:00:00Z'), // <-- agregado
      );

      final resp = CarritoResponse(
        items: [item],
        subtotal: 80.0,
        total: 80.0,
        totalItems: 2,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final json = resp.toJson();

      expect(json['items'], isA<List>());
      expect((json['subtotal'] as num).toDouble(), 80.0);
      expect((json['total'] as num).toDouble(), 80.0);
      final totalItems = json['total_items'] ?? json['totalItems'];
      expect(totalItems, 2);
    });
  });
}