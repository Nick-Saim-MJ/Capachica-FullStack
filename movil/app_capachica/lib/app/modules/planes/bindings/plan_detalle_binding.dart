import 'package:get/get.dart';
import '../controllers/plan_detalle_controller.dart';
import '../../../data/repositories/plan_repository_impl.dart';
import '../../../services/plan_service.dart';
import '../../../domain/usecases/planes_usecases.dart';

class PlanDetalleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlanService>(() => PlanService());
    Get.lazyPut<PlanRepositoryImpl>(() => PlanRepositoryImpl(planService: Get.find<PlanService>()));
    Get.lazyPut<GetPlanDetalleUseCase>(() => GetPlanDetalleUseCase(Get.find<PlanRepositoryImpl>()));
    Get.lazyPut<GetEmprendedoresPorPlanUseCase>(() => GetEmprendedoresPorPlanUseCase(Get.find<PlanRepositoryImpl>()));
    Get.lazyPut<PlanDetalleController>(() => PlanDetalleController(
      getPlanDetalleUseCase: Get.find<GetPlanDetalleUseCase>(),
      getEmprendedoresPorPlanUseCase: Get.find<GetEmprendedoresPorPlanUseCase>(),
    ));
  }
} 