// Archivo: lib/presentation/blocs/service/servicio_event.dart

import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:equatable/equatable.dart';

abstract class ServicioEvent extends Equatable {
  const ServicioEvent();
  @override
  List<Object> get props => [];
}

/// Evento para cargar todos los servicios
class LoadServicios extends ServicioEvent {}

/// Evento para buscar servicios por una consulta
class BuscarServicios extends ServicioEvent {
  final String query;
  const BuscarServicios(this.query);
  @override
  List<Object> get props => [query];
}

/// Evento para filtrar servicios por categoría
class FiltrarPorCategoria extends ServicioEvent {
  final int categoriaId;
  const FiltrarPorCategoria(this.categoriaId);
  @override
  List<Object> get props => [categoriaId];
}

/// Evento para limpiar todos los filtros de búsqueda y categoría
class LimpiarFiltros extends ServicioEvent {}

/// Evento para obtener un servicio específico por su ID
class FetchServicioById extends ServicioEvent {
  final int id;
  const FetchServicioById(this.id);
  @override
  List<Object> get props => [id];
}

/// Evento para obtener servicios por ID de emprendedor
class FetchServiciosByEmprendedor extends ServicioEvent {
  final int emprendedorId;
  const FetchServiciosByEmprendedor(this.emprendedorId);
  @override
  List<Object> get props => [emprendedorId];
}

class FiltrarPorEmprendedor extends ServicioEvent {
  final int emprendedorId;
  FiltrarPorEmprendedor(this.emprendedorId);
}

class LimpiarFiltrosEmprendedor extends ServicioEvent {}

class ToggleEstadoServicio extends ServicioEvent {
  final ServiceEntity servicio;
  const ToggleEstadoServicio(this.servicio);

  @override
  List<Object> get props => [servicio];
}

class CreateServicioEvent extends ServicioEvent {
  final ServiceEntity servicio;
  const CreateServicioEvent(this.servicio);
  @override
  List<Object> get props => [servicio];
}

class UpdateServicioEvent extends ServicioEvent {
  final ServiceEntity servicio;
  const UpdateServicioEvent(this.servicio);
  @override
  List<Object> get props => [servicio];
}

class DeleteServicioEvent extends ServicioEvent {
  final int id;
  const DeleteServicioEvent(this.id);
  @override
  List<Object> get props => [id];
}