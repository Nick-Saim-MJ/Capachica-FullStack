// get_asociaciones_by_municipalidad.dart
import '../entities/asociacion.dart';
import '../repositories/asociacion_repository.dart';

class GetAsociacionesByMunicipalidad {
  final AsociacionRepository repository;

  GetAsociacionesByMunicipalidad(this.repository);

  Future<List<AsociacionEntity>> call(int municipalidadId) async {
    return await repository.getAsociacionesByMunicipalidad(municipalidadId);
  }
}

