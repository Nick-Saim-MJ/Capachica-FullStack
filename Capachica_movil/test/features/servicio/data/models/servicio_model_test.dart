import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServicioCapachica Tests', () {
    test('should create ServicioCapachica instance from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'nombre': 'Servicio Test',
        'descripcion': 'Descripción del servicio',
        'precio_referencial': '100.00',
        'emprendedor_id': 1,
        'estado': true,
        'created_at': '2023-01-01',
        'updated_at': '2023-01-02',
        'capacidad': 50,
        'latitud': '-15.123456',
        'longitud': '-70.123456',
        'ubicacion_referencia': 'Cerca de la plaza',
        'emprendedor': {
          'id': 1,
          'nombre': 'Emprendedor Test',
          'tipo_servicio': 'Restaurante',
          'descripcion': 'Descripción del emprendedor',
          'ubicacion': 'Ubicación test',
          'telefono': '123456789',
          'email': 'test@test.com',
          'pagina_web': 'www.test.com',
          'horario_atencion': '9am - 5pm',
          'precio_rango': '50-100',
          'metodos_pago': 'Efectivo, Tarjeta',
          'capacidad_aforo': 100,
          'numero_personas_atiende': 50,
          'comentarios_resenas': 'Buenos comentarios',
          'imagenes': 'imagen1.jpg',
          'categoria': 'Restaurante',
          'certificaciones': 'ISO 9001',
          'idiomas_hablados': 'Español, Inglés',
          'opciones_acceso': 'Accesible',
          'facilidades_discapacidad': true,
          'estado': true,
          'created_at': '2023-01-01',
          'updated_at': '2023-01-02',
          'asociacion_id': 1
        },
        'categorias': [
          {
            'id': 1,
            'nombre': 'Categoría Test',
            'descripcion': 'Descripción de categoría',
            'icono_url': 'icono.png',
            'created_at': '2023-01-01',
            'updated_at': '2023-01-02'
          }
        ],
        'horarios': [
          {
            'id': 1,
            'servicio_id': 1,
            'dia_semana': 'Lunes',
            'hora_inicio': '09:00',
            'hora_fin': '17:00',
            'activo': true,
            'created_at': '2023-01-01',
            'updated_at': '2023-01-02'
          }
        ],
        'sliders': ['slider1.jpg', 'slider2.jpg']
      };

      // Act
      final servicio = ServicioCapachica.fromJson(json);

      // Assert
      expect(servicio.id, 1);
      expect(servicio.nombre, 'Servicio Test');
      expect(servicio.precioReferencial, '100.00');
      expect(servicio.estado, true);
      expect(servicio.capacidad, 50);
      expect(servicio.latitud, '-15.123456');
      expect(servicio.longitud, '-70.123456');
      expect(servicio.categorias.length, 1);
      expect(servicio.horarios.length, 1);
      expect(servicio.sliders.length, 2);
    });

    test('should handle empty or null JSON values', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final servicio = ServicioCapachica.fromJson(json);

      // Assert
      expect(servicio.id, 0);
      expect(servicio.nombre, '');
      expect(servicio.precioReferencial, '0');
      expect(servicio.estado, false);
      expect(servicio.capacidad, 0);
      expect(servicio.categorias, isEmpty);
      expect(servicio.horarios, isEmpty);
      expect(servicio.sliders, isEmpty);
    });
  });

  group('EmprendedorCapachica Tests', () {
    test('should create EmprendedorCapachica instance from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'nombre': 'Emprendedor Test',
        'tipo_servicio': 'Restaurante',
        'descripcion': 'Descripción del emprendedor',
        'ubicacion': 'Ubicación test',
        'telefono': '123456789',
        'email': 'test@test.com',
        'pagina_web': 'www.test.com',
        'horario_atencion': '9am - 5pm',
        'precio_rango': '50-100',
        'metodos_pago': 'Efectivo, Tarjeta',
        'capacidad_aforo': 100,
        'numero_personas_atiende': 50,
        'comentarios_resenas': 'Buenos comentarios',
        'imagenes': 'imagen1.jpg',
        'categoria': 'Restaurante',
        'certificaciones': 'ISO 9001',
        'idiomas_hablados': 'Español, Inglés',
        'opciones_acceso': 'Accesible',
        'facilidades_discapacidad': true,
        'estado': true,
        'created_at': '2023-01-01',
        'updated_at': '2023-01-02',
        'asociacion_id': 1
      };

      // Act
      final emprendedor = EmprendedorCapachica.fromJson(json);

      // Assert
      expect(emprendedor.id, 1);
      expect(emprendedor.nombre, 'Emprendedor Test');
      expect(emprendedor.tipoServicio, 'Restaurante');
      expect(emprendedor.telefono, '123456789');
      expect(emprendedor.email, 'test@test.com');
      expect(emprendedor.estado, true);
      expect(emprendedor.capacidadAforo, 100);
    });

    test('should handle empty or null JSON values for Emprendedor', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final emprendedor = EmprendedorCapachica.fromJson(json);

      // Assert
      expect(emprendedor.id, 0);
      expect(emprendedor.nombre, '');
      expect(emprendedor.tipoServicio, '');
      expect(emprendedor.telefono, '');
      expect(emprendedor.email, '');
      expect(emprendedor.estado, false);
      expect(emprendedor.capacidadAforo, 0);
    });
  });

  group('CategoriaCapachica Tests', () {
    test('should create CategoriaCapachica instance from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'nombre': 'Categoría Test',
        'descripcion': 'Descripción de categoría',
        'icono_url': 'icono.png',
        'created_at': '2023-01-01',
        'updated_at': '2023-01-02'
      };

      // Act
      final categoria = CategoriaCapachica.fromJson(json);

      // Assert
      expect(categoria.id, 1);
      expect(categoria.nombre, 'Categoría Test');
      expect(categoria.descripcion, 'Descripción de categoría');
      expect(categoria.iconoUrl, 'icono.png');
    });

    test('should handle empty or null JSON values for Categoria', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final categoria = CategoriaCapachica.fromJson(json);

      // Assert
      expect(categoria.id, 0);
      expect(categoria.nombre, '');
      expect(categoria.descripcion, '');
      expect(categoria.iconoUrl, '');
    });
  });

  group('HorarioCapachica Tests', () {
    test('should create HorarioCapachica instance from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'servicio_id': 1,
        'dia_semana': 'Lunes',
        'hora_inicio': '09:00',
        'hora_fin': '17:00',
        'activo': true,
        'created_at': '2023-01-01',
        'updated_at': '2023-01-02'
      };

      // Act
      final horario = HorarioCapachica.fromJson(json);

      // Assert
      expect(horario.id, 1);
      expect(horario.servicioId, 1);
      expect(horario.diaSemana, 'Lunes');
      expect(horario.horaInicio, '09:00');
      expect(horario.horaFin, '17:00');
      expect(horario.activo, true);
    });

    test('should handle empty or null JSON values for Horario', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final horario = HorarioCapachica.fromJson(json);

      // Assert
      expect(horario.id, 0);
      expect(horario.servicioId, 0);
      expect(horario.diaSemana, '');
      expect(horario.horaInicio, '');
      expect(horario.horaFin, '');
      expect(horario.activo, false);
    });
  });
}
