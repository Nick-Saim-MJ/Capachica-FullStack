import 'package:flutter/foundation.dart'; // Usar debugPrint
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/servicio_model.dart';
import '../../../data/models/emprendedor_resumen_model.dart';
import '../../../services/servicio_service.dart';
import '../../../services/emprendedor_service.dart';
import '../../../core/config/app_config.dart';

class ServiciosController extends GetxController {
  final ServicioService _servicioService = ServicioService();
  final EmprendedorService _emprendedorService = EmprendedorService();

  // Lista de servicios
  final RxList<Servicio> servicios = <Servicio>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Paginación
  final RxInt currentPage = 1.obs;
  final RxInt perPage = AppConfig.defaultPageSize.obs;
  final RxBool hasMore = true.obs;

  // Búsqueda y filtros
  final RxString searchQuery = ''.obs;
  final RxList<String> categorias = <String>[].obs;
  final RxString selectedCategoria = ''.obs;
  final RxList<EmprendedorResumen> emprendedores = <EmprendedorResumen>[].obs;
  final RxInt selectedEmprendedorId = 0.obs;
  final RxDouble precioMin = 0.0.obs;
  final RxDouble precioMax = 0.0.obs;

  // Scroll controller para infinite scroll
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    selectedCategoria.value = 'Todas'; // Inicializar con 'Todas'
    loadInitialData();

    // Infinite scroll
    scrollController.addListener(_scrollListener);

    // Debounce de búsqueda
    debounce<String>(
      searchQuery,
          (_) => loadServicios(refresh: true),
      time: const Duration(milliseconds: 400),
    );

    // Filtros (recarga inmediata)
    ever<String>(selectedCategoria, (_) => loadServicios(refresh: true));
    ever<int>(selectedEmprendedorId, (_) => loadServicios(refresh: true));
    ever<double>(precioMin, (_) => loadServicios(refresh: true));
    ever<double>(precioMax, (_) => loadServicios(refresh: true));
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await loadCategorias();
    await loadEmprendedores();
    await loadServicios(refresh: true);
  }

  void _resetPagination() {
    currentPage.value = 1;
    hasMore.value = true;
    servicios.clear();
    hasError.value = false;
    errorMessage.value = '';
  }

  void _scrollListener() {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    final atBottom = scrollController.position.pixels >=
        (scrollController.position.maxScrollExtent - 200); // Umbral de 200px

    if (atBottom) {
      loadServicios();
    }
  }

  Future<void> loadServicios({bool refresh = false}) async {
    if (refresh) {
      _resetPagination();
    }

    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;

    if (refresh) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    hasError.value = false;

    try {
      // FIX: Llamada al servicio corregida.
      // Se asume que el parámetro se llama 'categoria' (string) y no 'categoriaId'.
      // Se eliminó 'forceRefresh' porque no estaba definido en el servicio.
      final response = await _servicioService.getServicios(
        page: currentPage.value,
        perPage: perPage.value,
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
        categoria: selectedCategoria.value == 'Todas' ? null : selectedCategoria.value,
        emprendedorId: selectedEmprendedorId.value == 0 ? null : selectedEmprendedorId.value,
        precioMin: precioMin.value > 0 ? precioMin.value : null,
        precioMax: precioMax.value > 0 ? precioMax.value : null,
      );

      // FIX: Manejo unificado de la respuesta paginada.
      // Siempre se espera un objeto con una lista 'data'.
      if (response.success && response.data != null) {
        final nuevosServicios = response.data!;
        if (refresh) {
          servicios.value = nuevosServicios;
        } else {
          servicios.addAll(nuevosServicios);
        }

        hasMore.value = response.hasNextPage;
        if (hasMore.value) {
          currentPage.value++;
        }

      } else {
        throw Exception(response.message ?? 'Error al cargar servicios');
      }

    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      debugPrint('❌ ServiciosController: Error cargando servicios: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadCategorias() async {
    try {
      final data = await _emprendedorService.getCategorias();
      categorias.value = ['Todas', ...data];
    } catch (e) {
      categorias.value = ['Todas', 'Alojamiento', 'Restaurante', 'Turismo', 'Artesanía', 'Transporte', 'Otros'];
      // FIX: Cambiado print por debugPrint para consistencia y buenas prácticas.
      debugPrint('Error al cargar categorías: $e');
    }
  }

  Future<void> loadEmprendedores() async {
    try {
      // FIX: Se asume que getEmprendedores siempre devuelve un objeto paginado.
      // Se accede a la propiedad 'data' para obtener la lista.
      final response = await _emprendedorService.getEmprendedores(page: 1, perPage: 100);
      if (response.success && response.data != null) {
        emprendedores.value = response.data!;
      }
    } catch (e) {
      emprendedores.clear();
      // FIX: Cambiado print por debugPrint.
      debugPrint('Error al cargar emprendedores: $e');
    }
  }

  Future<void> refreshData() async {
    await _servicioService.limpiarCache();
    await _emprendedorService.limpiarCache();
    await loadInitialData();
  }

  // Handlers de UI
  void onSearchChanged(String query) => searchQuery.value = query;
  void clearSearch() => searchQuery.value = '';

  void onCategorySelected(String? category) {
    selectedCategoria.value = category ?? 'Todas';
  }

  void onEmprendedorSelected(int? id) => selectedEmprendedorId.value = id ?? 0;
  void onPrecioMinChanged(String v) => precioMin.value = double.tryParse(v) ?? 0.0;
  void onPrecioMaxChanged(String v) => precioMax.value = double.tryParse(v) ?? 0.0;

  // Helpers para la vista
  bool get showLoadingMore => isLoadingMore.value;
  bool get showEmptyState => !isLoading.value && servicios.isEmpty && !hasError.value;
  bool get showErrorMessage => hasError.value && errorMessage.value.isNotEmpty;
}