import 'package:get/get.dart';
import '../../../data/models/evento_model.dart';
import '../../../services/evento_service.dart';
import '../../../data/repositories/evento_repository_impl.dart';
import '../../../domain/repositories/evento_repository.dart';
import '../../../domain/usecases/eventos_usecases.dart';

class EventosController extends GetxController {
  // Servicios y casos de uso
  late final EventoService _eventoService;
  late final EventoRepository _eventoRepository;
  late final GetAllEventosUseCase _getAllEventosUseCase;
  late final GetEventosProximosUseCase _getEventosProximosUseCase;
  late final GetEventosActivosUseCase _getEventosActivosUseCase;
  late final GetEventoByIdUseCase _getEventoByIdUseCase;
  late final GetEventosByEmprendedorUseCase _getEventosByEmprendedorUseCase;

  // Variables observables
  final eventos = <Evento>[].obs;
  final eventosProximos = <Evento>[].obs;
  final eventosActivos = <Evento>[].obs;
  final eventosEmprendedor = <Evento>[].obs;
  final eventoSeleccionado = Rxn<Evento>();
  
  // Estados de carga
  final isLoading = false.obs;
  final isLoadingProximos = false.obs;
  final isLoadingActivos = false.obs;
  final isLoadingDetalle = false.obs;
  final isLoadingEmprendedor = false.obs;
  
  // Estados de error
  final error = Rxn<String>();
  final errorProximos = Rxn<String>();
  final errorActivos = Rxn<String>();
  final errorDetalle = Rxn<String>();
  final errorEmprendedor = Rxn<String>();
  
  // Tab seleccionada
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎉 EventosController inicializado');
    
    // Inicializar servicios y casos de uso
    _eventoService = EventoService();
    _eventoRepository = EventoRepositoryImpl(_eventoService);
    _getAllEventosUseCase = GetAllEventosUseCase(_eventoRepository);
    _getEventosProximosUseCase = GetEventosProximosUseCase(_eventoRepository);
    _getEventosActivosUseCase = GetEventosActivosUseCase(_eventoRepository);
    _getEventoByIdUseCase = GetEventoByIdUseCase(_eventoRepository);
    _getEventosByEmprendedorUseCase = GetEventosByEmprendedorUseCase(_eventoRepository);
    
    // Cargar eventos iniciales
    loadEventos();
  }

  @override
  void onClose() {
    _eventoService.dispose();
    super.onClose();
  }

  // Cargar todos los eventos
  Future<void> loadEventos() async {
    try {
      print('🎉 EventosController: Cargando todos los eventos...');
      
      error.value = null;
      isLoading.value = true;
      
      final data = await _getAllEventosUseCase.execute();
      eventos.value = data;
      isLoading.value = false;
      
      print('✅ EventosController: Eventos cargados exitosamente (${data.length} eventos)');
      
    } catch (e) {
      print('❌ EventosController: Error cargando eventos: $e');
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  // Cargar próximos eventos
  Future<void> loadEventosProximos() async {
    try {
      print('🎉 EventosController: Cargando próximos eventos...');
      
      errorProximos.value = null;
      isLoadingProximos.value = true;
      
      final data = await _getEventosProximosUseCase.execute();
      eventosProximos.value = data;
      isLoadingProximos.value = false;
      
      print('✅ EventosController: Próximos eventos cargados exitosamente (${data.length} eventos)');
      
    } catch (e) {
      print('❌ EventosController: Error cargando próximos eventos: $e');
      errorProximos.value = e.toString();
      isLoadingProximos.value = false;
    }
  }

  // Cargar eventos activos
  Future<void> loadEventosActivos() async {
    try {
      print('🎉 EventosController: Cargando eventos activos...');
      
      errorActivos.value = null;
      isLoadingActivos.value = true;
      
      final data = await _getEventosActivosUseCase.execute();
      eventosActivos.value = data;
      isLoadingActivos.value = false;
      
      print('✅ EventosController: Eventos activos cargados exitosamente (${data.length} eventos)');
      
    } catch (e) {
      print('❌ EventosController: Error cargando eventos activos: $e');
      errorActivos.value = e.toString();
      isLoadingActivos.value = false;
    }
  }

  // Cargar detalle de evento
  Future<void> loadEventoDetalle(int id) async {
    try {
      print('🎉 EventosController: Cargando detalle del evento $id...');
      
      errorDetalle.value = null;
      isLoadingDetalle.value = true;
      
      final data = await _getEventoByIdUseCase.execute(id);
      eventoSeleccionado.value = data;
      isLoadingDetalle.value = false;
      
      print('✅ EventosController: Detalle del evento $id cargado exitosamente');
      
    } catch (e) {
      print('❌ EventosController: Error cargando detalle del evento $id: $e');
      errorDetalle.value = e.toString();
      isLoadingDetalle.value = false;
    }
  }

  // Cargar eventos de un emprendedor
  Future<void> loadEventosEmprendedor(int emprendedorId) async {
    try {
      print('🎉 EventosController: Cargando eventos del emprendedor $emprendedorId...');
      
      errorEmprendedor.value = null;
      isLoadingEmprendedor.value = true;
      
      final data = await _getEventosByEmprendedorUseCase.execute(emprendedorId);
      eventosEmprendedor.value = data;
      isLoadingEmprendedor.value = false;
      
      print('✅ EventosController: Eventos del emprendedor $emprendedorId cargados exitosamente (${data.length} eventos)');
      
    } catch (e) {
      print('❌ EventosController: Error cargando eventos del emprendedor $emprendedorId: $e');
      errorEmprendedor.value = e.toString();
      isLoadingEmprendedor.value = false;
    }
  }

  // Cambiar tab
  void onTabChanged(int index) {
    selectedTab.value = index;
    print('🎉 EventosController: Tab cambiada a índice $index');
    
    switch (index) {
      case 0: // Todos
        if (eventos.isEmpty) {
          loadEventos();
        }
        break;
      case 1: // Próximos
        if (eventosProximos.isEmpty) {
          loadEventosProximos();
        }
        break;
      case 2: // Activos
        if (eventosActivos.isEmpty) {
          loadEventosActivos();
        }
        break;
    }
  }

  // Navegar al detalle de un evento
  void onEventoTap(Evento evento) {
    print('🎉 EventosController: Navegando al detalle del evento ${evento.id}');
    Get.toNamed('/eventos/detail/${evento.id}');
  }

  // Navegar a eventos de un emprendedor
  void onEmprendedorEventosTap(int emprendedorId) {
    print('🎉 EventosController: Navegando a eventos del emprendedor $emprendedorId');
    Get.toNamed('/eventos/emprendedor/$emprendedorId');
  }

  // Refrescar datos
  Future<void> refreshEventos() async {
    print('🎉 EventosController: Refrescando eventos...');
    await loadEventos();
  }

  Future<void> refreshProximos() async {
    print('🎉 EventosController: Refrescando próximos eventos...');
    await loadEventosProximos();
  }

  Future<void> refreshActivos() async {
    print('🎉 EventosController: Refrescando eventos activos...');
    await loadEventosActivos();
  }
} 