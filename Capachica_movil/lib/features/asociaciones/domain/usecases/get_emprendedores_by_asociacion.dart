// get_emprendedores_by_asociacion.dart
import '../entities/emprendedor.dart';
import '../repositories/asociacion_repository.dart';

class GetEmprendedoresByAsociacion {
  final AsociacionRepository repository;

  GetEmprendedoresByAsociacion(this.repository);

  Future<List<EmprendedorEntity>> call(int asociacionId) async {
    return await repository.getEmprendedoresByAsociacion(asociacionId);
  }
}

