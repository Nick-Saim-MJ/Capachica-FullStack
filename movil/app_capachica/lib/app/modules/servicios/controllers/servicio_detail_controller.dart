import 'package:get/get.dart';
import '../../../data/models/servicio_model.dart';
import '../../../data/models/carrito_model.dart';
import '../../../services/servicio_service.dart';
import '../../../services/carrito_service.dart';
import '../../../services/auth_service.dart';

class ServicioDetailController extends GetxController {
  final ServicioService _servicioService = ServicioService();
  final CarritoService _carritoService = CarritoService();
  final AuthService _authService = Get.find<AuthService>();

  // Estados principales
  final servicio = Rxn<Servicio>();
  final isLoading = false.obs;
  final error = ''.obs;

  // Estados del formulario de reserva
  final fechaReserva = Rxn<DateTime>();
  final horaReserva = ''.obs;
  final cantidad = 1.obs;
  final notas = ''.obs;

  // Estados del carrito
  final isAddingToCart = false.obs;
  final cantidadEnCarrito = 0.obs;

  // Estados de validación
  final fechaValida = true.obs;
  final horaValida = true.obs;
  final cantidadValida = true.obs;

  // Servicio ID
  late int servicioId;

  @override
  void onInit() {
    super.onInit();
    servicioId = Get.arguments as int? ?? 0;
    if (servicioId > 0) {
      loadServicio();
      checkCantidadEnCarrito();
    }
  }

