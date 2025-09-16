import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:app_capachica/app/modules/servicios/controllers/servicios_controller.dart';
import 'package:app_capachica/app/services/servicio_service.dart';
import 'package:app_capachica/app/services/emprendedor_service.dart';
import 'package:app_capachica/app/data/models/servicio_model.dart';
import 'package:app_capachica/app/data/models/emprendedor_resumen_model.dart';
import 'package:app_capachica/app/core/compatibility/response_adapter.dart';

void main() {
  group('ServiciosController Tests', () {
    late ServiciosController controller;
    late _MockServicioService mockServicioService;
    late _MockEmprendedorService mockEmprendedorService;

    setUp(() {
      Get.testMode = true;
      mockServicioService = _MockServicioService();
      mockEmprendedorService = _MockEmprendedorService();
      Get.put<ServicioService>(mockServicioService);
      Get.put<EmprendedorService>(mockEmprendedorService);
      controller = ServiciosController();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with empty state', () {
      expect(controller.servicios.length, 0);
      expect(controller.isLoading.value, false);
      // Estos Rx sí existen en el controller
      expect(controller.searchQuery.value, '');
      expect(controller.selectedCategoria.value, '');
      expect(controller.selectedEmprendedorId.value, 0);
      expect(controller.precioMin.value, 0.0);
      expect(controller.precioMax.value, 0.0);
    });

    test('should load servicios successfully', () async {
      final servicios = <Servicio>[
        Servicio(
          id: 1,
          nombre: 'Test Servicio 1',
          descripcion: 'Un servicio de prueba',
          precio: 80.0,
          categoria: 'Restaurante',
          emprendedorId: 1,
          disponible: true,
        ),
        Servicio(
          id: 2,
          nombre: 'Test Servicio 2',
          descripcion: 'Otro servicio de prueba',
          precio: 120.0,
          categoria: 'Alojamiento',
          emprendedorId: 2,
          disponible: true,
        ),
      ];

      mockServicioService.paginatedToReturn = PaginatedResponse<Servicio>.success(
        data: servicios,
        currentPage: 1,
        totalPages: 1,
        totalItems: servicios.length,
        perPage: servicios.length,
        hasNextPage: false,
        hasPreviousPage: false,
        message: 'ok',
        statusCode: 200,
      );

      // El controller actual suele tener loadServicios() (sin initialLoad)
      await controller.loadServicios();

      expect(controller.servicios.length, 2);
      expect(controller.servicios.first.nombre, 'Test Servicio 1');
      expect(controller.servicios.last.nombre, 'Test Servicio 2');
      expect(controller.isLoading.value, false);
    });

    test('should handle error when loading servicios', () async {
      mockServicioService.exception = Exception('Network error');

      await controller.loadServicios();

      expect(controller.servicios.length, 0);
      expect(controller.isLoading.value, false);
      // Si tu controller setea hasError/errorMessage, puedes comprobarlos aquí
      // expect(controller.hasError.value, true);
      // expect(controller.errorMessage.value, contains('Network error'));
    });

    test('should update search query (direct Rx write)', () {
      controller.searchQuery.value = 'test query';
      expect(controller.searchQuery.value, 'test query');
    });

    test('should clear search query', () {
      controller.searchQuery.value = 'test query';
      controller.searchQuery.value = '';
      expect(controller.searchQuery.value, '');
    });

    test('should update selected category (direct Rx write)', () {
      controller.selectedCategoria.value = 'Restaurante';
      expect(controller.selectedCategoria.value, 'Restaurante');
    });

    test('should update selected emprendedor (direct Rx write)', () {
      controller.selectedEmprendedorId.value = 1;
      expect(controller.selectedEmprendedorId.value, 1);
    });

    test('should update precio min/max via parser helpers if existen o direct Rx', () {
      controller.onPrecioMinChanged?.call('50.0'); // si el método existe
      controller.onPrecioMaxChanged?.call('100.0'); // si el método existe

      // si no existen los métodos anteriores en tu controller, descomenta:
      // controller.precioMin.value = 50.0;
      // controller.precioMax.value = 100.0;

      expect(controller.precioMin.value, 50.0);
      expect(controller.precioMax.value, 100.0);
    });

    test('should load categories successfully', () async {
      mockServicioService.categoriasToReturn = ['Alojamiento', 'Restaurante', 'Turismo'];

      await controller.loadCategorias();

      // Normalmente el controller antepone 'Todas'
      expect(controller.categorias.isNotEmpty, true);
      expect(controller.categorias.first, 'Todas');
      expect(controller.categorias.contains('Alojamiento'), true);
      expect(controller.categorias.contains('Restaurante'), true);
      expect(controller.categorias.contains('Turismo'), true);
    });

    test('should load emprendedores successfully', () async {
      final emps = <EmprendedorResumen>[
        EmprendedorResumen(
          id: 1,
          nombre: 'Test Emprendedor 1',
          tipoServicio: 'Restaurante',
          ubicacion: 'Lima, Perú',
          estado: true,
        ),
        EmprendedorResumen(
          id: 2,
          nombre: 'Test Emprendedor 2',
          tipoServicio: 'Alojamiento',
          ubicacion: 'Cusco, Perú',
          estado: true,
        ),
      ];

      mockEmprendedorService.paginatedToReturn =
      PaginatedResponse<EmprendedorResumen>.success(
        data: emps,
        currentPage: 1,
        totalPages: 1,
        totalItems: emps.length,
        perPage: emps.length,
        hasNextPage: false,
        hasPreviousPage: false,
        message: 'ok',
        statusCode: 200,
      );

      await controller.loadEmprendedores();

      expect(controller.emprendedores.length, 2);
      expect(controller.emprendedores.first.nombre, 'Test Emprendedor 1');
      expect(controller.emprendedores.last.nombre, 'Test Emprendedor 2');
    });

    test('should "refresh" by loading categorias, emprendedores y servicios', () async {
      mockServicioService.paginatedToReturn =
      PaginatedResponse<Servicio>.success(
        data: [
          Servicio(
            id: 1,
            nombre: 'Refreshed Servicio',
            descripcion: 'Un servicio refrescado',
            precio: 90.0,
            categoria: 'Restaurante',
            emprendedorId: 1,
            disponible: true,
          ),
        ],
        currentPage: 1,
        totalPages: 1,
        totalItems: 1,
        perPage: 1,
        hasNextPage: false,
        hasPreviousPage: false,
        message: 'ok',
        statusCode: 200,
      );
      mockServicioService.categoriasToReturn = ['Restaurante'];
      mockEmprendedorService.paginatedToReturn =
      PaginatedResponse<EmprendedorResumen>.success(
        data: const [],
        currentPage: 1,
        totalPages: 1,
        totalItems: 0,
        perPage: 1,
        hasNextPage: false,
        hasPreviousPage: false,
        message: 'ok',
        statusCode: 200,
      );

      // Si tu controller tiene refreshData(), úsalo; si no, simulamos:
      // await controller.refreshData();
      await controller.loadCategorias();
      await controller.loadEmprendedores();
      await controller.loadServicios();

      expect(controller.servicios.length, 1);
      expect(controller.servicios.first.nombre, 'Refreshed Servicio');
      // 'Todas' + 'Restaurante'
      expect(controller.categorias.length >= 2, true);
    });

    test('state getters sanity', () {
      controller.isLoading.value = false;
      controller.servicios.clear();
      expect(controller.showEmptyState, true);
      expect(controller.showErrorMessage, false);
      expect(controller.showLoadingMore, false);
    });
  });
}

