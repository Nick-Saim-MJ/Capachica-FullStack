import 'package:get/get.dart';
import '../../../data/models/services_capachica_model.dart';
import '../../../data/repositories/services_capachica_repository.dart';

class ServicesCapachicaController extends GetxController {
  final ServicesCapachicaRepository repository;
  ServicesCapachicaController(this.repository);

  var servicios = <ServicioCapachica>[].obs;
  var serviciosFiltrados = <ServicioCapachica>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var searchQuery = ''.obs;
  var categoriaSeleccionada = 0.obs; // 0 = todas las categorías

  @override
  void onInit() {
    super.onInit();
    fetchServicios();
  }

  void fetchServicios() async {
    try {
      print('🔄 ServicesCapachicaController: Iniciando carga de servicios...');
      isLoading.value = true;
      error.value = '';
      
      final data = await repository.getServicios();
      servicios.assignAll(data);
      serviciosFiltrados.assignAll(data);
      
      print('✅ ServicesCapachicaController: ${data.length} servicios cargados exitosamente');
    } catch (e) {
      print('❌ ServicesCapachicaController: Error cargando servicios: $e');
      error.value = e.toString();
      servicios.clear();
      serviciosFiltrados.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<ServicioCapachica?> fetchServicioById(int id) async {
    try {
      print('🔄 ServicesCapachicaController: Obteniendo servicio con ID: $id');
      isLoading.value = true;
      error.value = '';
      
      final servicio = await repository.getServicioById(id);
      print('✅ ServicesCapachicaController: Servicio $id obtenido exitosamente');
      if (servicio != null && !servicios.any((s) => s.id == servicio.id)) {
        servicios.add(servicio);
        serviciosFiltrados.add(servicio);
      }
      return servicio;
    } catch (e) {
      print('❌ ServicesCapachicaController: Error obteniendo servicio $id: $e');
      error.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void fetchServiciosByCategoria(int categoriaId) async {
    try {
      print('🔄 ServicesCapachicaController: Obteniendo servicios por categoría: $categoriaId');
      isLoading.value = true;
      error.value = '';
      
      final data = await repository.getServiciosByCategoria(categoriaId);
      servicios.assignAll(data);
      serviciosFiltrados.assignAll(data);
      categoriaSeleccionada.value = categoriaId;
      
      print('✅ ServicesCapachicaController: ${data.length} servicios por categoría cargados');
    } catch (e) {
      print('❌ ServicesCapachicaController: Error cargando servicios por categoría: $e');
      error.value = e.toString();
      servicios.clear();
      serviciosFiltrados.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void fetchServiciosByEmprendedor(int emprendedorId) async {
    try {
      print('🔄 ServicesCapachicaController: Obteniendo servicios por emprendedor: $emprendedorId');
      isLoading.value = true;
      error.value = '';
      
      final data = await repository.getServiciosByEmprendedor(emprendedorId);
      servicios.assignAll(data);
      serviciosFiltrados.assignAll(data);
      
      print('✅ ServicesCapachicaController: ${data.length} servicios por emprendedor cargados');
    } catch (e) {
      print('❌ ServicesCapachicaController: Error cargando servicios por emprendedor: $e');
      error.value = e.toString();
      servicios.clear();
      serviciosFiltrados.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void buscarServicios(String query) {
    searchQuery.value = query;
    _aplicarFiltros();
  }

  void filtrarPorCategoria(int categoriaId) {
    categoriaSeleccionada.value = categoriaId;
    _aplicarFiltros();
  }

  void limpiarFiltros() {
    searchQuery.value = '';
    categoriaSeleccionada.value = 0;
    serviciosFiltrados.assignAll(servicios);
  }

  void _aplicarFiltros() {
    var filtrados = List<ServicioCapachica>.from(servicios);

    // Filtrar por búsqueda
    if (searchQuery.value.isNotEmpty) {
      filtrados = filtrados.where((servicio) {
        final query = searchQuery.value.toLowerCase();
        return servicio.nombre.toLowerCase().contains(query) ||
               servicio.descripcion.toLowerCase().contains(query) ||
               servicio.emprendedor.nombre.toLowerCase().contains(query);
      }).toList();
    }

    // Filtrar por categoría
    if (categoriaSeleccionada.value > 0) {
      filtrados = filtrados.where((servicio) {
        return servicio.categorias.any((cat) => cat.id == categoriaSeleccionada.value);
      }).toList();
    }

    serviciosFiltrados.assignAll(filtrados);
  }

  void refreshServicios() {
    fetchServicios();
  }

  List<String> getCategoriasUnicas() {
    final categorias = <String>{};
    
    // Verificar que hay servicios disponibles
    if (servicios.isEmpty) return [];
    
    for (final servicio in servicios) {
      // Verificar que el servicio tiene categorías
      if (servicio.categorias.isNotEmpty) {
        for (final categoria in servicio.categorias) {
          // Verificar que la categoría tiene nombre válido
          if (categoria.nombre.isNotEmpty) {
            categorias.add(categoria.nombre);
          }
        }
      }
    }
    
    return categorias.toList()..sort();
  }

  List<ServicioCapachica> getServiciosDisponibles() {
    return servicios.where((servicio) => servicio.estado).toList();
  }

  List<ServicioCapachica> getServiciosPorPrecio({double? precioMaximo}) {
    if (precioMaximo == null) return servicios;
    
    return servicios.where((servicio) {
      try {
        final precio = double.tryParse(servicio.precioReferencial) ?? 0;
        return precio <= precioMaximo;
      } catch (e) {
        return false;
      }
    }).toList();
  }
} 