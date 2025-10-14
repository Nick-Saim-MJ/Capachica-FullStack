// lib/features/municipalidades/domain/usecases/create_municipalidad.dart
import '../repositories/municipalidad_repository.dart';
import '../entities/municipalidad.dart';

class CreateMunicipalidad {
  final MunicipalidadRepository repository;

  CreateMunicipalidad({required this.repository});

  Future<bool> call(MunicipalidadEntity municipalidad) async {
    return await repository.createMunicipalidad(municipalidad);
  }
}
