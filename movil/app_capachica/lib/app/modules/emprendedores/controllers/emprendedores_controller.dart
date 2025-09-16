import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/emprendedor_model.dart';
import '../../../data/models/emprendedor_resumen_model.dart';
import '../../../services/emprendedor_service.dart';
import '../../../core/utils/pagination_helper.dart';

class EmprendedoresController extends GetxController {
  final EmprendedorService _emprendedorService = EmprendedorService();

  // Estados principales
  final emprendedores = <EmprendedorResumen>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;
  final hasMore = true.obs;

  // Estados de búsqueda y filtros
  final searchQuery = ''.obs;
  final selectedCategoria = ''.obs;
  final selectedUbicacion = ''.obs;
  final categorias = <String>[].obs;
  final ubicaciones = <String>[].obs;

  // Estados de paginación
  final currentPage = 1.obs;
  final perPage = 20.obs;
  final totalItems = 0.obs;
  final totalPages = 0.obs;

  // Estados de ordenamiento
  final sortBy = ''.obs;
  final sortOrder = 'asc'.obs;

  // Estado de paginación
  late PaginationState _paginationState;

  // Worker para manejar el debounce de búsqueda
  late Worker _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🏪 EmprendedoresController: Inicializando...');
    _initializePagination();

    // Configurar debounce: se ejecuta cuando cambia searchQuery
    _searchDebounce = debounce<String>(
      searchQuery,
          (q) async {
        debugPrint('🔍 EmprendedoresController: Buscando con query: "$q"');
        await loadEmprendedores(refresh: true);
      },
      time: const Duration(milliseconds: 400),
    );

