// lib/features/asociaciones/domain/repositories/asociacion_repository.dart
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/asociacion.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/municipalidad.dart';
import 'package:aplicativo_capachica/features/asociaciones/data/models/laravel_paginated.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/usecases/create_asociacion.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/usecases/update_asociacion.dart';

abstract class AsociacionRepository {
  Future<LaravelPaginated<AsociacionEntity>> getAsociaciones({
    int page,
    int perPage,
  });

  Future<AsociacionEntity> getAsociacionById(int id);

  Future<List<EmprendedorEntity>> getEmprendedoresByAsociacion(int asociacionId);

  Future<List<AsociacionEntity>> getAsociacionesByMunicipalidad(int municipalidadId);

  Future<List<AsociacionEntity>> buscarAsociacionesPorUbicacion({
    required double latitud,
    required double longitud,
    required double distancia,
  });

  // Municipalidades
  Future<List<MunicipalidadEntity>> getMunicipalidades();

  // CRUD Operations
  Future<AsociacionEntity> createAsociacion(CreateAsociacionParams params);
  Future<AsociacionEntity> updateAsociacion(UpdateAsociacionParams params);
  Future<void> deleteAsociacion(int id);
}
