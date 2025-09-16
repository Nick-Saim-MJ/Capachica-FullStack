import '../../domain/repositories/plan_repository.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/plan_detalle_model.dart';
import '../../data/models/emprendedor_model.dart';
import '../../services/plan_service.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlanService _planService;

  PlanRepositoryImpl({PlanService? planService}) 
      : _planService = planService ?? PlanService();

  @override
  Future<List<Plan>> getPlanesPublicosLanding() async {
    try {
      print('🗺️ PlanRepository: Obteniendo planes públicos para landing...');
      return await _planService.getPlanesPublicosLanding();
    } catch (e) {
      print('❌ PlanRepository: Error en getPlanesPublicosLanding: $e');
      rethrow;
    }
  }

  @override
  Future<PlanDetalle> getPlanPublicoDetalle(int id) async {
    try {
      print('🗺️ PlanRepository: Obteniendo detalles del plan público $id...');
      return await _planService.getPlanPublicoDetalle(id);
    } catch (e) {
      print('❌ PlanRepository: Error en getPlanPublicoDetalle: $e');
      rethrow;
    }
  }

  @override
  Future<List<Plan>> getAllPlanes() async {
    try {
      print('🗺️ PlanRepository: Obteniendo todos los planes...');
      return await _planService.getAllPlanes();
    } catch (e) {
      print('❌ PlanRepository: Error en getAllPlanes: $e');
      rethrow;
    }
  }

  @override
  Future<List<Plan>> getPlanesPublicos() async {
    try {
      print('🗺️ PlanRepository: Obteniendo planes públicos...');
      return await _planService.getPlanesPublicos();
    } catch (e) {
      print('❌ PlanRepository: Error en getPlanesPublicos: $e');
      rethrow;
    }
  }

  @override
  Future<List<Plan>> searchPlanes({
    String? query,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? duracionMin,
    int? duracionMax,
    String? ubicacion,
  }) async {
    try {
      print('🗺️ PlanRepository: Buscando planes...');
      return await _planService.searchPlanes(
        query: query,
        categoria: categoria,
        precioMin: precioMin,
        precioMax: precioMax,
        duracionMin: duracionMin,
        duracionMax: duracionMax,
        ubicacion: ubicacion,
      );
    } catch (e) {
      print('❌ PlanRepository: Error en searchPlanes: $e');
      rethrow;
    }
  }

  @override
  Future<PlanDetalle> getPlanDetalle(int id) async {
    try {
      print('🗺️ PlanRepository: Obteniendo detalles del plan $id...');
      return await _planService.getPlanDetalle(id);
    } catch (e) {
      print('❌ PlanRepository: Error en getPlanDetalle: $e');
      rethrow;
    }
  }

  @override
  Future<List<Emprendedor>> getEmprendedoresPorPlan(int id) async {
    try {
      print('🗺️ PlanRepository: Obteniendo emprendedores del plan $id...');
      return await _planService.getEmprendedoresPorPlan(id);
    } catch (e) {
      print('❌ PlanRepository: Error en getEmprendedoresPorPlan: $e');
      rethrow;
    }
  }

  void dispose() {
    _planService.dispose();
  }
} 