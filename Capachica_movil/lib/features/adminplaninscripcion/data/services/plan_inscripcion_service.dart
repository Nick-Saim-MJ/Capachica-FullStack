import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/backend_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../model/plan_inscripcion_model.dart';

abstract class PlanInscripcionService {
  Future<List<PlanInscripcionModel>> getInscripciones();
  Future<void> updateEstadoInscripcion(int id, String estado);

  // 👇 AGREGA ESTE MÉTODO
  Future<PlanInscripcionModel> createInscripcion(PlanInscripcionModel inscripcion);
}

class PlanInscripcionServiceImpl implements PlanInscripcionService {
  final http.Client client;
  final AppSecureStorage storage;

  PlanInscripcionServiceImpl({required this.client, required this.storage});

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.getToken();
    if (token == null) throw const ApiException(message: 'No autenticado', statusCode: 401);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<PlanInscripcionModel>> getInscripciones() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('${BackendConfig.getBaseUrl()}/admin/planes/inscripciones/todas'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['data'] is Map && responseBody['data']['data'] is List) {
        final List<dynamic> inscripcionesList = responseBody['data']['data'];
        return inscripcionesList.map((json) => PlanInscripcionModel.fromJson(json)).toList();
      }
    }
    throw ApiException(message: 'Error al obtener inscripciones', statusCode: response.statusCode);
  }

  @override
  Future<void> updateEstadoInscripcion(int id, String estado) async {
    final headers = await _getHeaders();
    final response = await client.patch(
      Uri.parse('${BackendConfig.getBaseUrl()}/inscripciones/$id/estado'),
      headers: headers,
      body: json.encode({'estado': estado}),
    );

    if (response.statusCode != 200) {
      throw ApiException(message: 'Error al actualizar estado', statusCode: response.statusCode);
    }
  }

  // 👇 NUEVA IMPLEMENTACIÓN
  @override
  Future<PlanInscripcionModel> createInscripcion(PlanInscripcionModel inscripcion) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('${BackendConfig.getBaseUrl()}/inscripciones'),
      headers: headers,
      body: json.encode(inscripcion.toJson()),
    );

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      // ⚠️ Ajusta esta línea si tu API devuelve el modelo en otra clave
      return PlanInscripcionModel.fromJson(responseBody['data']);
    } else {
      throw ApiException(message: 'Error al crear inscripción', statusCode: response.statusCode);
    }
  }
}
