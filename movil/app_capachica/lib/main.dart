import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/controllers/theme_controller.dart';
import 'package:app_capachica/app/services/auth_service.dart';
import 'package:app_capachica/app/services/reserva_service.dart';
import 'app/core/controllers/cart_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar GetStorage
  await GetStorage.init();
  await Get.putAsync(() => AuthService().init());
  
  // Inicializar el servicio de reservas
  Get.put(ReservaService());
  
  // Inicializar el controlador de tema
  Get.put(ThemeController());

  // Inicializar el controlador global del carrito
  Get.put(CartController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Mi App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.SPLASH,
          getPages: AppPages.routes,
        );
      },
    );
  }
}