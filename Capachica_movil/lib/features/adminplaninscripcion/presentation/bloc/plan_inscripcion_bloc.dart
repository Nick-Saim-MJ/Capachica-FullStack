import 'package:flutter_bloc/flutter_bloc.dart';
import 'plan_inscripcion_event.dart';
import 'plan_inscripcion_state.dart';
import '../../domain/usecases/plan_inscripcion_usecases.dart';

class PlanInscripcionBloc extends Bloc<PlanInscripcionEvent, PlanInscripcionState> {
  final GetInscripcionesUseCase getInscripcionesUseCase;
  final UpdateEstadoInscripcionUseCase updateEstadoUseCase;

  PlanInscripcionBloc({
    required this.getInscripcionesUseCase,
    required this.updateEstadoUseCase,
  }) : super(PlanInscripcionInitial()) {
    on<LoadInscripciones>(_onLoadInscripciones);
    on<UpdateEstado>(_onUpdateEstado);
  }

  Future<void> _onLoadInscripciones(LoadInscripciones event, Emitter<PlanInscripcionState> emit) async {
    emit(PlanInscripcionLoading());
    final failureOrInscripciones = await getInscripcionesUseCase();
    failureOrInscripciones.fold(
          (failure) => emit(PlanInscripcionError(failure.message)),
          (inscripciones) => emit(PlanInscripcionLoaded(inscripciones)),
    );
  }

  Future<void> _onUpdateEstado(UpdateEstado event, Emitter<PlanInscripcionState> emit) async {
    emit(PlanInscripcionOperationInProgress());
    final failureOrSuccess = await updateEstadoUseCase(event.id, event.nuevoEstado);
    failureOrSuccess.fold(
          (failure) => emit(PlanInscripcionError(failure.message)),
          (_) => emit(PlanInscripcionOperationSuccess()),
    );
  }
}