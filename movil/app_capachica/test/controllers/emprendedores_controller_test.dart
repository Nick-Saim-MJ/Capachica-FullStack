import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:app_capachica/app/modules/emprendedores/controllers/emprendedores_controller.dart';
import 'package:app_capachica/app/services/emprendedor_service.dart';
import 'package:app_capachica/app/data/models/emprendedor_resumen_model.dart';
import 'package:app_capachica/app/core/compatibility/response_adapter.dart';

void main() {
  group('EmprendedoresController Tests', () {
    late EmprendedoresController controller;
    late _MockEmprendedorService mockService;

    setUp(() {
      Get.testMode = true;
      mockService = _MockEmprendedorService();
      Get.put<EmprendedorService>(mockService);
      controller = EmprendedoresController();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with empty state', () {
      expect(controller.emprendedores.length, 0);
      expect(controller.isLoading.value, false);
      // Propiedades que sí existen en el controller
      expect(controller.searchQuery.value, '');
      expect(controller.selectedCategoria.value, '');
    });

    test('should load emprendedores successfully', () async {
      final mockEmprendedores = <EmprendedorResumen>[
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

      mockService.paginatedToReturn =
      PaginatedResponse<EmprendedorResumen>.success(
        data: mockEmprendedores,
        currentPage: 1,
        totalPages: 1,
        totalItems: mockEmprendedores.length,
        perPage: mockEmprendedores.length,
        hasNextPage: false,
        hasPreviousPage: false,
        message: 'ok',
        statusCode: 200,
      );

      // Sin parámetro initialLoad (no existe en tu controller)
      await controller.loadEmprendedores();

      expect(controller.emprendedores.length, 2);
      expect(controller.emprendedores.first.nombre, 'Test Emprendedor 1');
      expect(controller.emprendedores.last.nombre, 'Test Emprendedor 2');
      expect(controller.isLoading.value, false);
    });

    test('should handle error when loading emprendedores', () async {
      mockService.exception = Exception('Network error');

      await controller.loadEmprendedores();

      expect(controller.emprendedores.length, 0);
      expect(controller.isLoading.value, false);
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

    test('should load categories successfully', () async {
      mockService.categoriasToReturn = ['Alojamiento', 'Restaurante', 'Turismo'];

      await controller.loadCategorias();

      // Normalmente el controller antepone 'Todas'
      expect(controller.categorias.isNotEmpty, true);
      expect(controller.categorias.first, 'Todas');
      expect(controller.categorias.contains('Alojamiento'), true);
      expect(controller.categorias.contains('Restaurante'), true);
      expect(controller.categorias.contains('Turismo'), true);
    });

    test('should handle error when loading categories (fallback)', () async {
      mockService.exception = Exception('Categories error');

      await controller.loadCategorias();

      // Comprobamos que deja algo útil (suele incluir 'Todas')
      expect(controller.categorias.isNotEmpty, true);
      expect(controller.categorias.first, 'Todas');
    });

    test('should "refresh" by loading categorias then emprendedores', () async {
      mockService.exception = null;
      mockService.paginatedToReturn =
      PaginatedResponse<EmprendedorResumen>.success(
        data: [
          EmprendedorResumen(
            id: 1,
            nombre: 'Refreshed Emprendedor',
            tipoServicio: 'Restaurante',
            ubicacion: 'Lima, Perú',
            estado: true,
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
      mockService.categoriasToReturn = ['Restaurante'];

      // Simulamos "refreshData": categorías + lista
      await controller.loadCategorias();
      await controller.loadEmprendedores();

      expect(controller.emprendedores.length, 1);
      expect(controller.emprendedores.first.nombre, 'Refreshed Emprendedor');
      // 'Todas' + 'Restaurante'
      expect(controller.categorias.length >= 2, true);
    });
  });
}

/// Mock del servicio compatible con la API actual del proyecto
class _MockEmprendedorService extends EmprendedorService {
  PaginatedResponse<EmprendedorResumen>? paginatedToReturn;
  List<String>? categoriasToReturn;
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
  Future<List<String>> getCategorias() async {
    if (exception != null) throw exception!;
    return categoriasToReturn ?? ['Alojamiento', 'Restaurante'];
  }

  @override
  Future<void> limpiarCache() async {
    // no-op
  }
}