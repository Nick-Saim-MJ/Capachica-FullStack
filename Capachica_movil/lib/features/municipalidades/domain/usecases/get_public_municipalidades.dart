// lib/features/municipalidades/domain/usecases/get_all_municipalidades.dart
import '../repositories/municipalidad_repository.dart';
import '../entities/municipalidad.dart';

class GetAllMunicipalidades {
  final MunicipalidadRepository repository;

  GetAllMunicipalidades({required this.repository});

  Future<List<MunicipalidadEntity>> call() async {
    return await repository.getAllMunicipalidades();
  }
}
