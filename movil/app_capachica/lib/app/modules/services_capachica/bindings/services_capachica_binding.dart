import 'package:get/get.dart';
import '../../../core/config/backend_config.dart';
import '../../../data/providers/services_capachica_provider.dart';
import '../../../data/repositories/services_capachica_repository.dart';
import '../controllers/services_capachica_controller.dart';

class ServicesCapachicaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ServicesCapachicaProvider());
    Get.lazyPut(() => ServicesCapachicaRepository(Get.find()));
    Get.lazyPut(() => ServicesCapachicaController(Get.find()));
  }
} 