  /// Cargar servicio por ID
  Future<void> loadServicio() async {
    try {
      isLoading.value = true;
      error.value = '';

      print('🛠️ ServicioDetailController: Cargando servicio ID: $servicioId');

      final servicioData = await _servicioService.getServicio(servicioId);
      servicio.value = servicioData;

      print('✅ ServicioDetailController: Servicio cargado: ${servicioData.nombre}');
    } catch (e) {
      error.value = e.toString();
      print('❌ ServicioDetailController: Error cargando servicio: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Verificar cantidad en carrito
  Future<void> checkCantidadEnCarrito() async {
    try {
      final cantidad = await _carritoService.getCantidadEnCarrito(servicioId);
      cantidadEnCarrito.value = cantidad;
    } catch (e) {
      print('❌ ServicioDetailController: Error verificando cantidad en carrito: $e');
    }
  }

  /// Establecer fecha de reserva
  void setFechaReserva(DateTime? fecha) {
    fechaReserva.value = fecha;
    _validateFecha();
  }

  /// Establecer hora de reserva
  void setHoraReserva(String hora) {
    horaReserva.value = hora;
    _validateHora();
  }

  /// Cambiar cantidad
  void changeCantidad(int nuevaCantidad) {
    if (nuevaCantidad > 0) {
      cantidad.value = nuevaCantidad;
      _validateCantidad();
    }
  }

  /// Establecer notas
  void setNotas(String texto) {
    notas.value = texto;
  }

  /// Validar fecha
  void _validateFecha() {
    if (fechaReserva.value == null) {
      fechaValida.value = true; // Fecha opcional
      return;
    }

    final hoy = DateTime.now();
    final fecha = fechaReserva.value!;
    
    // La fecha debe ser hoy o en el futuro
    fechaValida.value = fecha.isAfter(hoy.subtract(Duration(days: 1)));
  }

  /// Validar hora
  void _validateHora() {
    if (horaReserva.value.isEmpty) {
      horaValida.value = true; // Hora opcional
      return;
    }

    // Validar formato HH:MM
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    horaValida.value = regex.hasMatch(horaReserva.value);
  }

  /// Validar cantidad
  void _validateCantidad() {
    if (servicio.value == null) {
      cantidadValida.value = true;
      return;
    }

    final capacidad = servicio.value!.capacidad;
    if (capacidad != null && capacidad > 0) {
      cantidadValida.value = cantidad.value <= capacidad;
    } else {
      cantidadValida.value = cantidad.value > 0;
    }
  }

  /// Verificar si el formulario es válido
  bool get isFormValid {
    return fechaValida.value && horaValida.value && cantidadValida.value;
  }

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated {
    return _authService.isLoggedIn;
  }

  /// Agregar al carrito
  Future<void> agregarAlCarrito() async {
    if (!isAuthenticated) {
      Get.snackbar(
        'Autenticación requerida',
        'Debes iniciar sesión para agregar servicios al carrito',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    if (!isFormValid) {
      Get.snackbar(
        'Formulario inválido',
        'Por favor revisa los datos ingresados',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      isAddingToCart.value = true;

      print('🛒 ServicioDetailController: Agregando al carrito...');

      await _carritoService.agregarServicioAlCarrito(
        servicio: servicio.value!,
        cantidad: cantidad.value,
        fechaReserva: fechaReserva.value,
        horaReserva: horaReserva.value.isNotEmpty ? horaReserva.value : null,
        notas: notas.value.isNotEmpty ? notas.value : null,
      );

      // Actualizar cantidad en carrito
      await checkCantidadEnCarrito();

      Get.snackbar(
        'Agregado al carrito',
        '${servicio.value!.nombre} agregado exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );

      print('✅ ServicioDetailController: Servicio agregado al carrito');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo agregar al carrito: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print('❌ ServicioDetailController: Error agregando al carrito: $e');
    } finally {
      isAddingToCart.value = false;
    }
  }

  /// Ir al carrito
  void irAlCarrito() {
    Get.toNamed('/carrito');
  }

  /// Obtener horarios disponibles para un día
  List<String> getHorariosDisponibles(DateTime fecha) {
    if (servicio.value == null || !servicio.value!.tieneHorarios) {
      return [];
    }

    final horarios = servicio.value!.horarios!;
    final diaSemana = _getDiaSemana(fecha.weekday);
    
    return horarios
        .where((horario) => horario.estaAbiertoEnDia(diaSemana))
        .map((horario) => horario.horaInicio)
        .toList();
  }

  /// Obtener nombre del día de la semana
  String _getDiaSemana(int weekday) {
    switch (weekday) {
      case 1: return 'Lunes';
      case 2: return 'Martes';
      case 3: return 'Miércoles';
      case 4: return 'Jueves';
      case 5: return 'Viernes';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '';
    }
  }

  /// Verificar si el servicio está disponible en una fecha
  bool estaDisponibleEnFecha(DateTime fecha) {
    if (servicio.value == null) return false;
    return servicio.value!.estaDisponibleEnFecha(fecha);
  }

  /// Verificar si el servicio está disponible en un horario
  bool estaDisponibleEnHorario(String hora) {
    if (servicio.value == null) return false;
    return servicio.value!.estaDisponibleEnHorario(hora);
  }

  /// Obtener precio total
  double get precioTotal {
    if (servicio.value == null) return 0.0;
    return servicio.value!.precio * cantidad.value;
  }

  /// Obtener precio total formateado
  String get precioTotalFormateado {
    return 'S/ ${precioTotal.toStringAsFixed(2)}';
  }

  /// Obtener información de reserva
  String get infoReserva {
    final partes = <String>[];
    
    if (fechaReserva.value != null) {
      final fecha = fechaReserva.value!;
      partes.add('${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}');
    }
    
    if (horaReserva.value.isNotEmpty) {
      partes.add('a las ${horaReserva.value}');
    }
    
    if (cantidad.value > 1) {
      partes.add('x${cantidad.value}');
    }
    
    return partes.isEmpty ? 'Sin fecha específica' : partes.join(' ');
  }

  /// Limpiar formulario
  void limpiarFormulario() {
    fechaReserva.value = null;
    horaReserva.value = '';
    cantidad.value = 1;
    notas.value = '';
    fechaValida.value = true;
    horaValida.value = true;
    cantidadValida.value = true;
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await loadServicio();
    await checkCantidadEnCarrito();
  }
}