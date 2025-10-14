// municipalidad_bloc.dart
// presentation/bloc/municipalidad_bloc.dart
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/create-emprendedor.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/delete-emprendedor.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/search-emprendedores.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/usecases/update-emprendedor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_public_emprendedores.dart';
import 'emprendedor_event.dart';
import 'emprendedor_state.dart';

class EmprendedorBloc extends Bloc<EmprendedorEvent, EmprendedorState> {
  final GetPublicEmprendedores getPublicEmprendedores;
  final CreateEmprendedor createEmprendedor;
  final UpdateEmprendedor updateEmprendedor;
  final DeleteEmprendedor deleteEmprendedor;
  final SearchEmprendedores searchEmprendedores;

  EmprendedorBloc({
    required this.getPublicEmprendedores,
    required this.createEmprendedor,
    required this.updateEmprendedor,
    required this.deleteEmprendedor,
    required this.searchEmprendedores,
  }) : super(EmprendedorInitial()) {
    on<LoadEmprendedores>(_onLoadEmprendedores);
    on<CreateEmprendedorEvent>(_onCreateEmprendedor);
    on<UpdateEmprendedorEvent>(_onUpdateEmprendedor);
    on<DeleteEmprendedorEvent>(_onDeleteEmprendedor);
    on<SearchEmprendedoresEvent>(_onSearchEmprendedores);
  }

  Future<void> _onLoadEmprendedores(
      LoadEmprendedores event, Emitter<EmprendedorState> emit) async {
    emit(EmprendedorLoading());
    try {
      final emprendedores = await getPublicEmprendedores();
      emit(EmprendedorLoaded(emprendedores));
    } catch (e) {
      emit(EmprendedorError('Error al cargar emprendedores: $e'));
    }
  }

  Future<void> _onCreateEmprendedor(
      CreateEmprendedorEvent event, Emitter<EmprendedorState> emit) async {
    emit(EmprendedorLoading());
    final success = await createEmprendedor(event.emprendedor);
    success
        ? emit(const EmprendedorSuccess('Creado correctamente'))
        : emit(const EmprendedorError('Error al crear emprendedor'));
  }

  Future<void> _onUpdateEmprendedor(
      UpdateEmprendedorEvent event, Emitter<EmprendedorState> emit) async {
    emit(EmprendedorLoading());
    final success = await updateEmprendedor(event.emprendedor);
    success
        ? emit(const EmprendedorSuccess('Actualizado correctamente'))
        : emit(const EmprendedorError('Error al actualizar emprendedor'));
  }

  Future<void> _onDeleteEmprendedor(
      DeleteEmprendedorEvent event, Emitter<EmprendedorState> emit) async {
    emit(EmprendedorLoading());
    final success = await deleteEmprendedor(event.id);
    success
        ? emit(const EmprendedorSuccess('Eliminado correctamente'))
        : emit(const EmprendedorError('Error al eliminar emprendedor'));
  }

  Future<void> _onSearchEmprendedores(
      SearchEmprendedoresEvent event, Emitter<EmprendedorState> emit) async {
    emit(EmprendedorLoading());
    try {
      final result = await searchEmprendedores(event.query);
      emit(EmprendedorLoaded(result));
    } catch (e) {
      emit(EmprendedorError('Error en la búsqueda: $e'));
    }
  }
}

