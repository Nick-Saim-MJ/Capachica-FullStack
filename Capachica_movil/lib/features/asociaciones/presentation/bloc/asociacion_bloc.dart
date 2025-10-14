// asociacion_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aplicativo_capachica/features/asociaciones/data/models/laravel_paginated.dart';
import '../../domain/usecases/get_asociaciones.dart';
import '../../domain/usecases/get_asociacion_by_id.dart';
import '../../domain/usecases/get_emprendedores_by_asociacion.dart';
import '../../domain/usecases/get_asociaciones_by_municipalidad.dart';
import '../../domain/usecases/buscar_asociaciones_por_ubicacion.dart';
import '../../domain/usecases/create_asociacion.dart';
import '../../domain/usecases/update_asociacion.dart';
import '../../domain/usecases/delete_asociacion.dart';
import '../../domain/usecases/get_municipalidades.dart';
import '../../../../core/usecase/usecase.dart';
import 'asociacion_event.dart';
import 'asociacion_state.dart';

class AsociacionBloc extends Bloc<AsociacionEvent, AsociacionState> {
  final GetAsociaciones getAsociaciones;
  final GetAsociacionById getAsociacionById;
  final GetEmprendedoresByAsociacion getEmprendedoresByAsociacion;
  final GetAsociacionesByMunicipalidad getAsociacionesByMunicipalidad;
  final BuscarAsociacionesPorUbicacion buscarAsociacionesPorUbicacion;
  final CreateAsociacionUseCase createAsociacion;
  final UpdateAsociacionUseCase updateAsociacion;
  final DeleteAsociacionUseCase deleteAsociacion;
  final GetMunicipalidades getMunicipalidades;

  AsociacionBloc({
    required this.getAsociaciones,
    required this.getAsociacionById,
    required this.getEmprendedoresByAsociacion,
    required this.getAsociacionesByMunicipalidad,
    required this.buscarAsociacionesPorUbicacion,
    required this.createAsociacion,
    required this.updateAsociacion,
    required this.deleteAsociacion,
    required this.getMunicipalidades,
  }) : super(AsociacionInitial()) {
    on<LoadAsociaciones>(_onLoadAsociaciones);
    on<LoadMoreAsociaciones>(_onLoadMoreAsociaciones);
    on<RefreshAsociaciones>(_onRefreshAsociaciones);
    on<LoadAsociacionById>(_onLoadAsociacionById);
    on<LoadMunicipalidades>(_onLoadMunicipalidades);
    on<LoadEmprendedoresByAsociacion>((event, emit) async {
      emit(EmprendedoresLoading());
      try {
        final list = await getEmprendedoresByAsociacion(event.asociacionId);
        emit(EmprendedoresLoaded(emprendedores: list, asociacionId: event.asociacionId));
      } catch (e, st) {
        // Para que no quede colgado en Loading si algo falla en parsing/red
        addError(e, st);
        emit(EmprendedoresError(e.toString()));
      }
    });

    on<LoadAsociacionesByMunicipalidad>(_onLoadAsociacionesByMunicipalidad);
    on<SearchAsociacionesByLocation>(_onSearchAsociacionesByLocation);
    on<FilterAsociaciones>(_onFilterAsociaciones);
    on<ClearFilter>(_onClearFilter);
    on<ResetAsociacionState>(_onResetAsociacionState);
    
    // CRUD Events
    on<CreateAsociacion>(_onCreateAsociacion);
    on<UpdateAsociacion>(_onUpdateAsociacion);
    on<DeleteAsociacion>(_onDeleteAsociacion);
  }

  Future<void> _onLoadAsociaciones(LoadAsociaciones event, Emitter<AsociacionState> emit) async {
    emit(AsociacionesLoading());
    
    try {
      final result = await getAsociaciones(GetAsociacionesParams(
        page: event.page,
        perPage: event.perPage,
      ));
      
      emit(AsociacionesLoaded(
        asociaciones: result,
        hasReachedMax: result.nextPageUrl == null,
      ));
    } catch (e) {
      emit(AsociacionesError(e.toString()));
    }
  }

