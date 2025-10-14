// lib/features/municipalidades/presentation/bloc/municipalidad_bloc.dart
import 'package:aplicativo_capachica/features/municipalidades/domain/usecases/get_public_municipalidades.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create-municipalidad.dart';
import '../../domain/usecases/delete-municipalidad.dart';

import '../../domain/usecases/search-municipalidades.dart';
import '../../domain/usecases/update-municipalidad.dart';
import 'municipalidad_event.dart';
import 'municipalidad_state.dart';

class MunicipalidadBloc extends Bloc<MunicipalidadEvent, MunicipalidadState> {
  final GetAllMunicipalidades getAllMunicipalidades;
  final GetMunicipalidadById getMunicipalidadById;
  final CreateMunicipalidad createMunicipalidad;
  final UpdateMunicipalidad updateMunicipalidad;
  final DeleteMunicipalidad deleteMunicipalidad;
  //final SearchMunicipalidades searchMunicipalidades;

  MunicipalidadBloc({
    required this.getAllMunicipalidades,
    required this.getMunicipalidadById,
    required this.createMunicipalidad,
    required this.updateMunicipalidad,
    required this.deleteMunicipalidad,
    //required this.searchMunicipalidades,
  }) : super(MunicipalidadInitial()) {
    on<LoadMunicipalidades>(_onLoadMunicipalidades);
    on<LoadMunicipalidadById>(_onLoadMunicipalidadById);
    on<CreateMunicipalidadEvent>(_onCreateMunicipalidad);
    on<UpdateMunicipalidadEvent>(_onUpdateMunicipalidad);
    on<DeleteMunicipalidadEvent>(_onDeleteMunicipalidad);
    //on<SearchMunicipalidadesEvent>(_onSearchMunicipalidades);
  }

  Future<void> _onLoadMunicipalidades(
      LoadMunicipalidades event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    try {
      final list = await getAllMunicipalidades();
      emit(MunicipalidadLoaded(list));
    } catch (e) {
      emit(MunicipalidadError('Error al cargar municipalidades: $e'));
    }
  }

  Future<void> _onLoadMunicipalidadById(
      LoadMunicipalidadById event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    try {
      final municipalidad = await getMunicipalidadById(event.id);
      if (municipalidad != null) {
        emit(MunicipalidadLoadedSingle(municipalidad));
      } else {
        emit(const MunicipalidadError('Municipalidad no encontrada'));
      }
    } catch (e) {
      emit(MunicipalidadError('Error al obtener municipalidad: $e'));
    }
  }

  Future<void> _onCreateMunicipalidad(
      CreateMunicipalidadEvent event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    final success = await createMunicipalidad(event.municipalidad);
    success
        ? emit(const MunicipalidadSuccess('Municipalidad creada correctamente'))
        : emit(const MunicipalidadError('Error al crear municipalidad'));
  }

  Future<void> _onUpdateMunicipalidad(
      UpdateMunicipalidadEvent event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    final success = await updateMunicipalidad(event.municipalidad);
    success
        ? emit(const MunicipalidadSuccess('Municipalidad actualizada correctamente'))
        : emit(const MunicipalidadError('Error al actualizar municipalidad'));
  }

  Future<void> _onDeleteMunicipalidad(
      DeleteMunicipalidadEvent event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    final success = await deleteMunicipalidad(event.id);
    success
        ? emit(const MunicipalidadSuccess('Municipalidad eliminada correctamente'))
        : emit(const MunicipalidadError('Error al eliminar municipalidad'));
  }
/*
  Future<void> _onSearchMunicipalidades(
      SearchMunicipalidadesEvent event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    try {
      final result = await searchMunicipalidades(event.query);
      emit(MunicipalidadLoaded(result));
    } catch (e) {
      emit(MunicipalidadError('Error en la búsqueda: $e'));
    }
  }*/
}
