import '../repositories/plan_repository.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/plan_detalle_model.dart';
import '../../data/models/emprendedor_model.dart';

// Caso de uso para obtener planes públicos para landing page
class GetPlanesPublicosLandingUseCase {
  final PlanRepository _repository;

  GetPlanesPublicosLandingUseCase(this._repository);

  Future<List<Plan>> call() async {
    try {
      print('🗺️ GetPlanesPublicosLandingUseCase: Ejecutando...');
      return await _repository.getPlanesPublicosLanding();
    } catch (e) {
      print('❌ GetPlanesPublicosLandingUseCase: Error: $e');
      rethrow;
    }
  }
}

// Caso de uso para obtener detalles de un plan público
class GetPlanPublicoDetalleUseCase {
  final PlanRepository _repository;

  GetPlanPublicoDetalleUseCase(this._repository);

  Future<PlanDetalle> call(int id) async {
    try {
      print('🗺️ GetPlanPublicoDetalleUseCase: Ejecutando para plan $id...');
      return await _repository.getPlanPublicoDetalle(id);
    } catch (e) {
      print('❌ GetPlanPublicoDetalleUseCase: Error: $e');
      rethrow;
    }
  }
}

// Caso de uso para obtener todos los planes
class GetAllPlanesUseCase {
  final PlanRepository _repository;

  GetAllPlanesUseCase(this._repository);

  Future<List<Plan>> call() async {
    try {
      print('🗺️ GetAllPlanesUseCase: Ejecutando...');
      return await _repository.getAllPlanes();
    } catch (e) {
      print('❌ GetAllPlanesUseCase: Error: $e');
      rethrow;
    }
  }
}

// Caso de uso para obtener planes públicos
class GetPlanesPublicosUseCase {
  final PlanRepository _repository;

  GetPlanesPublicosUseCase(this._repository);

  Future<List<Plan>> call() async {
    try {
      print('🗺️ GetPlanesPublicosUseCase: Ejecutando...');
      return await _repository.getPlanesPublicos();
    } catch (e) {
      print('❌ GetPlanesPublicosUseCase: Error: $e');
      rethrow;
    }
  }
}

// Caso de uso para buscar planes
class SearchPlanesUseCase {
  final PlanRepository _repository;

  SearchPlanesUseCase(this._repository);

  Future<List<Plan>> call({
    String? query,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? duracionMin,
    int? duracionMax,
    String? ubicacion,
  }) async {
    try {
      print('🗺️ SearchPlanesUseCase: Ejecutando búsqueda...');
      return await _repository.searchPlanes(
        query: query,
        categoria: categoria,
        precioMin: precioMin,
        precioMax: precioMax,
        duracionMin: duracionMin,
        duracionMax: duracionMax,
        ubicacion: ubicacion,
      );
    } catch (e) {
      print('❌ SearchPlanesUseCase: Error: $e');
      rethrow;
    }
  }
}

// Caso de uso para obtener detalles de un plan específico
class GetPlanDetalleUseCase {
  final PlanRepository _repository;

  GetPlanDetalleUseCase(this._repository);

  Future<PlanDetalle> call(int id) async {
    try {
      print('🗺️ GetPlanDetalleUseCase: Ejecutando para plan $id...');
      return await _repository.getPlanDetalle(id);
    } catch (e) {
      print('❌ GetPlanDetalleUseCase: Error: $e');
      rethrow;
    }
  }
}

// Caso de uso para obtener emprendedores de un plan
class GetEmprendedoresPorPlanUseCase {
  final PlanRepository _repository;

  GetEmprendedoresPorPlanUseCase(this._repository);

  Future<List<Emprendedor>> call(int id) async {
    try {
      print('🗺️ GetEmprendedoresPorPlanUseCase: Ejecutando para plan $id...');
      return await _repository.getEmprendedoresPorPlan(id);
    } catch (e) {
      print('❌ GetEmprendedoresPorPlanUseCase: Error: $e');
      rethrow;
    }
  }
} 