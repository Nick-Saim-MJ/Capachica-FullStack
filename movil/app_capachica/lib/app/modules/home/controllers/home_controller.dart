import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/municipalidad_service.dart';
import '../../../data/repositories/municipalidad_repository_impl.dart';
import '../../../domain/repositories/municipalidad_repository.dart';
import '../../../domain/usecases/get_resumen_usecase.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthService authService = Get.find<AuthService>();
  
  // Servicios y casos de uso para el resumen
  late final MunicipalidadService _municipalidadService;
  late final MunicipalidadRepository _municipalidadRepository;
  late final GetResumenUseCase _getResumenUseCase;
  
  // Controlador de animación para el efecto neón
  late AnimationController _neonAnimationController;
  late Animation<double> neonAnimation;

  String get userDisplayName {
    if (!authService.isLoggedIn) return 'Mi Perfil';

    // Usar el nombre si existe, si no, usar el email.
    final name = authService.currentUser.value?.name;
    final email = authService.currentUser.value?.email ?? 'Perfil';

    // Si el nombre no es nulo y no está vacío, úsalo.
    if (name != null && name.isNotEmpty) {
      return name.length > 8 ? name.substring(0, 8) : name;
    }
    
    // Si no hay nombre, usa el email.
    return email.length > 8 ? email.substring(0, 8) : email;
  }

  // Variables observables
  final selectedTopNav = 'Inicio'.obs;
  final selectedBottomNav = 'Inicio'.obs;
  final showProfileDropdown = false.obs;
  
  // Variables observables para el resumen
  final isLoadingResumen = false.obs;
  final resumenData = Rxn<ResumenData>();
  final resumenError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    print('HomeController inicializado');
    
    // Inicializar servicios y casos de uso
    _municipalidadService = MunicipalidadService();
    _municipalidadRepository = MunicipalidadRepositoryImpl(_municipalidadService);
    _getResumenUseCase = GetResumenUseCase(_municipalidadRepository);
    
    // Inicializar animación neón
    _neonAnimationController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );
    
    neonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _neonAnimationController,
      curve: Curves.linear,
    ));
    
    // Iniciar animación en loop
    _neonAnimationController.repeat();
  }

  @override
  void onClose() {
    _neonAnimationController.dispose();
    _municipalidadService.dispose();
    super.onClose();
  }

  // Métodos para manejar navegación superior
  void onTopNavTap(String navItem) {
    if (navItem == 'Mi Perfil') {
      toggleProfileDropdown();
    } else {
      selectedTopNav.value = navItem;
      hideProfileDropdown(); // Ocultar dropdown si se selecciona otra opción
    }

    print('Top Nav seleccionado: $navItem');

    // Aquí puedes agregar lógica específica para cada tab
    switch (navItem) {
      case 'Inicio':
        _handleInicio();
        break;
      case 'Emprendimientos':
        _handleEmprendimientos();
        break;
      case 'Eventos':
        _handleEventos();
        break;
      case 'Servicios':
        _handleServicios();
        break;
      case 'Mi Perfil':
        _handleMiPerfil();
        break;
    }
  }

  // Métodos para manejar el dropdown del perfil
  void toggleProfileDropdown() {
    showProfileDropdown.value = !showProfileDropdown.value;
    if (showProfileDropdown.value) {
      selectedTopNav.value = 'Mi Perfil';
    }
  }

  void hideProfileDropdown() {
    showProfileDropdown.value = false;
    if (selectedTopNav.value == 'Mi Perfil') {
      selectedTopNav.value = 'Inicio'; // Volver a la opción anterior
    }
  }

  // Métodos para manejar las opciones del dropdown
  void onLoginTap() {
    hideProfileDropdown();
    Get.toNamed(AppRoutes.LOGIN);
  }

  void onMyAccountTap() {
    hideProfileDropdown();
    print('Mi Cuenta presionado');
    Get.toNamed('/profile');
  }

  void onMyReservationsTap() {
    hideProfileDropdown();
    print('Mis Reservas presionado');
    
    if (!authService.isLoggedIn) {
      Get.snackbar(
        'Autenticación requerida',
        'Debes iniciar sesión para ver tus reservas',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
        borderRadius: 12,
        margin: EdgeInsets.all(16),
        icon: Icon(Icons.warning, color: Colors.white),
      );
      Get.toNamed(AppRoutes.LOGIN);
    } else {
      Get.toNamed('/mis-reservas');
    }
  }

  void onMyCartTap() {
    hideProfileDropdown();
    print('Mi Carrito presionado');
    
    if (!authService.isLoggedIn) {
      Get.snackbar(
        'Autenticación requerida',
        'Debes iniciar sesión para ver tu carrito',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
        borderRadius: 12,
        margin: EdgeInsets.all(16),
        icon: Icon(Icons.warning, color: Colors.white),
      );
      Get.toNamed(AppRoutes.LOGIN);
    } else {
      Get.toNamed('/carrito');
    }
  }

  void onSettingsTap() {
    hideProfileDropdown();
    print('Configuración presionado');
    Get.snackbar(
      'Configuración',
      'Abriendo configuración...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF424242).withOpacity(0.95),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      icon: Icon(Icons.settings, color: Colors.white),
    );
    // Get.toNamed('/settings');
  }

  void onLogoutTap() {
    hideProfileDropdown();
    print('Cerrar Sesión presionado');

    // Mostrar diálogo de confirmación
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFD32F2F)),
            SizedBox(width: 12),
            Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    await authService.logout();
    Get.snackbar(
      'Sesión Cerrada',
      'Has cerrado sesión exitosamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFFD32F2F).withOpacity(0.95),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
      icon: Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // Métodos para manejar botones de acción
  void onHotelsTap() {
    print('🗺️ HomeController: Ver planes presionado, navegando a pantalla de planes...');
    Get.toNamed(AppRoutes.PLANES);
  }

  void onToursTap() {
    Get.toNamed(AppRoutes.SERVICES_CAPACHICA);
  }

  // Métodos para manejar navegación inferior
  void onBottomNavTap(String navItem) {
    selectedBottomNav.value = navItem;
    hideProfileDropdown(); // Ocultar dropdown si está abierto
    print('Bottom Nav seleccionado: $navItem');

    switch (navItem) {
      case 'Inicio':
      // Ya estamos en home
        break;
      case 'Emprendimientos':
        _handleEmprendimientos();
        break;
      case 'Servicios':
        _handleServiciosBottom();
        break;
      case 'Eventos':
        _handleEventos();
        break;
      case 'Planes':
        _handlePlanesBottom();
        break;
    }
  }

  // Métodos privados para manejar cada acción
  void _handleInicio() {
    print('🏠 HomeController: Inicio seleccionado, navegando a pantalla de resumen...');
    Get.toNamed(AppRoutes.RESUMEN);
  }

  /// Carga los datos del resumen usando el caso de uso
  void loadResumen() async {
    try {
      print('🏠 HomeController: Iniciando carga del resumen...');
      
      // Limpiar errores previos y establecer estado de carga
      resumenError.value = null;
      isLoadingResumen.value = true;
      
      // Ejecutar el caso de uso
      final data = await _getResumenUseCase.execute();
      
      // Actualizar los datos
      resumenData.value = data;
      isLoadingResumen.value = false;
      
      print('✅ HomeController: Resumen cargado exitosamente');
      
      // Mostrar snackbar de éxito
      Get.snackbar(
        'Resumen Cargado',
        'Datos actualizados correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF4CAF50).withOpacity(0.95),
        colorText: Colors.white,
        borderRadius: 12,
        margin: EdgeInsets.all(16),
        icon: Icon(Icons.check_circle, color: Colors.white),
        duration: Duration(seconds: 2),
      );
      
      // Mostrar información en consola
      print('📊 HomeController: Resumen cargado con:');
      print('   - Sliders: ${data.sliders.length}');
      print('   - Municipalidades: ${data.municipalidades.length}');
      print('   - Primera municipalidad con detalles: ${data.primeraMunicipalidadDetalle != null}');
      
    } catch (e) {
      print('❌ HomeController: Error cargando resumen: $e');
      
      // Actualizar estado de error
      resumenError.value = e.toString();
      isLoadingResumen.value = false;
      
      // Mostrar snackbar de error
      Get.snackbar(
        'Error al Cargar',
        'No se pudieron cargar los datos del resumen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFFD32F2F).withOpacity(0.95),
        colorText: Colors.white,
        borderRadius: 12,
        margin: EdgeInsets.all(16),
        icon: Icon(Icons.error, color: Colors.white),
        duration: Duration(seconds: 3),
      );
    }
  }

  void _handleEmprendimientos() {
    print('🏪 HomeController: Navegando a pantalla de emprendedores...');
    Get.toNamed(AppRoutes.EMPRENDEDORES);
  }

  void _handleServicios() {
    // Lógica para "Servicios"
  }

  void _handleMiPerfil() {
    // Lógica para "Mi Perfil" - ya manejado por el dropdown
  }

  void _handleServiciosBottom() {
    print('🔄 HomeController: Navegando a pantalla de servicios...');
    Get.toNamed(AppRoutes.SERVICES_CAPACHICA);
  }

  void _handleEventos() {
    print('🏷️ HomeController: Navegando a pantalla de eventos...');
    Get.toNamed(AppRoutes.EVENTOS);
  }

  void _handlePlanesBottom() {
    Get.snackbar(
      'Planes',
      'Planifica tu visita perfecta',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF424242).withOpacity(0.95),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }
}