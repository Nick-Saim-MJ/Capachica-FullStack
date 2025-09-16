import 'package:flutter_test/flutter_test.dart';
import 'package:app_capachica/app/data/models/emprendedor_model.dart';

void main() {
  group('Emprendedor Model Tests', () {
    test('should create Emprendedor from JSON with camelCase', () {
      // Arrange
      final json = {
        'id': 1,
        'nombre': 'Test Emprendedor',
        'tipoServicio': 'Restaurante',
        'ubicacion': 'Lima, Perú',
        'descripcion': 'Un restaurante de prueba',
        'telefono': '+51987654321',
        'email': 'test@example.com',
        'imagen': 'https://example.com/image.jpg',
        'estado': true,
        'fechaCreacion': '2024-01-01T00:00:00Z',
        'fechaActualizacion': '2024-01-01T00:00:00Z',
        'servicios': [],
        'relaciones': [],
      };

      // Act
      final emprendedor = Emprendedor.fromJson(json);

      // Assert
      expect(emprendedor.id, equals(1));
      expect(emprendedor.nombre, equals('Test Emprendedor'));
      expect(emprendedor.tipoServicio, equals('Restaurante'));
      expect(emprendedor.ubicacion, equals('Lima, Perú'));
      expect(emprendedor.descripcion, equals('Un restaurante de prueba'));
      expect(emprendedor.telefono, equals('+51987654321'));
      expect(emprendedor.email, equals('test@example.com'));
      expect(emprendedor.imagen, equals('https://example.com/image.jpg'));
      expect(emprendedor.estado, equals(true));
    });

    test('should create Emprendedor from JSON with snake_case fallback', () {
      // Arrange
      final json = {
        'id': 1,
        'nombre': 'Test Emprendedor',
        'tipo_servicio': 'Restaurante',
        'ubicacion': 'Lima, Perú',
        'descripcion': 'Un restaurante de prueba',
        'telefono': '+51987654321',
        'email': 'test@example.com',
        'imagen': 'https://example.com/image.jpg',
        'estado': true,
        'fecha_creacion': '2024-01-01T00:00:00Z',
        'fecha_actualizacion': '2024-01-01T00:00:00Z',
        'servicios': [],
        'relaciones': [],
      };

      // Act
      final emprendedor = Emprendedor.fromJson(json);

      // Assert
      expect(emprendedor.id, equals(1));
      expect(emprendedor.nombre, equals('Test Emprendedor'));
      expect(emprendedor.tipoServicio, equals('Restaurante'));
      expect(emprendedor.ubicacion, equals('Lima, Perú'));
    });

    test('should convert Emprendedor to JSON with snake_case', () {
      // Arrange
      final emprendedor = Emprendedor(
        id: 1,
        nombre: 'Test Emprendedor',
        tipoServicio: 'Restaurante',
        ubicacion: 'Lima, Perú',
        descripcion: 'Un restaurante de prueba',
        telefono: '+51987654321',
        email: 'test@example.com',
        imagen: 'https://example.com/image.jpg',
        estado: true,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00Z'),
        servicios: [],
        relaciones: [],
      );

      // Act
      final json = emprendedor.toJson();

      // Assert
      expect(json['id'], equals(1));
      expect(json['nombre'], equals('Test Emprendedor'));
      expect(json['tipo_servicio'], equals('Restaurante'));
      expect(json['ubicacion'], equals('Lima, Perú'));
      expect(json['descripcion'], equals('Un restaurante de prueba'));
      expect(json['telefono'], equals('+51987654321'));
      expect(json['email'], equals('test@example.com'));
      expect(json['imagen'], equals('https://example.com/image.jpg'));
      expect(json['estado'], equals(true));
    });

    test('should create copy with updated values', () {
      // Arrange
      final original = Emprendedor(
        id: 1,
        nombre: 'Original Name',
        tipoServicio: 'Restaurante',
        ubicacion: 'Lima, Perú',
        descripcion: 'Original description',
        telefono: '+51987654321',
        email: 'original@example.com',
        imagen: 'https://example.com/original.jpg',
        estado: true,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00Z'),
        servicios: [],
        relaciones: [],
      );

      // Act
      final updated = original.copyWith(
        nombre: 'Updated Name',
        descripcion: 'Updated description',
      );

      // Assert
      expect(updated.id, equals(original.id));
      expect(updated.nombre, equals('Updated Name'));
      expect(updated.descripcion, equals('Updated description'));
      expect(updated.tipoServicio, equals(original.tipoServicio));
      expect(updated.ubicacion, equals(original.ubicacion));
    });

    test('should return correct utility getters', () {
      // Arrange
      final emprendedor = Emprendedor(
        id: 1,
        nombre: 'Test Emprendedor',
        tipoServicio: 'Restaurante',
        ubicacion: 'Lima, Perú',
        descripcion: 'Un restaurante de prueba',
        telefono: '+51987654321',
        email: 'test@example.com',
        imagen: 'https://example.com/image.jpg',
        estado: true,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00Z'),
        servicios: [],
        relaciones: [],
      );

      // Act & Assert
      expect(emprendedor.imagenPrincipal, equals('https://example.com/image.jpg'));
      expect(emprendedor.tieneServicios, equals(false));
      expect(emprendedor.tieneRelaciones, equals(false));
      expect(emprendedor.telefonoFormateado, equals('+51987654321'));
    });
  });
}
