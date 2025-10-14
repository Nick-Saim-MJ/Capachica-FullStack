// get_asociacion_by_id.dart
import '../entities/asociacion.dart';
import '../repositories/asociacion_repository.dart';

class GetAsociacionById {
  final AsociacionRepository repository;

  GetAsociacionById(this.repository);

  Future<AsociacionEntity> call(int id) async {
    return await repository.getAsociacionById(id);
  }
}

