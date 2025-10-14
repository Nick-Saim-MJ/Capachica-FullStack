// lib/features/municipalidades/domain/usecases/delete_municipalidad.dart
import '../repositories/municipalidad_repository.dart';

class DeleteMunicipalidad {
  final MunicipalidadRepository repository;

  DeleteMunicipalidad({required this.repository});

  Future<bool> call(int id) async {
    return await repository.deleteMunicipalidad(id);
  }
}
