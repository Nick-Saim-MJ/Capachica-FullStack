import '../models/services_capachica_model.dart';
import '../providers/services_capachica_provider.dart';

class ServicesCapachicaRepository {
  final ServicesCapachicaProvider provider;

  ServicesCapachicaRepository(this.provider);

  Future<List<ServicioCapachica>> getServicios() async {
    return await provider.fetchServicios();
  }

  Future<ServicioCapachica> getServicioById(int id) async {
    return await provider.fetchServicioById(id);
  }

  Future<List<ServicioCapachica>> getServiciosByCategoria(int categoriaId) async {
    return await provider.fetchServiciosByCategoria(categoriaId);
  }

  Future<List<ServicioCapachica>> getServiciosByEmprendedor(int emprendedorId) async {
    return await provider.fetchServiciosByEmprendedor(emprendedorId);
  }
} 