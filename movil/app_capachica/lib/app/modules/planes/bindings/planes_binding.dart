import 'package:get/get.dart';
import '../controllers/planes_controller.dart';
import '../../../data/repositories/plan_repository_impl.dart';
import '../../../services/plan_service.dart';
import '../../../domain/usecases/planes_usecases.dart';

class PlanesBinding extends Bindings {
  @override
  void dependencies() {
    // Inyección de dependencias siguiendo arquitectura limpia
    Get.lazyPut<PlanService>(() => PlanService());
    
    Get.lazyPut<PlanRepositoryImpl>(
      () => PlanRepositoryImpl(planService: Get.find<PlanService>()),
    );
    
    // Casos de uso
    Get.lazyPut<GetPlanesPublicosUseCase>(
      () => GetPlanesPublicosUseCase(Get.find<PlanRepositoryImpl>()),
    );
    
    Get.lazyPut<SearchPlanesUseCase>(
      () => SearchPlanesUseCase(Get.find<PlanRepositoryImpl>()),
    );
    
    // Casos de uso para detalles y emprendedores (para navegación entre pantallas)
    Get.lazyPut<GetPlanDetalleUseCase>(
      () => GetPlanDetalleUseCase(Get.find<PlanRepositoryImpl>()),
    );
    Get.lazyPut<GetEmprendedoresPorPlanUseCase>(
      () => GetEmprendedoresPorPlanUseCase(Get.find<PlanRepositoryImpl>()),
    );
    
    // Controlador
    Get.lazyPut<PlanesController>(
      () => PlanesController(
        getPlanesPublicosUseCase: Get.find<GetPlanesPublicosUseCase>(),
        searchPlanesUseCase: Get.find<SearchPlanesUseCase>(),
      ),
    );
  }
} 