// lib/features/municipalidades/domain/usecases/get_municipalidad_by_id.dart
import '../repositories/municipalidad_repository.dart';
import '../entities/municipalidad.dart';

class GetMunicipalidadById {
  final MunicipalidadRepository repository;

  GetMunicipalidadById({required this.repository});

  Future<MunicipalidadEntity?> call(int id) async {
    return await repository.getMunicipalidadById(id);
  }
}
