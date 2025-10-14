// Archivo: lib/presentation/blocs/service/servicio_bloc.dart

import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/create_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/delete_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/get_services_usecase.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/toggle_servicio_estado.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/update_servicio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'servicio_event.dart';
import 'servicio_state.dart';

class ServicioBloc extends Bloc<ServicioEvent, ServicioState> {
  final GetServicesUseCase getServicesUseCase;
  final CreateServicio createServicioUseCase;
  final UpdateServicio updateServicioUseCase;
  final DeleteServicio deleteServicioUseCase;
  final ServiceRepository repository;
  final TextEditingController _searchController = TextEditingController();
  final ToggleServicioEstado toggleServicioEstadoUseCase;

  ServicioBloc({
    required this.getServicesUseCase,
    required this.createServicioUseCase,
    required this.updateServicioUseCase,
    required this.deleteServicioUseCase,
    required this.repository,
    required this.toggleServicioEstadoUseCase}) :
        super(const ServicioState(servicios: [], serviciosFiltrados: [])) {
    on<LoadServicios>(_onLoadServicios);
    on<BuscarServicios>(_onBuscarServicios);
    on<FiltrarPorCategoria>(_onFiltrarPorCategoria);
    on<LimpiarFiltros>(_onLimpiarFiltros);
    on<FetchServicioById>(_onFetchServicioById);
    on<FetchServiciosByEmprendedor>(_onFetchServiciosByEmprendedor);
    on<FiltrarPorEmprendedor>(_onFiltrarPorEmprendedor);
    on<LimpiarFiltrosEmprendedor>(_onLimpiarFiltrosEmprendedor);
    on<CreateServicioEvent>(_onCreateServicio);
    on<UpdateServicioEvent>(_onUpdateServicio);
    on<DeleteServicioEvent>(_onDeleteServicio);
    on<ToggleEstadoServicio>(_onToggleEstadoServicio);

    add(LoadServicios());
  }

