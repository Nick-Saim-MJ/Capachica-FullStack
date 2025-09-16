import 'package:get/get.dart';
import '../controllers/servicios_controller.dart';
import '../controllers/servicio_detail_controller.dart';
import '../controllers/carrito_controller.dart';

class ServiciosBinding extends Bindings {
  @override
  void dependencies() {
    // Controller para la lista de servicios
    Get.lazyPut<ServiciosController>(
      () => ServiciosController(),
    );
    
    // Controller para el detalle de servicio
    Get.lazyPut<ServicioDetailController>(
      () => ServicioDetailController(),
    );
    
    // Controller para el carrito
    Get.lazyPut<CarritoController>(
      () => CarritoController(),
    );
  }
}