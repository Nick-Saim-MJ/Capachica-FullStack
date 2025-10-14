import 'dart:async';

import '../../domain/entities/asociacion.dart';
import '../../domain/entities/emprendedor.dart';
import '../../domain/entities/municipalidad.dart';
import '../../domain/repositories/asociacion_repository.dart';
import '../../domain/usecases/create_asociacion.dart';
import '../../domain/usecases/update_asociacion.dart';

import '../datasources/asociacion_local_data_source.dart';
import '../datasources/asociacion_remote_data_source.dart';
import '../models/asociacion_model.dart';
import '../models/emprendedor_model.dart';
import 'package:aplicativo_capachica/features/asociaciones/data/models/laravel_paginated.dart';


import '../../../../core/network/network_info.dart';

// ===== Helpers =====
DateTime? _tryParseDate(String? iso) {
  if (iso == null) return null;
  try {
    return DateTime.parse(iso);
  } catch (_) {
    return null;
  }
}

// ===== Mapeos Model -> Entity =====
extension _AsociacionModelX on AsociacionModel {
  AsociacionEntity toEntity() => AsociacionEntity(
    id: id,
    nombre: nombre,
    descripcion: descripcion ?? '',
    // La API no trae "direccion" explícita: vacío para cumplir el required.
    direccion: '',
    telefono: telefono,
    email: email,
    // La entidad tiene logo/imagen (strings). Usamos la URL completa si existe.
    logo: null,
    imagen: imagenUrl ?? imagen,
    latitud: latitud,
    longitud: longitud,
    municipalidadId: municipalidadId,
    municipalidadNombre: municipalidad?.nombre,
    fechaCreacion: _tryParseDate(createdAt),
    fechaActualizacion: _tryParseDate(updatedAt),
  );
}

extension _EmprendedorModelX on EmprendedorModel {
  EmprendedorEntity toEntity() => EmprendedorEntity(
    id: id,
    nombre: nombre,
    // No viene "apellidos" en API → vacío para cumplir required
    apellidos: '',
    telefono: telefono,
    email: email,

    // Tomamos la primera imagen (si hay) como "foto"
    foto: imagenes.isNotEmpty ? imagenes.first : null,  // 👈
    descripcion: descripcion,
    // API trae asociacionId opcional; en entidad es requerido → fallback 0
    asociacionId: asociacionId ?? 0,
    asociacionNombre: null,
    fechaRegistro: _tryParseDate(createdAt),
  );
}

class AsociacionRepositoryImpl implements AsociacionRepository {
  final AsociacionRemoteDataSource remoteDataSource;
  final AsociacionLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AsociacionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<LaravelPaginated<AsociacionEntity>> getAsociaciones({
    int page = 1,
    int perPage = 10,
  }) async {
    if (await networkInfo.isConnected) {
      // Remote devuelve MODELOS
      final LaravelPaginated<AsociacionModel> remote =
      await remoteDataSource.getAsociaciones(page: page, perPage: perPage);

      // Mapear a ENTIDADES
      final mapped = remote.data.map((m) => m.toEntity()).toList();

      // Construir el contenedor de paginación con ENTIDADES
      final result = LaravelPaginated<AsociacionEntity>(
        currentPage: remote.currentPage,
        data: mapped,
        perPage: remote.perPage,
        total: remote.total,
        lastPage: remote.lastPage,
        nextPageUrl: remote.nextPageUrl,
        prevPageUrl: remote.prevPageUrl,
      );

      // (Opcional) adapta localDataSource a ENTIDADES y habilita cache
      // await localDataSource.cacheAsociaciones(result);
      return result;
    } else {
      // ❗️Temporal: sin cache hasta alinear tipos en localDataSource.
      throw Exception('No internet connection');
    }
  }

  @override
  Future<AsociacionEntity> getAsociacionById(int id) async {
    if (await networkInfo.isConnected) {
      final m = await remoteDataSource.getAsociacionById(id);
      final entity = m.toEntity();
      // await localDataSource.cacheAsociacion(entity);
      return entity;
    } else {
      // ❗️Temporal sin cache
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<EmprendedorEntity>> getEmprendedoresByAsociacion(int asociacionId) async {
    if (await networkInfo.isConnected) {
      final list = await remoteDataSource.getEmprendedoresByAsociacion(asociacionId);
      final entities = list.map((e) => e.toEntity()).toList();
      // await localDataSource.cacheEmprendedoresByAsociacion(asociacionId, entities);
      return entities;
    } else {
      // ❗️Temporal sin cache
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<AsociacionEntity>> getAsociacionesByMunicipalidad(int municipalidadId) async {
    if (await networkInfo.isConnected) {
      final list = await remoteDataSource.getAsociacionesByMunicipalidad(municipalidadId);
      final entities = list.map((m) => m.toEntity()).toList();
      // await localDataSource.cacheAsociacionesByMunicipalidad(municipalidadId, entities);
      return entities;
    } else {
      // ❗️Temporal sin cache
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<AsociacionEntity>> buscarAsociacionesPorUbicacion({
    required double latitud,
    required double longitud,
    required double distancia,
  }) async {
    if (await networkInfo.isConnected) {
      // El data source recibe distanciaKm (int)
      final list = await remoteDataSource.buscarAsociacionesPorUbicacion(
        latitud: latitud,
        longitud: longitud,
        distanciaKm: distancia.round(),
      );
      final entities = list.map((m) => m.toEntity()).toList();
      // await localDataSource.cacheAsociacionesByUbicacion('${latitud}_${longitud}_$distancia', entities);
      return entities;
    } else {
      // ❗️Temporal sin cache
      throw Exception('No internet connection');
    }
  }

  // CRUD Operations
  @override
  Future<AsociacionEntity> createAsociacion(CreateAsociacionParams params) async {
    if (await networkInfo.isConnected) {
      final model = await remoteDataSource.createAsociacion(params);
      return model.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<AsociacionEntity> updateAsociacion(UpdateAsociacionParams params) async {
    if (await networkInfo.isConnected) {
      final model = await remoteDataSource.updateAsociacion(params);
      return model.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<void> deleteAsociacion(int id) async {
    if (await networkInfo.isConnected) {
      await remoteDataSource.deleteAsociacion(id);
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<MunicipalidadEntity>> getMunicipalidades() async {
    if (await networkInfo.isConnected) {
      final models = await remoteDataSource.getMunicipalidades();
      return models.map((m) => m.toEntity()).toList();
    } else {
      throw Exception('No internet connection');
    }
  }
}
