import 'package:get/get.dart';
import '../../../data/models/plan_detalle_model.dart';
import '../../../data/models/emprendedor_model.dart';
import '../../../domain/usecases/planes_usecases.dart';

class PlanDetalleController extends GetxController {
  final GetPlanDetalleUseCase getPlanDetalleUseCase;
  final GetEmprendedoresPorPlanUseCase getEmprendedoresPorPlanUseCase;

  PlanDetalleController({
    required this.getPlanDetalleUseCase,
    required this.getEmprendedoresPorPlanUseCase,
  });

  final Rxn<PlanDetalle> planDetalle = Rxn<PlanDetalle>();
  final RxList<Emprendedor> emprendedores = <Emprendedor>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  int? planId;

  @override
  void onInit() {
    super.onInit();
    planId = Get.arguments is int ? Get.arguments : (Get.arguments as Map?)?['id'];
    loadDetalle();
  }

  Future<void> loadDetalle() async {
    if (planId == null) {
      errorMessage.value = 'ID de plan no proporcionado.';
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final detalle = await getPlanDetalleUseCase(planId!);
      planDetalle.value = detalle;
      final emps = await getEmprendedoresPorPlanUseCase(planId!);
      emprendedores.assignAll(emps);
    } catch (e) {
      errorMessage.value = 'Error al cargar detalles: $e';
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasError => errorMessage.value.isNotEmpty;
} 