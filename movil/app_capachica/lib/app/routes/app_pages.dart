import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_screen.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_screen.dart';
import '../modules/login/views/google_signin_webview.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_screen.dart';
import '../modules/services_capachica/bindings/services_capachica_binding.dart';
import '../modules/services_capachica/views/services_capachica_screen.dart';
import '../modules/services_capachica/views/service_detail_screen.dart';
import '../modules/services_capachica/controllers/services_capachica_controller.dart';
import '../modules/resumen/bindings/resumen_binding.dart';
import '../modules/resumen/views/resumen_screen.dart';
import '../modules/planes/bindings/planes_binding.dart';
import '../modules/planes/views/planes_screen.dart';
import '../modules/planes/bindings/plan_detalle_binding.dart';
import '../modules/planes/views/plan_detalle_screen.dart';
import '../modules/mis_reservas/bindings/mis_reservas_binding.dart';
import '../modules/mis_reservas/views/mis_reservas_screen.dart';
import '../modules/emprendedores/bindings/emprendedores_binding.dart';
import '../modules/emprendedores/views/emprendedores_screen.dart';
import '../modules/emprendedores/views/emprendedor_detail_screen.dart';
import '../modules/emprendedores/controllers/emprendedores_controller.dart';
import '../modules/eventos/bindings/eventos_binding.dart';
import '../modules/eventos/views/eventos_screen.dart';
import '../modules/eventos/views/evento_detail_screen.dart';
import '../modules/eventos/controllers/eventos_controller.dart';
import '../modules/carrito/views/carrito_screen.dart';
import 'app_routes.dart';
import '../modules/profile/views/profile_screen.dart';

class FadeScaleTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }
}

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      transitionDuration: const Duration(milliseconds: 600),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.GOOGLE_SIGNIN_WEBVIEW,
      page: () => GoogleSignInWebView(),
    ),
    GetPage(
      name: Routes.SERVICES_CAPACHICA,
      page: () => const ServicesCapachicaScreen(),
      binding: ServicesCapachicaBinding(),
    ),
    GetPage(
      name: '/services-capachica/detail/:id',
      page: () {
        final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
        final controller = Get.find<ServicesCapachicaController>();
        final servicio = controller.servicios.firstWhereOrNull((s) => s.id == id);
        if (servicio != null) {
          return ServiceDetailScreen(servicio: servicio);
        }
        // Si no está en memoria, intentar cargarlo de la API
        return FutureBuilder(
          future: controller.fetchServicioById(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: Text('Detalle de Servicio')),
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: Text('Detalle de Servicio')),
                body: Center(child: Text('Error al cargar el servicio: \\n${snapshot.error}')),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return ServiceDetailScreen(servicio: snapshot.data!);
            }
            return Scaffold(
              appBar: AppBar(title: Text('Detalle de Servicio')),
              body: Center(child: Text('Servicio no encontrado')),
            );
          },
        );
      },
      binding: ServicesCapachicaBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.RESUMEN,
      page: () => ResumenScreen(),
      binding: ResumenBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.PLANES,
      page: () => PlanesScreen(),
      binding: PlanesBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.PLAN_DETALLE,
      page: () => const PlanDetalleScreen(),
      binding: PlanDetalleBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.MIS_RESERVAS,
      page: () => MisReservasScreen(),
      binding: MisReservasBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.CARRITO,
      page: () => const CarritoScreen(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.EMPRENDEDORES,
      page: () => const EmprendedoresScreen(),
      binding: EmprendedoresBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: '/emprendedores/detail/:id',
      page: () {
        final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
        final controller = Get.find<EmprendedoresController>();
        final emprendedor = controller.emprendedores.firstWhereOrNull((e) => e.id == id);
        if (emprendedor != null) {
          return EmprendedorDetailScreen(emprendedor: emprendedor);
        }
        // Si no está en memoria, intentar cargarlo de la API
        return FutureBuilder(
          future: controller.fetchEmprendedorById(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: Text('Detalle del Emprendedor')),
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(title: Text('Detalle del Emprendedor')),
                body: Center(child: Text('Error al cargar el emprendedor: \\n${snapshot.error}')),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return EmprendedorDetailScreen(emprendedor: snapshot.data!);
            }
            return Scaffold(
              appBar: AppBar(title: Text('Detalle del Emprendedor')),
              body: Center(child: Text('Emprendedor no encontrado')),
            );
          },
        );
      },
      binding: EmprendedoresBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: Routes.EVENTOS,
      page: () => EventosScreen(),
      binding: EventosBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: '/eventos/detail/:id',
      page: () {
        final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
        final controller = Get.find<EventosController>();
        controller.loadEventoDetalle(id);
        controller.loadEventosEmprendedor(controller.eventoSeleccionado.value?.emprendedorId ?? 0);
        return EventoDetailScreen();
      },
      binding: EventosBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: '/eventos/emprendedor/:emprendedorId',
      page: () {
        final emprendedorId = int.tryParse(Get.parameters['emprendedorId'] ?? '') ?? 0;
        final controller = Get.find<EventosController>();
        controller.loadEventosEmprendedor(emprendedorId);
        return EventosScreen();
      },
      binding: EventosBinding(),
      transitionDuration: const Duration(milliseconds: 400),
      customTransition: FadeScaleTransition(),
    ),
    GetPage(
      name: '/profile',
      page: () => ProfileScreen(),
    ),
  ];
}

abstract class Routes {
  static const SPLASH = _Paths.SPLASH;
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const GOOGLE_SIGNIN_WEBVIEW = _Paths.GOOGLE_SIGNIN_WEBVIEW;
  static const SERVICES_CAPACHICA = _Paths.SERVICES_CAPACHICA;
  static const RESUMEN = _Paths.RESUMEN;
  static const PLANES = _Paths.PLANES;
  static const PLAN_DETALLE = _Paths.PLAN_DETALLE;
  static const MIS_RESERVAS = _Paths.MIS_RESERVAS;
  static const CARRITO = _Paths.CARRITO;
  static const EMPRENDEDORES = _Paths.EMPRENDEDORES;
  static const EVENTOS = _Paths.EVENTOS;
}

abstract class _Paths {
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const GOOGLE_SIGNIN_WEBVIEW = '/google-signin-webview';
  static const SERVICES_CAPACHICA = '/services-capachica';
  static const RESUMEN = '/resumen';
  static const PLANES = '/planes';
  static const PLAN_DETALLE = '/plan-detalle';
  static const MIS_RESERVAS = '/mis-reservas';
  static const CARRITO = '/carrito';
  static const EMPRENDEDORES = '/emprendedores';
  static const EVENTOS = '/eventos';
}
