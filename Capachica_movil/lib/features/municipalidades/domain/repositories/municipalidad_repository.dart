// lib/features/municipalidades/domain/repositories/municipalidad_repository.dart
import '../entities/municipalidad.dart';

abstract class MunicipalidadRepository {
  Future<List<MunicipalidadEntity>> getAllMunicipalidades();
  Future<MunicipalidadEntity?> getMunicipalidadById(int id);
  Future<bool> createMunicipalidad(MunicipalidadEntity municipalidad);
  Future<bool> updateMunicipalidad(MunicipalidadEntity municipalidad);
  Future<bool> deleteMunicipalidad(int id);
}