  Future<void> _onLoadMoreAsociaciones(LoadMoreAsociaciones event, Emitter<AsociacionState> emit) async {
    final currentState = state;
    
    if (currentState is AsociacionesLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.asociaciones.currentPage + 1;
        final result = await getAsociaciones(GetAsociacionesParams(
          page: nextPage,
          perPage: currentState.asociaciones.perPage,
        ));
        
        final updatedData = [
          ...currentState.asociaciones.data,
          ...result.data,
        ];
        
        final updatedAsociaciones = LaravelPaginated(
          currentPage: result.currentPage,
          data: updatedData,
          perPage: result.perPage,
          total: result.total,
          lastPage: result.lastPage,
          nextPageUrl: result.nextPageUrl,
          prevPageUrl: result.prevPageUrl,
        );

        emit(AsociacionesLoaded(
          asociaciones: updatedAsociaciones,
          hasReachedMax: result.nextPageUrl == null,
        ));
      } catch (e) {
        emit(AsociacionesError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshAsociaciones(RefreshAsociaciones event, Emitter<AsociacionState> emit) async {
    add(LoadAsociaciones(page: 1, perPage: 10));
  }

  Future<void> _onLoadAsociacionById(LoadAsociacionById event, Emitter<AsociacionState> emit) async {
    emit(AsociacionLoading());
    
    try {
      final result = await getAsociacionById(event.id);
      emit(AsociacionLoaded(result));
    } catch (e) {
      emit(AsociacionError(e.toString()));
    }
  }

  Future<void> _onLoadEmprendedoresByAsociacion(LoadEmprendedoresByAsociacion event, Emitter<AsociacionState> emit) async {
    emit(EmprendedoresLoading());
    
    try {
      final result = await getEmprendedoresByAsociacion(event.asociacionId);
      emit(EmprendedoresLoaded(
        emprendedores: result,
        asociacionId: event.asociacionId,
      ));
    } catch (e) {
      emit(EmprendedoresError(e.toString()));
    }
  }

  Future<void> _onLoadAsociacionesByMunicipalidad(LoadAsociacionesByMunicipalidad event, Emitter<AsociacionState> emit) async {
    emit(AsociacionesByMunicipalidadLoading());
    
    try {
      final result = await getAsociacionesByMunicipalidad(event.municipalidadId);
      emit(AsociacionesByMunicipalidadLoaded(
        asociaciones: result,
        municipalidadId: event.municipalidadId,
      ));
    } catch (e) {
      emit(AsociacionesByMunicipalidadError(e.toString()));
    }
  }

  Future<void> _onSearchAsociacionesByLocation(SearchAsociacionesByLocation event, Emitter<AsociacionState> emit) async {
    emit(AsociacionesByLocationLoading());
    
    try {
      final result = await buscarAsociacionesPorUbicacion(BuscarAsociacionesPorUbicacionParams(
        latitud: event.latitud,
        longitud: event.longitud,
        distancia: event.distancia,
      ));
      emit(AsociacionesByLocationLoaded(
        asociaciones: result,
        latitud: event.latitud,
        longitud: event.longitud,
        distancia: event.distancia,
      ));
    } catch (e) {
      emit(AsociacionesByLocationError(e.toString()));
    }
  }

  void _onFilterAsociaciones(FilterAsociaciones event, Emitter<AsociacionState> emit) {
    final currentState = state;
    
    if (currentState is AsociacionesLoaded) {
      final filteredAsociaciones = currentState.asociaciones.data
          .where((asociacion) => 
              asociacion.nombre.toLowerCase().contains(event.query.toLowerCase()) ||
              asociacion.descripcion.toLowerCase().contains(event.query.toLowerCase()) ||
              (asociacion.direccion?.toLowerCase().contains(event.query.toLowerCase()) ?? false))
          .toList();
      
      emit(AsociacionesFiltered(
        filteredAsociaciones: filteredAsociaciones,
        query: event.query,
      ));
    }
  }

  void _onClearFilter(ClearFilter event, Emitter<AsociacionState> emit) {
    final currentState = state;
    
    if (currentState is AsociacionesFiltered) {
      // Volver al estado anterior de AsociacionesLoaded
      add(RefreshAsociaciones());
    }
  }

  void _onResetAsociacionState(ResetAsociacionState event, Emitter<AsociacionState> emit) {
    emit(AsociacionInitial());
  }

  // Municipalidades Handler
  Future<void> _onLoadMunicipalidades(LoadMunicipalidades event, Emitter<AsociacionState> emit) async {
    emit(MunicipalidadesLoading());
    final result = await getMunicipalidades(NoParams());
    result.fold(
      (failure) => emit(MunicipalidadesError('No se pudieron cargar municipalidades')),
      (municipalidades) => emit(MunicipalidadesLoaded(municipalidades)),
    );
  }

  // CRUD Handlers
  Future<void> _onCreateAsociacion(CreateAsociacion event, Emitter<AsociacionState> emit) async {
    final currentState = state;
    
    emit(AsociacionCreating());
    final result = await createAsociacion(event.params);
    result.fold(
      (failure) => emit(AsociacionCrudError('No se pudo crear la asociación')),
      (asociacion) async {
        emit(AsociacionCreated(asociacion));
        
        // Si estamos en la lista cargada, agregar el nuevo item
        if (currentState is AsociacionesLoaded) {
          final updatedData = [asociacion, ...currentState.asociaciones.data];
          
          final updatedAsociaciones = LaravelPaginated(
            currentPage: currentState.asociaciones.currentPage,
            data: updatedData,
            perPage: currentState.asociaciones.perPage,
            total: currentState.asociaciones.total + 1,
            lastPage: currentState.asociaciones.lastPage,
            nextPageUrl: currentState.asociaciones.nextPageUrl,
            prevPageUrl: currentState.asociaciones.prevPageUrl,
          );
          
          await Future.delayed(const Duration(milliseconds: 100));
          emit(AsociacionesLoaded(
            asociaciones: updatedAsociaciones,
            hasReachedMax: currentState.hasReachedMax,
          ));
        } else {
          // Si no estamos en lista cargada, recargar desde el servidor
          add(LoadAsociaciones(page: 1, perPage: 10));
        }
      },
    );
  }

  Future<void> _onUpdateAsociacion(UpdateAsociacion event, Emitter<AsociacionState> emit) async {
    final currentState = state;
    
    emit(AsociacionUpdating());
    final result = await updateAsociacion(event.params);
    result.fold(
      (failure) => emit(AsociacionCrudError('No se pudo actualizar la asociación')),
      (asociacion) async {
        emit(AsociacionUpdated(asociacion));
        
        // Si estamos en la lista cargada, actualizar el item existente
        if (currentState is AsociacionesLoaded) {
          final updatedData = currentState.asociaciones.data.map((item) {
            return item.id == asociacion.id ? asociacion : item;
          }).toList();
          
          final updatedAsociaciones = LaravelPaginated(
            currentPage: currentState.asociaciones.currentPage,
            data: updatedData,
            perPage: currentState.asociaciones.perPage,
            total: currentState.asociaciones.total,
            lastPage: currentState.asociaciones.lastPage,
            nextPageUrl: currentState.asociaciones.nextPageUrl,
            prevPageUrl: currentState.asociaciones.prevPageUrl,
          );
          
          await Future.delayed(const Duration(milliseconds: 100));
          emit(AsociacionesLoaded(
            asociaciones: updatedAsociaciones,
            hasReachedMax: currentState.hasReachedMax,
          ));
        } else {
          // Si no estamos en lista cargada, recargar desde el servidor
          add(LoadAsociaciones(page: 1, perPage: 10));
        }
      },
    );
  }

  Future<void> _onDeleteAsociacion(DeleteAsociacion event, Emitter<AsociacionState> emit) async {
    final currentState = state;
    
    emit(AsociacionDeleting());
    final result = await deleteAsociacion(event.id);
    result.fold(
      (failure) => emit(AsociacionCrudError('No se pudo eliminar la asociación')),
      (_) async {
        emit(AsociacionDeleted(event.id));
        
        // Si estamos en la lista cargada, actualizar la lista sin hacer otra petición
        if (currentState is AsociacionesLoaded) {
          final updatedData = currentState.asociaciones.data
              .where((asociacion) => asociacion.id != event.id)
              .toList();
          
          final updatedAsociaciones = LaravelPaginated(
            currentPage: currentState.asociaciones.currentPage,
            data: updatedData,
            perPage: currentState.asociaciones.perPage,
            total: currentState.asociaciones.total - 1,
            lastPage: currentState.asociaciones.lastPage,
            nextPageUrl: currentState.asociaciones.nextPageUrl,
            prevPageUrl: currentState.asociaciones.prevPageUrl,
          );
          
          emit(AsociacionesLoaded(
            asociaciones: updatedAsociaciones,
            hasReachedMax: currentState.hasReachedMax,
          ));
        } else {
          // Si no estamos en lista cargada, recargar desde el servidor
          add(LoadAsociaciones(page: 1, perPage: 10));
        }
      },
    );
  }
}

