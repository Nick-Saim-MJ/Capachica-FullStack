import 'package:get/get.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../data/repositories/profile_repository_impl.dart';
import '../../../services/profile_service.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Registrar ProfileService como singleton
    Get.lazyPut<ProfileService>(() => ProfileService(), fenix: true);

    // Registrar ProfileRepositoryImpl con la instancia de ProfileService
    Get.lazyPut<ProfileRepository>(
            () => ProfileRepositoryImpl(Get.find<ProfileService>()),
        fenix: true);

    // Registrar ProfileController con la instancia de ProfileRepository
    Get.lazyPut<ProfileController>(
            () => ProfileController(Get.find<ProfileRepository>()),
        fenix: true);
  }
}
