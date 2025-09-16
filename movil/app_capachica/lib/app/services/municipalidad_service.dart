import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/backend_config.dart';
import '../core/exceptions/api_exception.dart';
import '../data/models/api_response_model.dart';
import '../data/models/slider_model.dart';
import '../data/models/municipalidad_model.dart';
import '../data/models/municipalidad_detalle_model.dart';

class MunicipalidadService {
  final http.Client _client = http.Client();

  // Método para verificar que la app funciona
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      print('🔍 MunicipalidadService: Realizando health check...');
      
      if (BackendConfig.testMode) {
        print('🧪 MunicipalidadService: Usando modo de prueba para health check');
        await Future.delayed(Duration(milliseconds: 500)); // Simular delay
        return ApiResponse.success(
          data: {
            'status': 'ok',
            'message': 'API funcionando correctamente',
            'timestamp': DateTime.now().toIso8601String(),
          },
          message: 'API funcionando correctamente',
        );
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 MunicipalidadService: Health check response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(data, (json) => Map<String, dynamic>.from(json));
      } else {
        throw ApiException(
          message: 'Error en health check: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ MunicipalidadService: Error en health check: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // Método para obtener sliders/banners promocionales
  Future<List<Slider>> getSliders() async {
    try {
      print('🔍 MunicipalidadService: Obteniendo sliders...');
      
      if (BackendConfig.testMode) {
        print('🧪 MunicipalidadService: Usando modo de prueba para sliders');
        await Future.delayed(Duration(milliseconds: 800)); // Simular delay
        return [
          Slider(
            id: 1,
            title: 'Banner Local',
            description: 'Banner de prueba local',
            imageUrl: '', // Forzar asset local
            linkUrl: '',
            isActive: true,
            order: 1,
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/sliders'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 MunicipalidadService: Sliders response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> slidersData = data['data'] ?? data;
        return slidersData.map((json) => Slider.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo sliders: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ MunicipalidadService: Error obteniendo sliders: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // Método para listar municipalidades
  Future<List<Municipalidad>> listMunicipalidades() async {
    try {
      print('🔍 MunicipalidadService: Obteniendo lista de municipalidades...');
      
      if (BackendConfig.testMode) {
        print('🧪 MunicipalidadService: Usando modo de prueba para municipalidades');
        await Future.delayed(Duration(milliseconds: 1000)); // Simular delay
        return [
          Municipalidad(
            id: 1,
            nombre: 'Municipalidad Distrital de Capachica',
            descripcion: 'La Municipalidad Distrital de Capachica es una institución pública que vela por el desarrollo sostenible del distrito a través de la promoción del turismo, conservación del medio ambiente y mejora de la calidad de vida de sus pobladores.',
            redFacebook: 'https://facebook.com/municipalidadcapachica',
            redInstagram: 'https://instagram.com/municapachica',
            redYoutube: 'https://youtube.com/municapachica',
            coordenadasX: '-15.6425000',
            coordenadasY: '-69.8330000',
            frase: '¡Bienvenidos a Capachica, Paraíso Turístico del Lago Titicaca!',
            comunidades: 'Capachica cuenta con 16 comunidades: Llachón, Cotos, Siale, Hilata, Isañura, San Cristóbal, Escallani, Chillora, Yapura, Collasuyo, Miraflores, Villa Lago, Capano, Ccotos, Yancaco y Central.',
            historiaFamilias: 'Las familias de Capachica han mantenido sus tradiciones ancestrales por generaciones, dedicándose principalmente a la agricultura, pesca y ahora al turismo vivencial.',
            historiaCapachica: 'Capachica es una península situada en el lago Titicaca con una rica historia preinca e inca. Durante la colonia española, se establecieron haciendas que luego dieron paso a comunidades campesinas que hoy preservan su cultura y patrimonio.',
            comite: 'El comité de desarrollo turístico de Capachica está formado por representantes de las comunidades, emprendedores locales y autoridades municipales.',
            mision: 'Promover el desarrollo sostenible del distrito mediante la gestión eficiente de recursos, servicios públicos de calidad y promoción del turismo vivencial, respetando la identidad cultural y el medio ambiente.',
            vision: 'Al 2030, ser un distrito modelo en turismo sostenible, con infraestructura adecuada, servicios de calidad y una población con mejor calidad de vida, preservando su identidad cultural y recursos naturales.',
            valores: 'Honestidad, Transparencia, Respeto al medio ambiente, Identidad cultural, Trabajo en equipo, Compromiso social',
            ordenanzaMunicipal: 'Ordenanza Municipal N° 015-2023-MDP que regula la actividad turística y establece estándares para la prestación de servicios turísticos en el distrito.',
            alianzas: 'Trabajamos en alianza con MINCETUR, DIRCETUR Puno, Programa TRC, PNUD, GIZ, y diversas universidades para la capacitación de emprendedores y promoción del turismo.',
            correo: 'informes@municapachica.gob.pe',
            horarioDeAtencion: 'Lunes a Viernes: 8:00 am - 4:00 pm',
            slidersPrincipales: [
              Slider(
                id: 1,
                title: 'Capachica Turística',
                description: 'Imágenes de la belleza natural de Capachica',
                imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                urlCompleta: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                isActive: true,
                order: 1,
              ),
              Slider(
                id: 2,
                title: 'Lago Titicaca',
                description: 'Vistas espectaculares del lago sagrado',
                imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b',
                urlCompleta: 'https://images.unsplash.com/photo-1464983953574-0892a716854b',
                isActive: true,
                order: 2,
              ),
            ],
            slidersSecundarios: [],
            isActive: true,
          ),
          Municipalidad(
            id: 2,
            nombre: 'Municipalidad de Llachón',
            descripcion: 'Municipalidad de la comunidad de Llachón, conocida por su turismo vivencial y hermosas vistas del lago Titicaca.',
            redFacebook: 'https://facebook.com/municipalidadllachon',
            redInstagram: 'https://instagram.com/munillachon',
            redYoutube: 'https://youtube.com/munillachon',
            coordenadasX: '-15.6500000',
            coordenadasY: '-69.8400000',
            frase: 'Llachón: Donde la tradición se encuentra con el turismo sostenible',
            comunidades: 'Llachón es una comunidad que forma parte del distrito de Capachica, conocida por su turismo vivencial y artesanías.',
            historiaFamilias: 'Las familias de Llachón han preservado sus costumbres ancestrales y hoy comparten su cultura con visitantes de todo el mundo.',
            historiaCapachica: 'Llachón es una de las comunidades más antiguas de la península, con una rica tradición pesquera y agrícola.',
            comite: 'El comité de turismo de Llachón trabaja en conjunto con las familias locales para ofrecer experiencias auténticas.',
            mision: 'Promover el turismo vivencial sostenible, preservando la cultura local y mejorando la calidad de vida de la comunidad.',
            vision: 'Ser un destino turístico reconocido por su autenticidad cultural y compromiso con la sostenibilidad.',
            valores: 'Tradición, Sostenibilidad, Hospitalidad, Respeto cultural, Trabajo comunitario',
            ordenanzaMunicipal: 'Cumplimos con las ordenanzas municipales y estándares de calidad turística.',
            alianzas: 'Trabajamos con organizaciones locales e internacionales para el desarrollo del turismo comunitario.',
            correo: 'info@llachon.com',
            horarioDeAtencion: 'Todos los días: 6:00 am - 8:00 pm',
            slidersPrincipales: [
              Slider(
                id: 3,
                title: 'Llachón Vivencial',
                description: 'Experiencias únicas en la comunidad',
                imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                urlCompleta: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                isActive: true,
                order: 1,
              ),
            ],
            slidersSecundarios: [],
            isActive: true,
          ),
        ];
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/municipalidad'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 MunicipalidadService: Municipalidades response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> municipalidadesData = data['data'] ?? data;
        return municipalidadesData.map((json) => Municipalidad.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Error obteniendo municipalidades: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ MunicipalidadService: Error obteniendo municipalidades: $e');
      if (e is ApiException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // Método para obtener una municipalidad específica
  Future<Municipalidad> getMunicipalidad(int id) async {
    try {
      print('🔍 MunicipalidadService: Obteniendo municipalidad con ID: $id');
      
      if (BackendConfig.testMode) {
        print('🧪 MunicipalidadService: Usando modo de prueba para municipalidad $id');
        await Future.delayed(Duration(milliseconds: 600)); // Simular delay
        return Municipalidad(
          id: id,
          nombre: 'Municipalidad de Capachica',
          descripcion: 'Municipalidad principal de la península de Capachica, ubicada en las orillas del lago Titicaca',
          isActive: true,
        );
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/municipalidad/$id'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 MunicipalidadService: Municipalidad $id response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final municipalidadData = data['data'] ?? data;
        return Municipalidad.fromJson(municipalidadData);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Municipalidad no encontrada');
      } else {
        throw ApiException(
          message: 'Error obteniendo municipalidad: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ MunicipalidadService: Error obteniendo municipalidad $id: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  // Método para obtener municipalidad con relaciones
  Future<MunicipalidadDetalle> getMunicipalidadConRelaciones(int id) async {
    try {
      print('🔍 MunicipalidadService: Obteniendo municipalidad $id con relaciones...');
      
      if (BackendConfig.testMode) {
        print('🧪 MunicipalidadService: Usando modo de prueba para municipalidad $id con relaciones');
        await Future.delayed(Duration(milliseconds: 1200)); // Simular delay
        
        final municipalidad = Municipalidad(
          id: id,
          nombre: 'Municipalidad de Capachica',
          descripcion: 'Municipalidad principal de la península de Capachica',
          isActive: true,
        );

        final servicios = [
          Servicio(
            id: 1,
            nombre: 'Paseo en Bote',
            descripcion: 'Recorrido por las islas flotantes',
            imagenUrl: 'https://example.com/servicio1.jpg',
            precio: 50.0,
            isActive: true,
          ),
          Servicio(
            id: 2,
            nombre: 'Hospedaje Local',
            descripcion: 'Alojamiento en casas de familias locales',
            imagenUrl: 'https://example.com/servicio2.jpg',
            precio: 80.0,
            isActive: true,
          ),
        ];

        final negocios = [
          Negocio(
            id: 1,
            nombre: 'Restaurante El Lago',
            descripcion: 'Comida típica de la región',
            imagenUrl: 'https://example.com/negocio1.jpg',
            ubicacion: 'Plaza Principal, Capachica',
            telefono: '+51 987 654 321',
            email: 'info@ellago.com',
            isActive: true,
          ),
          Negocio(
            id: 2,
            nombre: 'Artesanías Titicaca',
            descripcion: 'Productos artesanales locales',
            imagenUrl: 'https://example.com/negocio2.jpg',
            ubicacion: 'Calle Comercial, Capachica',
            telefono: '+51 987 654 322',
            email: 'info@artesanias.com',
            isActive: true,
          ),
        ];

        return MunicipalidadDetalle(
          municipalidad: municipalidad,
          servicios: servicios,
          negocios: negocios,
          estadisticas: {
            'total_servicios': servicios.length,
            'total_negocios': negocios.length,
            'visitantes_mes': 1500,
          },
        );
      }

      final response = await _client
          .get(
            Uri.parse('${BackendConfig.getBaseUrl()}/municipalidad/$id/relaciones'),
            headers: BackendConfig.defaultHeaders,
          )
          .timeout(BackendConfig.requestTimeout);

      print('📡 MunicipalidadService: Municipalidad $id con relaciones response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detalleData = data['data'] ?? data;
        return MunicipalidadDetalle.fromJson(detalleData);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Municipalidad no encontrada');
      } else {
        throw ApiException(
          message: 'Error obteniendo municipalidad con relaciones: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ MunicipalidadService: Error obteniendo municipalidad $id con relaciones: $e');
      if (e is ApiException || e is NotFoundException) rethrow;
      throw NetworkException(message: 'Error de conexión: $e');
    }
  }

  void dispose() {
    _client.close();
  }
} 