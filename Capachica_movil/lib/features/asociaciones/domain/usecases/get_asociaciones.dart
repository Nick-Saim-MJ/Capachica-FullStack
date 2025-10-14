// lib/features/asociaciones/domain/usecases/get_asociaciones.dart
import 'package:aplicativo_capachica/features/asociaciones/domain/entities/asociacion.dart';
import 'package:aplicativo_capachica/features/asociaciones/domain/repositories/asociacion_repository.dart';
// usamos el mismo tipo de paginación del data layer
import 'package:aplicativo_capachica/features/asociaciones/data/models/laravel_paginated.dart';

class GetAsociaciones {
  final AsociacionRepository repository;
  GetAsociaciones(this.repository);

  Future<LaravelPaginated<AsociacionEntity>> call(GetAsociacionesParams params) {
    // no hace falta await/async aquí
    return repository.getAsociaciones(
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetAsociacionesParams {
  final int page;
  final int perPage;
  const GetAsociacionesParams({required this.page, required this.perPage});
}