  void _onLoadServicios(LoadServicios event, Emitter<ServicioState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final data = await getServicesUseCase.execute();
      emit(state.copyWith(
        servicios: data,
        serviciosFiltrados: data,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        servicios: [],
        serviciosFiltrados: [],
      ));
    }
  }

  // Lógica para el evento BuscarServicios
  void _onBuscarServicios(BuscarServicios event, Emitter<ServicioState> emit) {
    /*emit(state.copyWith(searchQuery: event.query));
    _aplicarFiltros(emit);*/
    final newState = state.copyWith(
      searchQuery: event.query,
      categoriaSeleccionada: 0,
    );
    emit(newState.copyWith(serviciosFiltrados: _aplicarFiltros(newState)));
  }

  // Lógica para el evento FiltrarPorCategoria
  void _onFiltrarPorCategoria(FiltrarPorCategoria event, Emitter<ServicioState> emit) {
    /*emit(state.copyWith(
        categoriaSeleccionada: event.categoriaId,
        searchQuery: ''
    ));
    _aplicarFiltros(emit);*/
    final newState = state.copyWith(
      categoriaSeleccionada: event.categoriaId,
      //searchQuery: '',
    );
    emit(newState.copyWith(serviciosFiltrados: _aplicarFiltros(newState)));
  }



  // Lógica para el evento LimpiarFiltros
  void _onLimpiarFiltros(LimpiarFiltros event, Emitter<ServicioState> emit) {
    _searchController.text = '';
    emit(state.copyWith(
      searchQuery: '',
      categoriaSeleccionada: 0,
      emprendedorSeleccionadoId: 0,
      serviciosFiltrados: state.servicios,
    ));
  }

  void _onFiltrarPorEmprendedor(FiltrarPorEmprendedor event, Emitter<ServicioState> emit) {
    final newState = state.copyWith(
      emprendedorSeleccionadoId: event.emprendedorId,
      //searchQuery: '',
    );
    emit(newState.copyWith(serviciosFiltrados: _aplicarFiltros(newState)));
  }

  void _onLimpiarFiltrosEmprendedor(LimpiarFiltrosEmprendedor event, Emitter<ServicioState> emit) {
    final newState = state.copyWith(
      emprendedorSeleccionadoId: 0,
    );
    emit(newState.copyWith(serviciosFiltrados: _aplicarFiltros(newState)));
  }

  void _onFetchServicioById(FetchServicioById event, Emitter<ServicioState> emit) async {
      emit(state.copyWith(isLoading: true, error: ''));
      try {
        final servicio = await repository.getServicioById(event.id);
        if (servicio != null) {
          final nuevosServicios = List<ServiceEntity>.from(state.servicios);
          if (!nuevosServicios.any((s) => s.id == servicio.id)) {
            nuevosServicios.add(servicio);
          }
          /*emit(state.copyWith(servicios: nuevosServicios, isLoading: false));
          await _aplicarFiltros(emit);*/ // Re-aplicar filtros después de un cambio en la lista
          final newState = state.copyWith(servicios: nuevosServicios, isLoading: false);
          emit(newState.copyWith(serviciosFiltrados: _aplicarFiltros(newState)));
        } else {
          emit(state.copyWith(isLoading: false));
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }

  // Lógica para el evento FetchServiciosByEmprendedor
  void _onFetchServiciosByEmprendedor(FetchServiciosByEmprendedor event, Emitter<ServicioState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final data = await repository.getServiciosByEmprendedor(event.emprendedorId);
      emit(state.copyWith(
        servicios: data,
        serviciosFiltrados: data,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        servicios: [],
        serviciosFiltrados: [],
      ));
    }
  }

  // Método privado para aplicar los filtros
  List<ServiceEntity> _aplicarFiltros(ServicioState currentState) {
    List<ServiceEntity> resultados = currentState.servicios;

    if (currentState.searchQuery.isNotEmpty) {
      final query = currentState.searchQuery.toLowerCase();
      resultados = resultados.where((servicio) {
        return servicio.nombre.toLowerCase().contains(query) ||
            servicio.descripcion.toLowerCase().contains(query);
      }).toList();
    }

    if (currentState.categoriaSeleccionada > 0) {
      final id = currentState.categoriaSeleccionada;
      resultados = resultados.where((servicio) {
        return servicio.categorias.any((cat) => cat.id == id);
      }).toList();
    }

    if (currentState.emprendedorSeleccionadoId > 0) {
      final id = currentState.emprendedorSeleccionadoId;
      resultados = resultados.where((servicio) {
        return servicio.emprendedor.id == id;
      }).toList();
    }

    return resultados;
  }

  void _onToggleEstadoServicio(ToggleEstadoServicio event, Emitter<ServicioState> emit) async {
    emit(state.copyWith(status: ServicioStatus.updating));
    try {
      final result = await toggleServicioEstadoUseCase(event.servicio);
      result.fold(
              (failure) {
            emit(state.copyWith(
              status: ServicioStatus.failure,
              error: failure.toString(),
            ));
          },
              (updatedService) {
            final List<ServiceEntity> nuevosServicios = List.from(state.servicios);
            final index = nuevosServicios.indexWhere((s) => s.id == updatedService.id);
            if (index != -1) {
              nuevosServicios[index] = updatedService;
            }

            final newState = state.copyWith(
              servicios: nuevosServicios,
            );
            emit(newState.copyWith(serviciosFiltrados: _aplicarFiltros(newState)));
              },
      );
    } catch (e) {
      emit(state.copyWith(
        error: 'Error interno: ${e.toString()}',
      ));
    }
  }

  // ----------------------------------------------------
  // 💡 HANDLER: CREAR SERVICIO (CreateServicioEvent)
  // ----------------------------------------------------
  void _onCreateServicio(CreateServicioEvent event, Emitter<ServicioState> emit) async {
    emit(state.copyWith(status: ServicioStatus.loading));
    try {
      final result = await createServicioUseCase(event.servicio);

      result.fold(
            (failure) {
          emit(state.copyWith(
            status: ServicioStatus.failure,
            error: failure.toString(),
          ));
        },
            (newService) {
              final List<ServiceEntity> updatedList = List.from(state.servicios)..add(newService);

          emit(state.copyWith(
            status: ServicioStatus.success,
            servicios: updatedList,
            lastOperationService: newService, // CORRECCIÓN
            error: null,
          ));
          emit(state.copyWith(serviciosFiltrados: _aplicarFiltros(state.copyWith(servicios: updatedList))));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: ServicioStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // ----------------------------------------------------
  // 💡 HANDLER: ACTUALIZAR SERVICIO (UpdateServicioEvent)
  // ----------------------------------------------------
  void _onUpdateServicio(UpdateServicioEvent event, Emitter<ServicioState> emit) async {
    emit(state.copyWith(status: ServicioStatus.updating));
    try {
      final result = await updateServicioUseCase(event.servicio);
      result.fold(
            (failure) {
          emit(state.copyWith(
            status: ServicioStatus.failure,
            error: failure.toString(),
          ));
        },
            (updatedService) {
              final List<ServiceEntity> updatedList = List.from(state.servicios);
          final index = updatedList.indexWhere((s) => s.id == updatedService.id);

          if (index != -1) {
            updatedList[index] = updatedService;
          }

          emit(state.copyWith(
            status: ServicioStatus.success,
            servicios: updatedList,
            lastOperationService: updatedService,
            error: null,
          ));
          emit(state.copyWith(serviciosFiltrados: _aplicarFiltros(state.copyWith(servicios: updatedList))));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: ServicioStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteServicio(
      DeleteServicioEvent event, Emitter<ServicioState> emit) async {
    try {
      await deleteServicioUseCase(event.id);
      final updatedList = state.servicios.where((cat) => cat.id != event.id).toList();

      final newState = state.copyWith(
        servicios: updatedList,
        error: '',
        isLoading: false,
      );
      final updatedFiltradosList = _aplicarFiltros(newState);
      emit(newState.copyWith(
        serviciosFiltrados: updatedFiltradosList,
      ));

    } catch (e) {
      emit(state.copyWith(
        error: "Error al eliminar categoría: ${e.toString()}",
        isLoading: false,
      ));
    }
  }
}