import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    print('SplashController onReady');
    _navigateToHome();
  }

  void _navigateToHome() {
    print('Iniciando navegación al home en 3 segundos...');
    Future.delayed(const Duration(seconds: 3), () {
      print('Navegando al home...');
      Get.offAllNamed(AppRoutes.HOME);
    });
  }
}