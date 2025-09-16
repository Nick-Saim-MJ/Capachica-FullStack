import 'package:get/get.dart';
import '../views/servicios_list_view.dart';
import '../views/servicio_detail_view.dart';
import '../views/carrito_view.dart';
import '../bindings/servicios_binding.dart';

class ServiciosRoutes {
  static const String servicios = '/servicios';
  static const String servicioDetalle = '/servicio-detalle';
  static const String carrito = '/carrito';

  static List<GetPage> routes = [
    GetPage(
      name: servicios,
      page: () => ServiciosListView(),
      binding: ServiciosBinding(),
    ),
    GetPage(
      name: servicioDetalle,
      page: () => ServicioDetailView(),
      binding: ServiciosBinding(),
    ),
    GetPage(
      name: carrito,
      page: () => CarritoView(),
      binding: ServiciosBinding(),
    ),
  ];
}