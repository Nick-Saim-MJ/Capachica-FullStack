import 'package:get/get.dart';
import '../controllers/emprendedores_controller.dart';

class EmprendedoresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmprendedoresController>(() => EmprendedoresController());
  }
} 