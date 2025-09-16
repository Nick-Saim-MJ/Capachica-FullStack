import 'package:get/get.dart';
import '../controllers/eventos_controller.dart';

class EventosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventosController>(() => EventosController());
  }
} 