    loadEmprendedores();
    loadCategorias();
    loadUbicaciones();
  }

  @override
  void onClose() {
    // Liberar el worker del debounce
    _searchDebounce.dispose();
    super.onClose();
  }

  /// Inicializar estado de paginación
  void _initializePagination() {
    _paginationState = PaginationHelper.createInitialPaginationState(
      perPage: perPage.value,
    );
  }

  /// Cargar emprendedores con paginación
  Future<void> loadEmprendedores({bool refresh = false}) async {
    try {
      if (refresh) {
        _resetPagination();
      }

      if (isLoading.value || isLoadingMore.value) return;

      if (refresh) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      error.value = '';

      debugPrint('🔄 EmprendedoresController: Cargando emprendedores (página ${currentPage.value})...');

      final response = await _emprendedorService.getEmprendedores(
        page: currentPage.value,
        perPage: perPage.value,
        query: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        categoria: selectedCategoria.value.isNotEmpty ? selectedCategoria.value : null,
        ubicacion: selectedUbicacion.value.isNotEmpty ? selectedUbicacion.value : null,
        sortBy: sortBy.value.isNotEmpty ? sortBy.value : null,
        sortOrder: sortOrder.value,
      );

      if (response.success && response.data != null) {
        _updatePaginationState(response);

        if (refresh) {
          emprendedores.value = response.data!;
        } else {
          emprendedores.addAll(response.data!);
        }

        hasMore.value = response.hasNextPage;
        totalItems.value = response.totalItems;
        totalPages.value = response.totalPages;

        debugPrint('✅ EmprendedoresController: ${response.data!.length} emprendedores cargados (${emprendedores.length} total)');
      } else {
        throw response.message;
      }
    } catch (e) {
      error.value = e.toString();
      debugPrint('❌ EmprendedoresController: Error cargando emprendedores: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Cargar más emprendedores (infinite scroll)
  Future<void> loadMoreEmprendedores() async {
    if (!hasMore.value || isLoadingMore.value) return;

    currentPage.value++;
    await loadEmprendedores();
  }

  /// Refrescar lista de emprendedores
  Future<void> refreshEmprendedores() async {
    debugPrint('🔄 EmprendedoresController: Refrescando emprendedores...');
    await loadEmprendedores(refresh: true);
  }

  /// Actualiza el Rx para que dispare el debounce configurado en onInit
  void searchEmprendedores(String query) {
    searchQuery.value = query;
  }

  /// Filtrar por categoría
  Future<void> filterByCategoria(String categoria) async {
    debugPrint('🏷️ EmprendedoresController: Filtrando por categoría: "$categoria"');
    selectedCategoria.value = categoria;
    await loadEmprendedores(refresh: true);
  }

  /// Filtrar por ubicación
  Future<void> filterByUbicacion(String ubicacion) async {
    debugPrint('📍 EmprendedoresController: Filtrando por ubicación: "$ubicacion"');
    selectedUbicacion.value = ubicacion;
    await loadEmprendedores(refresh: true);
  }

  /// Ordenar emprendedores
  Future<void> sortEmprendedores(String field, String order) async {
    debugPrint('📊 EmprendedoresController: Ordenando por $field ($order)');
    sortBy.value = field;
    sortOrder.value = order;
    await loadEmprendedores(refresh: true);
  }

  /// Cargar categorías disponibles
  Future<void> loadCategorias() async {
    try {
      debugPrint('🏷️ EmprendedoresController: Cargando categorías...');
      final categoriasList = await _emprendedorService.getCategorias();
      categorias.value = categoriasList;
      debugPrint('✅ EmprendedoresController: ${categoriasList.length} categorías cargadas');
    } catch (e) {
      debugPrint('❌ EmprendedoresController: Error cargando categorías: $e');
      categorias.value = [
        'Alojamiento',
        'Restaurante',
        'Turismo',
        'Artesanía',
        'Transporte',
        'Otros'
      ];
    }
  }

  /// Cargar ubicaciones disponibles
  Future<void> loadUbicaciones() async {
    try {
      debugPrint('📍 EmprendedoresController: Cargando ubicaciones...');
      ubicaciones.value = [
        'Capachica',
        'Llachón',
        'Amantaní',
        'Taquile',
        'Uros',
        'Puno',
      ];
      debugPrint('✅ EmprendedoresController: ${ubicaciones.length} ubicaciones cargadas');
    } catch (e) {
      debugPrint('❌ EmprendedoresController: Error cargando ubicaciones: $e');
    }
  }

  /// Limpiar búsqueda
  void clearSearch() {
    debugPrint('🧹 EmprendedoresController: Limpiando búsqueda...');
    searchQuery.value = '';
    loadEmprendedores(refresh: true);
  }

  /// Limpiar filtros
  void clearFilters() {
    debugPrint('🧹 EmprendedoresController: Limpiando filtros...');
    selectedCategoria.value = '';
    selectedUbicacion.value = '';
    sortBy.value = '';
    sortOrder.value = 'asc';
    loadEmprendedores(refresh: true);
  }

  /// Limpiar todo (búsqueda y filtros)
  void clearAll() {
    debugPrint('🧹 EmprendedoresController: Limpiando todo...');
    searchQuery.value = '';
    clearFilters();
  }

  /// Verificar si hay filtros activos
  bool get hasActiveFilters =>
      selectedCategoria.value.isNotEmpty ||
          selectedUbicacion.value.isNotEmpty ||
          sortBy.value.isNotEmpty;

  /// Verificar si hay búsqueda activa
  bool get hasActiveSearch => searchQuery.value.isNotEmpty;

  /// Información de paginación
  String get paginationInfo {
    if (totalItems.value == 0) return 'No hay emprendedores';
    final start = ((currentPage.value - 1) * perPage.value) + 1;
    final end = (start + emprendedores.length - 1).clamp(1, totalItems.value);
    return 'Mostrando $start-$end de ${totalItems.value} emprendedores';
  }

  /// Información de página
  String get pageInfo =>
      totalPages.value == 0 ? 'Página 1 de 1' : 'Página ${currentPage.value} de ${totalPages.value}';

  bool get canLoadMore => hasMore.value && !isLoadingMore.value && !isLoading.value;
  bool get isAnyLoading => isLoading.value || isLoadingMore.value;

  void _resetPagination() {
    currentPage.value = 1;
    hasMore.value = true;
    totalItems.value = 0;
    totalPages.value = 0;
    _paginationState = PaginationHelper.refreshPagination(_paginationState);
  }

  void _updatePaginationState(dynamic response) {
    _paginationState = PaginationHelper.updatePaginationState(
      _paginationState,
      response.data ?? [],
      totalItems: response.totalItems,
      isLoading: false,
    );
  }

  Future<List<EmprendedorResumen>> getEmprendedoresDestacados() async {
    try {
      debugPrint('⭐ EmprendedoresController: Obteniendo emprendedores destacados...');
      final destacados = await _emprendedorService.getEmprendedoresDestacados();
      debugPrint('✅ EmprendedoresController: ${destacados.length} emprendedores destacados obtenidos');
      return destacados;
    } catch (e) {
      debugPrint('❌ EmprendedoresController: Error obteniendo emprendedores destacados: $e');
      return [];
    }
  }

  void navigateToDetail(EmprendedorResumen emprendedor) {
    debugPrint('👤 EmprendedoresController: Navegando al detalle de ${emprendedor.nombre}');
    Get.toNamed('/emprendedores/detail/${emprendedor.id}', arguments: emprendedor);
  }

  Future<Emprendedor?> getEmprendedorById(int id) async {
    try {
      debugPrint('👤 EmprendedoresController: Obteniendo emprendedor ID: $id');
      final emprendedor = await _emprendedorService.getEmprendedor(id);
      debugPrint('✅ EmprendedoresController: Emprendedor obtenido: ${emprendedor.nombre}');
      return emprendedor;
    } catch (e) {
      debugPrint('❌ EmprendedoresController: Error obteniendo emprendedor: $e');
      return null;
    }
  }

  Future<Emprendedor?> fetchEmprendedorById(int id) async => getEmprendedorById(id);

  Future<List<RelacionEmprendedor>> getEmprendedorRelaciones(int id) async {
    try {
      debugPrint('🔗 EmprendedoresController: Obteniendo relaciones del emprendedor ID: $id');
      final emprendedor = await _emprendedorService.getEmprendedor(id);
      final relaciones = emprendedor.relaciones ?? [];
      debugPrint('✅ EmprendedoresController: ${relaciones.length} relaciones obtenidas');
      return relaciones;
    } catch (e) {
      debugPrint('❌ EmprendedoresController: Error obteniendo relaciones: $e');
      return [];
    }
  }

  Future<List<ServicioEmprendedor>> getEmprendedorServicios(int id) async {
    try {
      debugPrint('🛠️ EmprendedoresController: Obteniendo servicios del emprendedor ID: $id');
      final emprendedor = await _emprendedorService.getEmprendedor(id);
      final servicios = emprendedor.servicios ?? [];
      debugPrint('✅ EmprendedoresController: ${servicios.length} servicios obtenidos');
      return servicios;
    } catch (e) {
      debugPrint('❌ EmprendedoresController: Error obteniendo servicios: $e');
      return [];
    }
  }

  Future<void> invalidarCache() async {
    debugPrint('🗑️ EmprendedoresController: Invalidando cache...');
    await _emprendedorService.limpiarCache();
  }

  // Getters para UI (compatibilidad)
  bool get hasEmprendedores => emprendedores.isNotEmpty;
  bool get hasSearchResults => searchQuery.value.isNotEmpty;
  bool get hasCategoriaFilter => selectedCategoria.value.isNotEmpty;
  int get totalEmprendedores => emprendedores.length;
  int get filteredCount => emprendedores.length;
}