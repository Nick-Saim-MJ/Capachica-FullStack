import 'package:get/get.dart';
import '../../../data/models/plan_model.dart';
import '../../../domain/usecases/planes_usecases.dart';
import '../../../core/exceptions/api_exception.dart';

class PlanesController extends GetxController {
  final GetPlanesPublicosUseCase _getPlanesPublicosUseCase;
  final SearchPlanesUseCase _searchPlanesUseCase;

  PlanesController({
    required GetPlanesPublicosUseCase getPlanesPublicosUseCase,
    required SearchPlanesUseCase searchPlanesUseCase,
  })  : _getPlanesPublicosUseCase = getPlanesPublicosUseCase,
        _searchPlanesUseCase = searchPlanesUseCase;

  // Estados observables
  final RxList<Plan> planes = <Plan>[].obs;
  final RxList<Plan> planesFiltrados = <Plan>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoria = ''.obs;

  // Categorías disponibles para filtros
  final List<String> categorias = [
    'Todas',
    'Aventura',
    'Cultural',
    'Gastronomía',
    'Naturaleza',
    'Relax',
  ];

  @override
  void onInit() {
    super.onInit();
    loadPlanes();
  }

  // Cargar planes públicos
  Future<void> loadPlanes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print('🗺️ PlanesController: Cargando planes...');
      final planesData = await _getPlanesPublicosUseCase();
      
      planes.value = planesData;
      planesFiltrados.value = planesData;
      
      print('✅ PlanesController: ${planesData.length} planes cargados');
    } catch (e) {
      print('❌ PlanesController: Error cargando planes: $e');
      errorMessage.value = _getErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Buscar planes
  Future<void> searchPlanes({
    String? query,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? duracionMin,
    int? duracionMax,
    String? ubicacion,
  }) async {
    try {
      isSearching.value = true;
      errorMessage.value = '';
      
      print('🗺️ PlanesController: Buscando planes...');
      final planesData = await _searchPlanesUseCase(
        query: query,
        categoria: categoria,
        precioMin: precioMin,
        precioMax: precioMax,
        duracionMin: duracionMin,
        duracionMax: duracionMax,
        ubicacion: ubicacion,
      );
      
      planesFiltrados.value = planesData;
      print('✅ PlanesController: ${planesData.length} planes encontrados');
    } catch (e) {
      print('❌ PlanesController: Error buscando planes: $e');
      errorMessage.value = _getErrorMessage(e);
    } finally {
      isSearching.value = false;
    }
  }

  // Filtrar por texto de búsqueda
  void filterByQuery(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      // Si no hay query, mostrar todos los planes o aplicar filtro de categoría
      if (selectedCategoria.value.isEmpty || selectedCategoria.value == 'Todas') {
        planesFiltrados.value = planes;
      } else {
        planesFiltrados.value = planes.where((plan) =>
          plan.categoria?.toLowerCase() == selectedCategoria.value.toLowerCase()
        ).toList();
      }
    } else {
      // Filtrar por query y categoría
      var filtered = planes.where((plan) =>
        plan.titulo.toLowerCase().contains(query.toLowerCase()) ||
        (plan.descripcion?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();

      if (selectedCategoria.value.isNotEmpty && selectedCategoria.value != 'Todas') {
        filtered = filtered.where((plan) =>
          plan.categoria?.toLowerCase() == selectedCategoria.value.toLowerCase()
        ).toList();
      }

      planesFiltrados.value = filtered;
    }
  }

  // Filtrar por categoría
  void filterByCategoria(String categoria) {
    selectedCategoria.value = categoria;
    
    if (categoria.isEmpty || categoria == 'Todas') {
      // Mostrar todos los planes o aplicar filtro de búsqueda
      if (searchQuery.value.isEmpty) {
        planesFiltrados.value = planes;
      } else {
        planesFiltrados.value = planes.where((plan) =>
          plan.titulo.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (plan.descripcion?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
        ).toList();
      }
    } else {
      // Filtrar por categoría y búsqueda
      var filtered = planes.where((plan) =>
        plan.categoria?.toLowerCase() == categoria.toLowerCase()
      ).toList();

      if (searchQuery.value.isNotEmpty) {
        filtered = filtered.where((plan) =>
          plan.titulo.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (plan.descripcion?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
        ).toList();
      }

      planesFiltrados.value = filtered;
    }
  }

  // Limpiar filtros
  void clearFilters() {
    searchQuery.value = '';
    selectedCategoria.value = '';
    planesFiltrados.value = planes;
  }

  // Navegar a detalles del plan
  void navigateToPlanDetalle(Plan plan) {
    print('🗺️ PlanesController: Navegando a detalles del plan ${plan.id}');
    Get.toNamed('/plan-detalle', arguments: plan.id);
  }

  // Recargar planes
  Future<void> refreshPlanes() async {
    await loadPlanes();
  }

  // Obtener mensaje de error
  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return 'Error de conexión. Verifica tu internet.';
    } else if (error is NotFoundException) {
      return 'No se encontraron planes.';
    } else {
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  // Verificar si hay planes
  bool get hasPlanes => planesFiltrados.isNotEmpty;
  
  // Verificar si está cargando
  bool get isCurrentlyLoading => isLoading.value;
  
  // Verificar si está buscando
  bool get isCurrentlySearching => isSearching.value;
  
  // Verificar si hay error
  bool get hasError => errorMessage.value.isNotEmpty;
} 