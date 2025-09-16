import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/controllers/theme_controller.dart';
import 'app/services/auth_service.dart';
import 'app/services/reserva_service.dart';
import 'app/services/services_capachica_service.dart';
import 'app/core/controllers/cart_controller.dart';
import 'app/core/cache/cache_service.dart';
import 'app/core/http/http_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Core singletons
  Get.put<CacheService>(CacheService(), permanent: true);
  Get.put<AppHttpClient>(AppHttpClient.instance, permanent: true);

  // AuthService: REGISTRO SINCRÓNICO y luego init()
  final auth = Get.put<AuthService>(AuthService(), permanent: true);
  await auth.init();

  // Otros servicios
  Get.put<ReservaService>(ReservaService(), permanent: true);
  Get.put<ServicesCapachicaService>(ServicesCapachicaService(), permanent: true);

  // Controladores
  Get.put<ThemeController>(ThemeController(), permanent: true);
  Get.put<CartController>(CartController(), permanent: true);

  runApp(const MyApp());
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