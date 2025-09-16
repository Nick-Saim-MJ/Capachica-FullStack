import 'package:app_capachica/app/data/providers/emprendedor_provider.dart';
import 'package:app_capachica/app/data/repositories/emprendedor_repository.dart';
import 'package:get/get.dart';
import '../controllers/emprendedores_controller.dart';

class EmprendedoresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmprendedoresCapachicaProvider());
    Get.lazyPut(() => EmprendedoresCapachicaRepository(Get.find()));
    Get.lazyPut(() => EmprendedoresController(Get.find()));
  }
} 