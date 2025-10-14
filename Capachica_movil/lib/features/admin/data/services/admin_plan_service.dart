import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // <-- 1. IMPORTA 'dart:io' PARA USAR LA CLASE File

import '../../../../core/config/backend_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/admin_plan_model.dart';


class AdminPlanService {
  final http.Client client;
  final AppSecureStorage storage;

  AdminPlanService({required this.client, required this.storage});

  // Esta función no cambia, pero la usaremos un poco diferente
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.getToken();
    if (token == null) {
      throw const ApiException(message: 'Usuario no autenticado', statusCode: 401);
    }
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // El método getPlans() se queda igual.
  Future<List<AdminPlanModel>> getPlans() async {
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'application/json'; // Añadimos Content-Type para GET

    final response = await client.get(
      Uri.parse('${BackendConfig.getBaseUrl()}/admin/planes/todos'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['data'] is Map<String, dynamic>) {
        final paginatorObject = responseBody['data'];
        if (paginatorObject['data'] is List) {
          final List<dynamic> plansList = paginatorObject['data'];
          return plansList.map((json) => AdminPlanModel.fromJson(json)).toList();
        }
      }
      throw const ApiException(message: 'Formato de paginación inesperado desde el servidor.', statusCode: 500);
    } else {
      throw ApiException(message: 'Error al obtener los planes', statusCode: response.statusCode);
    }
  }

  // --- MÉTODO createPlan ACTUALIZADO PARA ENVIAR IMÁGENES ---
  Future<AdminPlanModel> createPlan(AdminPlanModel plan, File? imageFile) async {
    final headers = await _getAuthHeaders();
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BackendConfig.getBaseUrl()}/planes')
    );
    request.headers.addAll(headers);

    // Añade los campos de texto del plan como 'fields'
    request.fields.addAll({
      'nombre': plan.title,
      'descripcion': plan.description,
      'precio_total': plan.price.toString(),
      'duracion_dias': plan.duration.toString(),
      'estado': plan.isActive ? 'activo' : 'inactivo',
      'capacidad': plan.capacidad.toString(),
    });

    // Si se seleccionó un archivo de imagen, lo añade a la petición
    if (imageFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('imagen_principal', imageFile.path)
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      return AdminPlanModel.fromJson(responseBody['data']);
    } else {
      throw ApiException(message: 'Error al crear el plan', statusCode: response.statusCode);
    }
  }

  // --- MÉTODO updatePlan ACTUALIZADO PARA ENVIAR IMÁGENES ---
  Future<AdminPlanModel> updatePlan(AdminPlanModel plan, File? imageFile) async {
    final headers = await _getAuthHeaders();
    // Para enviar archivos con PUT, Laravel a veces prefiere un POST con un campo '_method'
    var request = http.MultipartRequest(
        'POST', // Usamos POST
        Uri.parse('${BackendConfig.getBaseUrl()}/planes/${plan.id}')
    );
    request.headers.addAll(headers);

    // Añade los campos, incluyendo el método PUT falso
    request.fields.addAll({
      '_method': 'PUT', // <-- Truco para que Laravel lo trate como una petición PUT
      'nombre': plan.title,
      'descripcion': plan.description,
      'precio_total': plan.price.toString(),
      'duracion_dias': plan.duration.toString(),
      'estado': plan.isActive ? 'activo' : 'inactivo',
      'capacidad': plan.capacidad.toString(),
    });

    if (imageFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('imagen_principal', imageFile.path)
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return AdminPlanModel.fromJson(responseBody['data']);
    } else {
      throw ApiException(message: 'Error al actualizar el plan', statusCode: response.statusCode);
    }
  }

  // El método deletePlan() se queda igual
  Future<void> deletePlan(int id) async {
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await client.delete(
      Uri.parse('${BackendConfig.getBaseUrl()}/planes/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(message: 'Error al eliminar el plan', statusCode: response.statusCode);
    }
  }
}