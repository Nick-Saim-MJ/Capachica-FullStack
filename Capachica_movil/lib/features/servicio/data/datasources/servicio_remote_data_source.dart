// Archivo: lib/data/datasources/remote_data_source.dart

import 'dart:convert';
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/core/error/exceptions.dart';
import 'package:aplicativo_capachica/core/storage/secure_storage.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/mappers/servicio_mapper.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:http/http.dart' as http;

class ServicioRemoteDataSource {
  final String baseUrl;
  final AppSecureStorage secureStorage;

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  http.MultipartRequest _prepareMultipartRequest({
    required String method,
    required String url,
    required ServicioCapachica servicio,
    required String token,
  }) {
    final uri = Uri.parse(url);

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

    if (method == 'PUT') {
      request.fields['_method'] = 'PUT';
    }
    final Map<String, dynamic> data = ServiceMapper.toJson(servicio);

    data.forEach((key, value) {
      if (value != null && key != 'sliders') {
        request.fields[key] = value.toString();
      }
    });

    return request;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getToken();
    if (token == null) {
      throw Exception('Token de autenticación no encontrado. Inicie sesión.');
    }
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // Necesario para DELETE/PUT si no es multipart
    };
  }

  ServicioRemoteDataSource({String? baseUrl, required this.secureStorage})
      : baseUrl = baseUrl ?? BackendConfig.baseUrl;

  Future<List<ServicioCapachica>> fetchServicios() async {
    try {
      print('🔄 ServicesCapachicaProvider: Iniciando fetch de servicios...');
      print('🌐 ServicesCapachicaProvider: URL: $baseUrl/servicios');

      final response = await http.get(
        Uri.parse('$baseUrl/servicios'),
        headers: defaultHeaders,
      ).timeout(requestTimeout);

      print('📡 ServicesCapachicaProvider: Status code: ${response.statusCode}');
      print('📄 ServicesCapachicaProvider: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List<dynamic> data;
        if (decoded['data'] != null && decoded['data']['data'] != null) {
          data = decoded['data']['data'];
        } else if (decoded['data'] != null) {
          data = decoded['data'] is List ? decoded['data'] : [decoded['data']];
        } else {
          data = decoded is List ? decoded : [decoded];
        }

        final servicios = data.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios cargados exitosamente');
        return servicios;
      } else {
        print('❌ ServicesCapachicaProvider: Error HTTP ${response.statusCode}');
        throw Exception('Error al cargar los servicios: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServicios: $e');
      throw Exception('Error al cargar los servicios: $e');
    }
  }

  Future<ServicioCapachica> fetchServicioById(int id) async {
    try {
      print('🔄 ServicesCapachicaProvider: Obteniendo servicio con ID: $id');

      final response = await http.get(
        Uri.parse('$baseUrl/servicios/$id'),
        headers: defaultHeaders,
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] ?? decoded;
        final servicio = ServicioCapachica.fromJson(data);
        print('✅ ServicesCapachicaProvider: Servicio $id cargado exitosamente');
        return servicio;
      } else {
        throw Exception('Error al cargar el servicio: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServicioById: $e');
      throw Exception('Error al cargar el servicio: $e');
    }
  }

  Future<List<ServicioCapachica>> fetchServiciosByCategoria(int categoriaId) async {
    try {
      print('🔄 ServicesCapachicaProvider: Obteniendo servicios por categoría: $categoriaId');

      final response = await http.get(
        Uri.parse('$baseUrl/servicios/categoria/$categoriaId'),
        headers: defaultHeaders,
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> dataList;
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          // Aseguramos que 'data' sea una lista (si el servidor devuelve null o un solo objeto, manejamos eso)
          final dataField = decoded['data'];
          if (dataField is List) {
            dataList = dataField;
          } else if (dataField is Map<String, dynamic>) {
            // Si 'data' es un solo objeto (en lugar de una lista), lo envolvemos
            dataList = [dataField];
          } else {
            // Si 'data' es null o tiene un tipo inesperado
            dataList = [];
          }
        } else {
          // Si la respuesta no tiene la clave 'data' y asumimos que es directamente la lista (caso de error)
          dataList = decoded is List ? decoded : [];
        }


        final servicios = dataList.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios por categoría cargados');
        return servicios;
      } else {
        throw Exception('Error al cargar servicios por categoría: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServiciosByCategoria: $e');
      throw Exception('Error al cargar servicios por categoría: $e');
    }
  }

  Future<List<ServicioCapachica>> fetchServiciosByEmprendedor(int emprendedorId) async {
    try {
      print('🔄 ServicesCapachicaProvider: Obteniendo servicios por emprendedor: $emprendedorId');

      final response = await http.get(
        Uri.parse('$baseUrl/servicios/emprendedor/$emprendedorId'),
        headers: defaultHeaders,
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> data;
        if (decoded['data'] != null && decoded['data']['data'] != null) {
          data = decoded['data']['data'];
        } else if (decoded['data'] != null) {
          data = decoded['data'] is List ? decoded['data'] : [decoded['data']];
        } else {
          data = decoded is List ? decoded : [decoded];
        }

        final servicios = data.map((e) => ServicioCapachica.fromJson(e)).toList();
        print('✅ ServicesCapachicaProvider: ${servicios.length} servicios por emprendedor cargados');
        return servicios;
      } else {
        throw Exception('Error al cargar servicios por emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ServicesCapachicaProvider: Error en fetchServiciosByEmprendedor: $e');
      throw Exception('Error al cargar servicios por emprendedor: $e');
    }
  }
  Future<bool> verificarDisponibilidadServicio({
    required int servicioId,
    required String fecha,
    required String horaInicio,
    required String horaFin,
  }) async {
    final Map<String, dynamic> params = {
      'servicio_id': servicioId.toString(),
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
    };

    // Construir la URL con los parámetros de consulta (query parameters)
    final uri = Uri.parse('$baseUrl/servicios/verificar-disponibilidad').replace(
      queryParameters: params,
    );

    try {
      final response = await http.get(
        uri,
        headers: defaultHeaders,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // El JSON de Angular sugiere una respuesta como: { success: boolean, disponible: boolean }
        if (decoded is Map<String, dynamic> && decoded.containsKey('disponible')) {
          // Devolvemos directamente el valor booleano 'disponible'
          return decoded['disponible'] as bool;
        } else {
          // La respuesta del servidor no tiene el formato esperado
          throw const FormatException('Respuesta de disponibilidad en formato inválido.');
        }
      } else {
        throw Exception('Error de servidor (${response.statusCode}) al verificar disponibilidad.');
      }
    } catch (e) {
      print('❌ ServicioRemoteDataSource: Error al verificar disponibilidad: $e');
      throw Exception('Fallo en la conexión o parsing al verificar disponibilidad: $e');
    }
  }

  Future<ServicioCapachica> createServicio(ServicioRequestDTO servicioDto) async {
    final url = Uri.parse('$baseUrl/servicios');
    final token = await secureStorage.getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación disponible.');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // 💡 2. USO DEL DTO: Llamar a toJson() del ServicioRequestDTO
      body: json.encode(servicioDto.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      // 3. Devolver el modelo de respuesta (ServicioCapachica)
      return ServicioCapachica.fromJson(responseBody['data'] as Map<String, dynamic>);

    } else {
      String errorMessage;
      try {
        final responseBody = json.decode(response.body);
        errorMessage = responseBody['message'] ?? response.reasonPhrase ?? 'Error desconocido';
      } catch (_) {
        errorMessage = response.body.substring(0, response.body.length > 100 ? 100 : response.body.length);
        errorMessage = 'Respuesta no JSON: $errorMessage';
      }

      throw Exception('Fallo al crear servicio. Status: ${response.statusCode}. Mensaje: $errorMessage');
    }
  }

  Future<ServicioCapachica> updateServicio(int id, ServicioRequestDTO servicioDto) async {
    final uri = Uri.parse('$baseUrl/servicios/$id');
    final token = await secureStorage.getToken();
    if (token == null) {
      throw DataException('No hay token de autenticación para actualizar.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(servicioDto.toJson()),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return ServicioCapachica.fromJson(decoded['data'] as Map<String, dynamic>);

      } else if (response.statusCode == 404) {
        throw DataException('Error 404: Servicio con ID $id no encontrado para actualizar.', statusCode: 404);
      } else if (response.statusCode == 422) {
        throw DataException(
          'Error de validación al actualizar servicio: ${decoded['message'] ?? response.reasonPhrase}',
          statusCode: 422,
        );
      } else {
        throw DataException('Fallo al actualizar el servicio. Status: ${response.statusCode}. Mensaje: ${decoded['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (e is DataException) rethrow;
      throw DataException('Error de conexión o serialización al actualizar servicio: $e');
    }
  }

  Future<void> deleteServicio(int id) async {
    final uri = Uri.parse('$baseUrl/servicios/$id');
    final headers = await _getAuthHeaders();

    try {
      final response = await http.delete(
        uri,
        headers: headers,
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        // Éxito. No retorna datos, solo confirmación.
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Error 404: Servicio no encontrado para eliminar.');
      } else {
        throw Exception('Fallo al eliminar el servicio: ${decoded['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error de conexión al eliminar servicio: $e');
    }
  }
}