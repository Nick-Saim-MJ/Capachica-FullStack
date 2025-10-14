// lib/features/municipalidades/domain/usecases/update_municipalidad.dart
import '../repositories/municipalidad_repository.dart';
import '../entities/municipalidad.dart';

class UpdateMunicipalidad {
  final MunicipalidadRepository repository;

  UpdateMunicipalidad({required this.repository});

  Future<bool> call(MunicipalidadEntity municipalidad) async {
    return await repository.updateMunicipalidad(municipalidad);
  }
}
