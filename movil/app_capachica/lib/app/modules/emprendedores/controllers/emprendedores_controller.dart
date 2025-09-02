import 'package:get/get.dart';
import '../../../data/models/emprendedor_model.dart';
import '../../../services/emprendedor_service.dart';

class EmprendedoresController extends GetxController {
  final EmprendedorService _emprendedorService = EmprendedorService();

  // Variables observables
  final emprendedores = <Emprendedor>[].obs;
  final filteredEmprendedores = <Emprendedor>[].obs;
  final categorias = <String>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final selectedCategoria = ''.obs;
  final isSearching = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🏪 EmprendedoresController: Inicializando...');
    cargarEmprendedores();
    loadCategorias();
  }

  // Método para cargar emprendedores (alias para compatibilidad)
  Future<void> cargarEmprendedores() async {
    await loadEmprendedores();
  }

  @override
  void onClose() {
    _emprendedorService.dispose();
    super.onClose();
  }

  // Cargar lista completa de emprendedores
  Future<void> loadEmprendedores() async {
    try {
      print('🔄 EmprendedoresController: Cargando emprendedores...');
      
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await _emprendedorService.getEmprendedores();
      emprendedores.value = data;
      filteredEmprendedores.value = data;

      print('✅ EmprendedoresController: ${data.length} emprendedores cargados');
      
    } catch (e) {
      print('❌ EmprendedoresController: Error cargando emprendedores: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Cargar categorías disponibles
  Future<void> loadCategorias() async {
    try {
      print('🏷️ EmprendedoresController: Cargando categorías...');
      
      final data = await _emprendedorService.getCategorias();
      categorias.value = data;
      
      print('✅ EmprendedoresController: ${data.length} categorías cargadas');
      
    } catch (e) {
      print('❌ EmprendedoresController: Error cargando categorías: $e');
      // Usar categorías por defecto en caso de error
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

  // Buscar emprendedores
  Future<void> searchEmprendedores(String query) async {
    try {
      print('🔍 EmprendedoresController: Buscando emprendedores con query: "$query"');
      
      if (query.trim().isEmpty) {
        // Si la búsqueda está vacía, mostrar todos
        filteredEmprendedores.value = emprendedores;
        return;
      }

      isSearching.value = true;
      searchQuery.value = query;

      final results = await _emprendedorService.searchEmprendedores(query);
      filteredEmprendedores.value = results;

      print('✅ EmprendedoresController: ${results.length} resultados encontrados');
      
    } catch (e) {
      print('❌ EmprendedoresController: Error en búsqueda: $e');
      // En caso de error, filtrar localmente
      _filterLocalEmprendedores(query);
    } finally {
      isSearching.value = false;
    }
  }

  // Filtro local como fallback
  void _filterLocalEmprendedores(String query) {
    final lowercaseQuery = query.toLowerCase();
    final filtered = emprendedores.where((emprendedor) {
      return emprendedor.nombre.toLowerCase().contains(lowercaseQuery) ||
             emprendedor.tipoServicio.toLowerCase().contains(lowercaseQuery) ||
             emprendedor.ubicacion.toLowerCase().contains(lowercaseQuery) ||
             (emprendedor.descripcion?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
    
    filteredEmprendedores.value = filtered;
    print('🔍 EmprendedoresController: Filtro local aplicado, ${filtered.length} resultados');
  }

  // Filtrar por categoría
  Future<void> filterByCategoria(String categoria) async {
    try {
      print('🏷️ EmprendedoresController: Filtrando por categoría: "$categoria"');
      
      if (categoria.isEmpty) {
        // Si no hay categoría seleccionada, mostrar todos
        filteredEmprendedores.value = emprendedores;
        selectedCategoria.value = '';
        return;
      }

      isLoading.value = true;
      selectedCategoria.value = categoria;

      final results = await _emprendedorService.getEmprendedoresByCategoria(categoria);
      filteredEmprendedores.value = results;

      print('✅ EmprendedoresController: ${results.length} emprendedores en categoría "$categoria"');
      
    } catch (e) {
      print('❌ EmprendedoresController: Error filtrando por categoría: $e');
      // En caso de error, filtrar localmente
      _filterLocalByCategoria(categoria);
    } finally {
      isLoading.value = false;
    }
  }

  // Filtro local por categoría como fallback
  void _filterLocalByCategoria(String categoria) {
    final filtered = emprendedores.where((emprendedor) {
      return emprendedor.tipoServicio.toLowerCase().contains(categoria.toLowerCase());
    }).toList();
    
    filteredEmprendedores.value = filtered;
    print('🏷️ EmprendedoresController: Filtro local por categoría aplicado, ${filtered.length} resultados');
  }

  // Limpiar filtros
  void clearFilters() {
    print('🧹 EmprendedoresController: Limpiando filtros...');
    
    searchQuery.value = '';
    selectedCategoria.value = '';
    filteredEmprendedores.value = emprendedores;
    isSearching.value = false;
  }

  // Refrescar datos
  Future<void> refreshData() async {
    print('🔄 EmprendedoresController: Refrescando datos...');
    await loadEmprendedores();
    await loadCategorias();
  }

  // Navegar al detalle de un emprendedor
  void navigateToDetail(Emprendedor emprendedor) {
    print('👤 EmprendedoresController: Navegando al detalle de ${emprendedor.nombre}');
    Get.toNamed('/emprendedores/detail/${emprendedor.id}', arguments: emprendedor);
  }

  // Obtener emprendedor por ID
  Future<Emprendedor?> getEmprendedorById(int id) async {
    try {
      print('👤 EmprendedoresController: Obteniendo emprendedor ID: $id');
      
      final emprendedor = await _emprendedorService.getEmprendedorById(id);
      print('✅ EmprendedoresController: Emprendedor obtenido: ${emprendedor.nombre}');
      return emprendedor;
      
    } catch (e) {
      print('❌ EmprendedoresController: Error obteniendo emprendedor: $e');
      return null;
    }
  }

  // Método para navegación dinámica
  Future<Emprendedor?> fetchEmprendedorById(int id) async {
    return await getEmprendedorById(id);
  }

  // Obtener relaciones de un emprendedor
  Future<List<RelacionEmprendedor>> getEmprendedorRelaciones(int id) async {
    try {
      print('🔗 EmprendedoresController: Obteniendo relaciones del emprendedor ID: $id');
      
      final relaciones = await _emprendedorService.getEmprendedorRelaciones(id);
      print('✅ EmprendedoresController: ${relaciones.length} relaciones obtenidas');
      return relaciones;
      
    } catch (e) {
      print('❌ EmprendedoresController: Error obteniendo relaciones: $e');
      return [];
    }
  }

  // Obtener servicios de un emprendedor
  Future<List<ServicioEmprendedor>> getEmprendedorServicios(int id) async {
    try {
      print('🛠️ EmprendedoresController: Obteniendo servicios del emprendedor ID: $id');
      
      final servicios = await _emprendedorService.getEmprendedorServicios(id);
      print('✅ EmprendedoresController: ${servicios.length} servicios obtenidos');
      return servicios;
      
    } catch (e) {
      print('❌ EmprendedoresController: Error obteniendo servicios: $e');
      return [];
    }
  }

  // Getters para UI
  bool get hasEmprendedores => filteredEmprendedores.isNotEmpty;
  bool get hasSearchResults => searchQuery.value.isNotEmpty;
  bool get hasCategoriaFilter => selectedCategoria.value.isNotEmpty;
  int get totalEmprendedores => emprendedores.length;
  int get filteredCount => filteredEmprendedores.length;
} 