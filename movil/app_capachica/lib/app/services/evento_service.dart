import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/backend_config.dart';
import '../core/exceptions/api_exception.dart';
import '../data/models/evento_model.dart';

class EventoService {
  final http.Client _client = http.Client();

  // GET /api/eventos - Listar todos los eventos
  Future<List<Evento>> getAllEventos() async {
    try {
      print('🎉 EventoService: Obteniendo todos los eventos...');
      
      if (BackendConfig.testMode) {
        print('🧪 EventoService: Usando modo de prueba para todos los eventos');
        await Future.delayed(Duration(milliseconds: 800));
        return [
          Evento(
            id: 1,
            titulo: 'Festival de Música Andina',
            descripcion: 'Celebra la música tradicional de los Andes con artistas locales y nacionales',
            fecha: '2024-02-15',
            hora: '18:00',
            ubicacion: 'Plaza Principal de Capachica',
            imagenUrl: 'https://example.com/festival-musica.jpg',
            emprendedorId: 1,
            emprendedorNombre: 'Cultura Viva Capachica',
            emprendedorImagen: 'https://example.com/emprendedor1.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Cultural',
            precio: 25.0,
            capacidadMaxima: 200,
            estado: 'activo',
          ),
          Evento(
            id: 2,
            titulo: 'Feria Gastronómica del Lago',
            descripcion: 'Degusta los mejores platos típicos de la región del lago Titicaca',
            fecha: '2024-02-20',
            hora: '12:00',
            ubicacion: 'Malecón de Capachica',
            imagenUrl: 'https://example.com/feria-gastronomica.jpg',
            emprendedorId: 2,
            emprendedorNombre: 'Sabores del Titicaca',
            emprendedorImagen: 'https://example.com/emprendedor2.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Gastronomía',
            precio: 15.0,
            capacidadMaxima: 150,
            estado: 'activo',
          ),
          Evento(
            id: 3,
            titulo: 'Exposición de Artesanías',
            descripcion: 'Muestra de tejidos, cerámicas y artesanías tradicionales',
            fecha: '2024-02-10',
            hora: '10:00',
            ubicacion: 'Centro Cultural de Capachica',
            imagenUrl: 'https://example.com/exposicion-artesanias.jpg',
            emprendedorId: 3,
            emprendedorNombre: 'Artesanías Ancestrales',
            emprendedorImagen: 'https://example.com/emprendedor3.jpg',
            isActivo: false,
            isProximo: false,
            categoria: 'Artesanía',
            precio: 0.0,
            capacidadMaxima: 80,
            estado: 'finalizado',
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/eventos'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 EventoService: Todos los eventos response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> eventosData = data['data'] ?? data;
        return eventosData.map((json) => Evento.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo eventos: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ EventoService: Error obteniendo todos los eventos: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/eventos/proximos - Listar próximos eventos
  Future<List<Evento>> getEventosProximos() async {
    try {
      print('🎉 EventoService: Obteniendo próximos eventos...');
      
      if (BackendConfig.testMode) {
        print('🧪 EventoService: Usando modo de prueba para próximos eventos');
        await Future.delayed(Duration(milliseconds: 600));
        return [
          Evento(
            id: 1,
            titulo: 'Festival de Música Andina',
            descripcion: 'Celebra la música tradicional de los Andes con artistas locales y nacionales',
            fecha: '2024-02-15',
            hora: '18:00',
            ubicacion: 'Plaza Principal de Capachica',
            imagenUrl: 'https://example.com/festival-musica.jpg',
            emprendedorId: 1,
            emprendedorNombre: 'Cultura Viva Capachica',
            emprendedorImagen: 'https://example.com/emprendedor1.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Cultural',
            precio: 25.0,
            capacidadMaxima: 200,
            estado: 'activo',
          ),
          Evento(
            id: 2,
            titulo: 'Feria Gastronómica del Lago',
            descripcion: 'Degusta los mejores platos típicos de la región del lago Titicaca',
            fecha: '2024-02-20',
            hora: '12:00',
            ubicacion: 'Malecón de Capachica',
            imagenUrl: 'https://example.com/feria-gastronomica.jpg',
            emprendedorId: 2,
            emprendedorNombre: 'Sabores del Titicaca',
            emprendedorImagen: 'https://example.com/emprendedor2.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Gastronomía',
            precio: 15.0,
            capacidadMaxima: 150,
            estado: 'activo',
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/eventos/proximos'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 EventoService: Próximos eventos response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> eventosData = data['data'] ?? data;
        return eventosData.map((json) => Evento.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo próximos eventos: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ EventoService: Error obteniendo próximos eventos: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/eventos/activos - Listar eventos activos
  Future<List<Evento>> getEventosActivos() async {
    try {
      print('🎉 EventoService: Obteniendo eventos activos...');
      
      if (BackendConfig.testMode) {
        print('🧪 EventoService: Usando modo de prueba para eventos activos');
        await Future.delayed(Duration(milliseconds: 700));
        return [
          Evento(
            id: 1,
            titulo: 'Festival de Música Andina',
            descripcion: 'Celebra la música tradicional de los Andes con artistas locales y nacionales',
            fecha: '2024-02-15',
            hora: '18:00',
            ubicacion: 'Plaza Principal de Capachica',
            imagenUrl: 'https://example.com/festival-musica.jpg',
            emprendedorId: 1,
            emprendedorNombre: 'Cultura Viva Capachica',
            emprendedorImagen: 'https://example.com/emprendedor1.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Cultural',
            precio: 25.0,
            capacidadMaxima: 200,
            estado: 'activo',
          ),
          Evento(
            id: 2,
            titulo: 'Feria Gastronómica del Lago',
            descripcion: 'Degusta los mejores platos típicos de la región del lago Titicaca',
            fecha: '2024-02-20',
            hora: '12:00',
            ubicacion: 'Malecón de Capachica',
            imagenUrl: 'https://example.com/feria-gastronomica.jpg',
            emprendedorId: 2,
            emprendedorNombre: 'Sabores del Titicaca',
            emprendedorImagen: 'https://example.com/emprendedor2.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Gastronomía',
            precio: 15.0,
            capacidadMaxima: 150,
            estado: 'activo',
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/eventos/activos'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 EventoService: Eventos activos response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> eventosData = data['data'] ?? data;
        return eventosData.map((json) => Evento.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo eventos activos: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ EventoService: Error obteniendo eventos activos: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/eventos/{id} - Ver detalle de un evento específico
  Future<Evento> getEventoById(int id) async {
    try {
      print('🎉 EventoService: Obteniendo evento $id...');
      
      if (BackendConfig.testMode) {
        print('🧪 EventoService: Usando modo de prueba para evento $id');
        await Future.delayed(Duration(milliseconds: 500));
        
        return Evento(
          id: id,
          titulo: 'Festival de Música Andina',
          descripcion: 'Celebra la música tradicional de los Andes con artistas locales y nacionales. Una noche mágica llena de melodías ancestrales, danzas tradicionales y la mejor gastronomía local. No te pierdas esta experiencia única que conecta el pasado con el presente.',
          fecha: '2024-02-15',
          hora: '18:00',
          ubicacion: 'Plaza Principal de Capachica, Puno, Perú',
          imagenUrl: 'https://example.com/festival-musica.jpg',
          emprendedorId: 1,
          emprendedorNombre: 'Cultura Viva Capachica',
          emprendedorImagen: 'https://example.com/emprendedor1.jpg',
          isActivo: true,
          isProximo: true,
          categoria: 'Cultural',
          precio: 25.0,
          capacidadMaxima: 200,
          estado: 'activo',
        );
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/eventos/$id'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 EventoService: Evento $id response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventoData = data['data'] ?? data;
        return Evento.fromJson(eventoData);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Evento no encontrado');
      } else {
        throw ApiException(
          message: 'Error obteniendo evento: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ EventoService: Error obteniendo evento $id: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // GET /api/eventos/emprendedor/{emprendedorId} - Eventos de un emprendedor
  Future<List<Evento>> getEventosByEmprendedor(int emprendedorId) async {
    try {
      print('🎉 EventoService: Obteniendo eventos del emprendedor $emprendedorId...');
      
      if (BackendConfig.testMode) {
        print('🧪 EventoService: Usando modo de prueba para eventos del emprendedor $emprendedorId');
        await Future.delayed(Duration(milliseconds: 600));
        
        return [
          Evento(
            id: 1,
            titulo: 'Festival de Música Andina',
            descripcion: 'Celebra la música tradicional de los Andes con artistas locales y nacionales',
            fecha: '2024-02-15',
            hora: '18:00',
            ubicacion: 'Plaza Principal de Capachica',
            imagenUrl: 'https://example.com/festival-musica.jpg',
            emprendedorId: emprendedorId,
            emprendedorNombre: 'Cultura Viva Capachica',
            emprendedorImagen: 'https://example.com/emprendedor1.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Cultural',
            precio: 25.0,
            capacidadMaxima: 200,
            estado: 'activo',
          ),
          Evento(
            id: 4,
            titulo: 'Taller de Danzas Tradicionales',
            descripcion: 'Aprende las danzas ancestrales de la región del lago Titicaca',
            fecha: '2024-03-01',
            hora: '16:00',
            ubicacion: 'Centro Cultural de Capachica',
            imagenUrl: 'https://example.com/taller-danzas.jpg',
            emprendedorId: emprendedorId,
            emprendedorNombre: 'Cultura Viva Capachica',
            emprendedorImagen: 'https://example.com/emprendedor1.jpg',
            isActivo: true,
            isProximo: true,
            categoria: 'Educativo',
            precio: 30.0,
            capacidadMaxima: 50,
            estado: 'activo',
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/eventos/emprendedor/$emprendedorId'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 EventoService: Eventos emprendedor $emprendedorId response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> eventosData = data['data'] ?? data;
        return eventosData.map((json) => Evento.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Emprendedor no encontrado');
      } else {
        throw ApiException(
          message: 'Error obteniendo eventos del emprendedor: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ EventoService: Error obteniendo eventos del emprendedor $emprendedorId: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  void dispose() {
    _client.close();
  }
} 