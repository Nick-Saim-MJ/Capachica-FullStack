// lib/features/plans/presentation/bloc/plan_bloc.dart

import 'package:bloc/bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/plan.dart';
import '../../domain/usecases/get_public_plans.dart';
import 'plan_event.dart';
import 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final GetPublicPlans getPublicPlans;

  PlanBloc({required this.getPublicPlans}) : super(PlanInitial()) {
    on<FetchPublicPlans>(_onFetchPublicPlans);
  }

  Future<void> _onFetchPublicPlans(FetchPublicPlans event, Emitter<PlanState> emit) async {
    emit(PlanLoading());
    final failureOrPlans = await getPublicPlans(GetPublicPlansParams(filters: event.filters));

    failureOrPlans.fold(
          (failure) => emit(PlanError(message: _mapFailureToMessage(failure))),
          (plans) => emit(PlanLoaded(plans: plans)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor. Inténtalo de nuevo.';
    } else if (failure is NetworkFailure) {
      return 'Sin conexión a internet.';
    } else {
      return 'Error inesperado.';
    }
  }
}