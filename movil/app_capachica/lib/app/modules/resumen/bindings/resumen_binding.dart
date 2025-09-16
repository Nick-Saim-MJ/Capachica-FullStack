import 'package:get/get.dart';
import '../controllers/resumen_controller.dart';

class ResumenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResumenController>(() => ResumenController());
  }
} 