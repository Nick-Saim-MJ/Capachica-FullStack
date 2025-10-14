import 'dart:convert';
import 'dart:developer' as developer;
import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:http/http.dart' as http;
import '../models/plan_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class PlanRemoteDataSource {
  Future<List<PlanModel>> getPublicPlans({Map<String, String> filters = const {}});
  Future<PlanModel> getPlanById(int id);
  Future<void> deletePlan(int id); // 👈 Método abstracto
}

class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  final http.Client client;

  // CONFIGURA LA URL DE TU SERVIDOR LARAVEL
  static const String baseUrl = BackendConfig.baseUrl; // Para emulador Android
  static const bool useRealApi = true; // Cambiar a true para conectar con tu Laravel

  PlanRemoteDataSourceImpl({required this.client});

  // 🔹 1️⃣ Obtener planes públicos
  @override
  Future<List<PlanModel>> getPublicPlans({Map<String, String> filters = const {}}) async {
    developer.log('🚀 Conectando con Laravel backend', name: 'LARAVEL_API');

    if (!useRealApi) return _getMockPlans();

    try {
      final uri = Uri.parse('$baseUrl/planes').replace(queryParameters: filters);
      developer.log('📡 Petición a Laravel: $uri', name: 'LARAVEL_HTTP');

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      developer.log('📥 Laravel respondió: ${response.statusCode}', name: 'LARAVEL_HTTP');
      developer.log('📄 Respuesta Laravel: ${response.body}', name: 'LARAVEL_RESPONSE');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          List<dynamic> planesData;

          if (jsonResponse['data'] is Map && jsonResponse['data']['data'] != null) {
            planesData = jsonResponse['data']['data'] as List;
          } else if (jsonResponse['data'] is List) {
            planesData = jsonResponse['data'] as List;
          } else {
            throw ServerException();
          }

          return planesData.map((planJson) => PlanModel.fromLaravelJson(planJson)).toList();
        } else {
          throw ServerException();
        }
      } else {
        throw ServerException();
      }
    } catch (e) {
      developer.log('💥 Error conectando con Laravel: $e', name: 'LARAVEL_ERROR');
      throw ServerException();
    }
  }

  // 🔹 2️⃣ Obtener un plan específico
  @override
  Future<PlanModel> getPlanById(int id) async {
    developer.log('🚀 Laravel - Obteniendo plan ID: $id', name: 'LARAVEL_API');

    if (!useRealApi) return _getMockPlan(id);

    try {
      final uri = Uri.parse('$baseUrl/planes/$id');
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return PlanModel.fromLaravelJson(jsonResponse['data']);
        } else {
          throw ServerException();
        }
      } else {
        throw ServerException();
      }
    } catch (e) {
      developer.log('💥 Laravel - Error obteniendo plan: $e', name: 'LARAVEL_ERROR');
      throw ServerException();
    }
  }

  // 🔹 3️⃣ NUEVO — Eliminar un plan
  @override
  Future<void> deletePlan(int id) async {
    developer.log('🗑️ Eliminando plan ID: $id en Laravel...', name: 'LARAVEL_DELETE');

    try {
      final uri = Uri.parse('$baseUrl/planes/$id');
      final response = await client.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      developer.log('📥 Respuesta DELETE: ${response.statusCode}', name: 'LARAVEL_DELETE');

      if (response.statusCode == 200 || response.statusCode == 204) {
        developer.log('✅ Plan $id eliminado correctamente', name: 'LARAVEL_DELETE');
        return;
      } else {
        developer.log('❌ Error al eliminar plan: ${response.body}', name: 'LARAVEL_DELETE');
        throw ServerException();
      }
    } catch (e) {
      developer.log('💥 Error DELETE Laravel: $e', name: 'LARAVEL_DELETE_ERROR');
      throw ServerException();
    }
  }

  // 🔹 Mock data para desarrollo
  Future<List<PlanModel>> _getMockPlans() async {
    developer.log('🎭 Usando datos mock', name: 'MOCK_DATA');
    await Future.delayed(const Duration(seconds: 2));
    return [
      const PlanModel(
        id: 1,
        nombre: 'Tour Isla Amantaní - Mock',
        descripcion: 'Visita simulada a la hermosa Isla Amantaní (datos de prueba)',
        duracionDias: 2,
        capacidad: 20,
        cuposDisponibles: 15,
        precioTotal: 150.0,
        dificultad: 'Fácil',
        queIncluye: 'Transporte, comidas, hospedaje (simulado)',
      ),
    ];
  }

  Future<PlanModel> _getMockPlan(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    return const PlanModel(
      id: 1,
      nombre: 'Plan Detallado Mock',
      descripcion: 'Descripción detallada simulada desde mock data',
      duracionDias: 2,
      capacidad: 20,
      cuposDisponibles: 15,
      precioTotal: 150.0,
      dificultad: 'Fácil',
      queIncluye: 'Todo incluido (mock)',
    );
  }
}