// buscar_asociaciones_por_ubicacion.dart
import '../entities/asociacion.dart';
import '../repositories/asociacion_repository.dart';

class BuscarAsociacionesPorUbicacion {
  final AsociacionRepository repository;

  BuscarAsociacionesPorUbicacion(this.repository);

  Future<List<AsociacionEntity>> call(BuscarAsociacionesPorUbicacionParams params) async {
    return await repository.buscarAsociacionesPorUbicacion(
      latitud: params.latitud,
      longitud: params.longitud,
      distancia: params.distancia,
    );
  }
}

class BuscarAsociacionesPorUbicacionParams {
  final double latitud;
  final double longitud;
  final double distancia;

  BuscarAsociacionesPorUbicacionParams({
    required this.latitud,
    required this.longitud,
    required this.distancia,
  });
}