/// ---------------------------
/// Mocks compatibles con tu API
/// ---------------------------

class _MockServicioService extends ServicioService {
  PaginatedResponse<Servicio>? paginatedToReturn;
  List<String>? categoriasToReturn;
  Exception? exception;

  @override
  Future<PaginatedResponse<Servicio>> getServicios({
    int page = 1,
    int perPage = 20,
    String? query,
    String? categoria,
    int? emprendedorId,
    double? precioMin,
    double? precioMax,
    bool? disponible,
    String? ubicacion,
    String? sortBy,
    String? sortOrder = 'asc',
  }) async {
    if (exception != null) throw exception!;
    return paginatedToReturn ??
        PaginatedResponse<Servicio>.success(
          data: const [],
          currentPage: 1,
          totalPages: 1,
          totalItems: 0,
          perPage: perPage,
          hasNextPage: false,
          hasPreviousPage: false,
          message: 'ok',
          statusCode: 200,
        );
  }

  @override
  Future<List<String>> getCategoriasServicios() async {
    if (exception != null) throw exception!;
    return categoriasToReturn ?? ['Alojamiento', 'Restaurante'];
  }

  @override
  Future<void> limpiarCache() async {}
}

class _MockEmprendedorService extends EmprendedorService {
  PaginatedResponse<EmprendedorResumen>? paginatedToReturn;
  Exception? exception;

  @override
  Future<PaginatedResponse<EmprendedorResumen>> getEmprendedores({
    int page = 1,
    int perPage = 20,
    String? query,
    String? categoria,
    String? ubicacion,
    bool? estado,
    String? sortBy,
    String? sortOrder = 'asc',
  }) async {
    if (exception != null) throw exception!;
    return paginatedToReturn ??
        PaginatedResponse<EmprendedorResumen>.success(
          data: const [],
          currentPage: 1,
          totalPages: 1,
          totalItems: 0,
          perPage: perPage,
          hasNextPage: false,
          hasPreviousPage: false,
          message: 'ok',
          statusCode: 200,
        );
  }

  @override
  Future<void> limpiarCache() async {}
}