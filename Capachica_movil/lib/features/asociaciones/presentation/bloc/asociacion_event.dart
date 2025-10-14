// asociacion_event.dart
import '../../domain/entities/asociacion.dart';
import '../../domain/entities/emprendedor.dart';
import '../../domain/usecases/create_asociacion.dart';
import '../../domain/usecases/update_asociacion.dart';

abstract class AsociacionEvent {}

// Eventos para lista de asociaciones
class LoadAsociaciones extends AsociacionEvent {
  final int page;
  final int perPage;

  LoadAsociaciones({this.page = 1, this.perPage = 10});
}

class LoadMoreAsociaciones extends AsociacionEvent {}

class RefreshAsociaciones extends AsociacionEvent {}

// Eventos para asociación específica
class LoadAsociacionById extends AsociacionEvent {
  final int id;

  LoadAsociacionById(this.id);
}

// Eventos para emprendedores
class LoadEmprendedoresByAsociacion extends AsociacionEvent {
  final int asociacionId;

  LoadEmprendedoresByAsociacion(this.asociacionId);
}

// Eventos para asociaciones por municipalidad
class LoadAsociacionesByMunicipalidad extends AsociacionEvent {
  final int municipalidadId;

  LoadAsociacionesByMunicipalidad(this.municipalidadId);
}

// Eventos para búsqueda por ubicación
class SearchAsociacionesByLocation extends AsociacionEvent {
  final double latitud;
  final double longitud;
  final double distancia;

  SearchAsociacionesByLocation({
    required this.latitud,
    required this.longitud,
    required this.distancia,
  });
}

// Eventos de filtro
class FilterAsociaciones extends AsociacionEvent {
  final String query;

  FilterAsociaciones(this.query);
}

class ClearFilter extends AsociacionEvent {}

// Eventos de reset
class ResetAsociacionState extends AsociacionEvent {}

// Eventos CRUD
class CreateAsociacion extends AsociacionEvent {
  final CreateAsociacionParams params;

  CreateAsociacion(this.params);
}

class UpdateAsociacion extends AsociacionEvent {
  final UpdateAsociacionParams params;

  UpdateAsociacion(this.params);
}

class DeleteAsociacion extends AsociacionEvent {
  final int id;

  DeleteAsociacion(this.id);
}

// Evento para cargar municipalidades
class LoadMunicipalidades extends AsociacionEvent {}

