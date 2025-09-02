import '../../data/models/plan_model.dart';
import '../../data/models/plan_detalle_model.dart';
import '../../data/models/emprendedor_model.dart';

abstract class PlanRepository {
  // Métodos para planes públicos (landing page)
  Future<List<Plan>> getPlanesPublicosLanding();
  Future<PlanDetalle> getPlanPublicoDetalle(int id);
  
  // Métodos para todos los planes
  Future<List<Plan>> getAllPlanes();
  Future<List<Plan>> getPlanesPublicos();
  
  // Métodos de búsqueda
  Future<List<Plan>> searchPlanes({
    String? query,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? duracionMin,
    int? duracionMax,
    String? ubicacion,
  });
  
  // Métodos para planes específicos
  Future<PlanDetalle> getPlanDetalle(int id);
  Future<List<Emprendedor>> getEmprendedoresPorPlan(int id);
} 