import 'package:app_capachica/app/data/models/emprendedor_model.dart';
import 'package:app_capachica/app/data/models/emprendedor_resumen_model.dart';
import 'package:app_capachica/app/data/models/services_capachica_model.dart';
import 'package:app_capachica/app/data/providers/emprendedor_provider.dart';

class EmprendedoresCapachicaRepository {
  final EmprendedoresCapachicaProvider provider;

  EmprendedoresCapachicaRepository(this.provider);

  Future<List<EmprendedorResumen>> getEmprendedores() async {
    return await provider.fetchEmprendedores();
  }

  Future<Emprendedor> getEmprendedorById(int id) async {
    return await provider.fetchEmprendedorById(id);
  }

  Future<List<EmprendedorResumen>> getEmprendedoresByCategoria(String categoria) async {
    return await provider.fetchEmprendedoresByCategoria(categoria);
  }

  Future<List<EmprendedorResumen>> getEmprendedoresByAsociacion(int asociacionId) async {
    return await provider.fetchEmprendedoresByAsociacion(asociacionId);
  }

  Future<List<EmprendedorResumen>> searchEmprendedores(String query) async {
    return await provider.searchEmprendedores(query);
  }

  Future<List<ServicioCapachica>> getServiciosByEmprendedor(int id) async {
    return await provider.getServiciosByEmprendedor(id);
  }
}