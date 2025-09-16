import 'package:app_capachica/app/data/models/emprendedor_model.dart';
import 'package:app_capachica/app/data/models/emprendedor_resumen_model.dart';
import 'package:app_capachica/app/data/models/services_capachica_model.dart';
import 'package:app_capachica/app/data/repositories/emprendedor_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class EmprendedoresController extends GetxController {
  final EmprendedoresCapachicaRepository repository;
  final TextEditingController searchController = TextEditingController();

  EmprendedoresController(this.repository);

  // Estados principales
  final emprendedores = <EmprendedorResumen>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Estados de búsqueda y filtros
  final searchQuery = ''.obs;
  final selectedCategoria = ''.obs;

  // Worker para manejar el debounce de búsqueda
  late Worker _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🏪 EmprendedoresCapachicaController: Inicializando...');

    // Configurar debounce: se ejecuta cuando cambia searchQuery
    _searchDebounce = debounce<String>(
      searchQuery,
          (q) async {
        debugPrint('🔍 EmprendedoresCapachicaController: Buscando con query: "$q"');
        await buscarEmprendedores(q);
      },
      time: const Duration(milliseconds: 400),
    );

    fetchEmprendedores();
  }

  @override
  void onClose() {
    // Liberar el worker del debounce
    _searchDebounce.dispose();
    super.onClose();
  }

  /// Cargar todos los emprendedores
  Future<void> fetchEmprendedores() async {
    try {
      debugPrint('🔄 EmprendedoresCapachicaController: Iniciando carga de emprendedores...');
      isLoading.value = true;
      error.value = '';

      final data = await repository.getEmprendedores();
      emprendedores.assignAll(data);

      print('✅ EmprendedoresCapachicaController: ${data.length} emprendedores cargados exitosamente');
    } catch (e) {
      debugPrint('❌ EmprendedoresCapachicaController: Error cargando emprendedores: $e');
      error.value = e.toString();
      emprendedores.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener un emprendedor por su ID
  Future<Emprendedor?> fetchEmprendedorById(int id) async {
    try {
      debugPrint('🔄 EmprendedoresCapachicaController: Obteniendo emprendedor con ID: $id');
      isLoading.value = true;
      error.value = '';

      final emprendedor = await repository.getEmprendedorById(id);
      debugPrint('✅ EmprendedoresCapachicaController: Emprendedor $id obtenido exitosamente');
      return emprendedor;
    } catch (e) {
      debugPrint('❌ EmprendedoresCapachicaController: Error obteniendo emprendedor $id: $e');
      error.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Buscar emprendedores por un query de texto
  Future<void> buscarEmprendedores(String query) async {
    try {
      debugPrint('🔄 EmprendedoresCapachicaController: Buscando emprendedores...');
      isLoading.value = true;
      error.value = '';

      if (query.isEmpty) {
        await fetchEmprendedores();
        return;
      }

      final data = await repository.searchEmprendedores(query);
      emprendedores.assignAll(data);

      debugPrint('✅ EmprendedoresCapachicaController: ${data.length} resultados de búsqueda cargados');
    } catch (e) {
      debugPrint('❌ EmprendedoresCapachicaController: Error en la búsqueda de emprendedores: $e');
      error.value = e.toString();
      emprendedores.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtrar por categoría
  Future<void> filterByCategoria(String categoria) async {
    try {
      debugPrint('🏷️ EmprendedoresCapachicaController: Filtrando por categoría: "$categoria"');
      isLoading.value = true;
      error.value = '';

      selectedCategoria.value = categoria;
      final data = await repository.getEmprendedoresByCategoria(categoria);
      emprendedores.assignAll(data);

      debugPrint('✅ EmprendedoresCapachicaController: ${data.length} emprendedores por categoría cargados');
    } catch (e) {
      debugPrint('❌ EmprendedoresCapachicaController: Error cargando emprendedores por categoría: $e');
      error.value = e.toString();
      emprendedores.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpiar filtros de búsqueda y categoría
  void clearFilters() {
    debugPrint('🧹 EmprendedoresCapachicaController: Limpiando filtros...');
    searchQuery.value = '';
    selectedCategoria.value = '';
    fetchEmprendedores();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    // Recargar los emprendedores con los filtros por defecto
    fetchEmprendedores();
  }

  /// Refrescar la lista de emprendedores
  Future<void> refreshEmprendedores() async {
    debugPrint('🔄 EmprendedoresCapachicaController: Refrescando emprendedores...');
    clearFilters(); // Opcional, para refrescar la lista completa
  }

  /// Obtener servicios de un emprendedor específico
  Future<List<ServicioCapachica>> getServiciosByEmprendedor(int id) async {
    try {
      isLoading.value = true;
      error.value = '';
      return await repository.getServiciosByEmprendedor(id);
    } catch (e) {
      error.value = e.toString();
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener lista de categorías únicas de los emprendedores cargados
  List<String> get categoriasUnicas {
    final categoriasSet = <String>{};
    for (var emp in emprendedores) {
      if (emp.tipoServicio.isNotEmpty) {
        categoriasSet.add(emp.tipoServicio);
      }
    }
    return categoriasSet.toList();
  }

  // Getters para UI
  bool get hasEmprendedores => emprendedores.isNotEmpty;
  bool get hasSearchResults => searchQuery.value.isNotEmpty;
  bool get hasCategoriaFilter => selectedCategoria.value.isNotEmpty;
}