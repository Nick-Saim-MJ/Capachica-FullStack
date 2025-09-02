import 'package:get/get.dart';
import '../controllers/mis_reservas_controller.dart';
import '../../../services/reserva_service.dart';

class MisReservasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReservaService>(() => ReservaService());
    Get.lazyPut<MisReservasController>(() => MisReservasController());
  }
} 