import 'package:get/get.dart';
import 'routes/servicios_routes.dart';

class ServiciosModule {
  static void init() {
    // Registrar las rutas del módulo en GetX
    Get.addPages(ServiciosRoutes.routes);
  }
}