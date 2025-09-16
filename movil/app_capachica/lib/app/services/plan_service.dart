import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/backend_config.dart';
import '../core/exceptions/api_exception.dart';
import '../data/models/plan_model.dart';
import '../data/models/plan_detalle_model.dart';
import '../data/models/emprendedor_model.dart';

class PlanService {
  final String baseUrl = "http://localhost:8000/api";

  // 👉 Obtener TODOS los planes (admin, sin filtro)
  Future<List<Plan>> getAllPlanes() async {
    final response = await http.get(Uri.parse('$baseUrl/planes'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // 👇 Ojo: backend devuelve paginación => data['data']['data']
      final List<dynamic> planesData = data['data']['data'];
      return planesData.map((json) => Plan.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los planes');
    }
  }

  // 👉 Obtener planes públicos (ej: para usuarios normales)
  Future<List<Plan>> getPlanesPublicos() async {
    final response = await http.get(Uri.parse('$baseUrl/planes/publicos'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> planesData = data['data']['data']; // 👈 igual
      return planesData.map((json) => Plan.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los planes públicos');
    }
  }

  // 👉 Planes públicos para la landing
  Future<List<Plan>> getPlanesPublicosLanding() async {
    final response = await http.get(Uri.parse('$baseUrl/planes/landing'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> planesData = data['data']['data']; // 👈 igual
      return planesData.map((json) => Plan.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los planes para la landing');
    }
  }

  // 👉 Buscar planes
  Future<List<Plan>> searchPlanes({
    String? query,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? duracionMin,
    int? duracionMax,
    String? ubicacion,
  }) async {
    final uri = Uri.parse('$baseUrl/planes/search').replace(queryParameters: {
      if (query != null) 'query': query,
      if (categoria != null) 'categoria': categoria,
      if (precioMin != null) 'precio_min': precioMin.toString(),
      if (precioMax != null) 'precio_max': precioMax.toString(),
      if (duracionMin != null) 'duracion_min': duracionMin.toString(),
      if (duracionMax != null) 'duracion_max': duracionMax.toString(),
      if (ubicacion != null) 'ubicacion': ubicacion,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> planesData = data['data']['data']; // 👈 igual
      return planesData.map((json) => Plan.fromJson(json)).toList();
    } else {
      throw Exception('Error en la búsqueda de planes');
    }
  }

  // 👉 Obtener detalle de un plan
  Future<PlanDetalle> getPlanDetalle(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/planes/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final detalleData = data['data'] ?? data;
      return PlanDetalle.fromJson(detalleData);
    } else {
      throw Exception('Error al obtener el detalle del plan');
    }
  }

  // 👉 Obtener detalle de un plan público
  Future<PlanDetalle> getPlanPublicoDetalle(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/planes/publicos/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final detalleData = data['data'] ?? data;
      return PlanDetalle.fromJson(detalleData);
    } else {
      throw Exception('Error al obtener el detalle del plan público');
    }
  }

  // 👉 Obtener emprendedores de un plan
  Future<List<Emprendedor>> getEmprendedoresPorPlan(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/planes/$id/emprendedores'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> emprendedoresData = data['data'] ?? [];
      return emprendedoresData.map((json) => Emprendedor.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener emprendedores del plan');
    }
  }

  void dispose() {}
}