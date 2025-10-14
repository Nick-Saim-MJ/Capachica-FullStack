import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/admin_plan_usecases.dart';
import '../../../../core/usecases/usecase.dart';
import 'admin_plans_event.dart';
import 'admin_plans_state.dart';

class AdminPlansBloc extends Bloc<AdminPlansEvent, AdminPlansState> {
  final GetPlansUseCase getPlansUseCase;
  final CreatePlanUseCase createPlanUseCase;
  final UpdatePlanUseCase updatePlanUseCase;
  final DeletePlanUseCase deletePlanUseCase;

  AdminPlansBloc({
    required this.getPlansUseCase,
    required this.createPlanUseCase,
    required this.updatePlanUseCase,
    required this.deletePlanUseCase,
  }) : super(AdminPlansInitial()) {
    on<LoadAdminPlans>(_onLoadAdminPlans);
    on<AddPlan>(_onAddPlan);
    on<UpdatePlan>(_onUpdatePlan);
    on<DeletePlan>(_onDeletePlan);
  }

  Future<void> _onLoadAdminPlans(LoadAdminPlans event, Emitter<AdminPlansState> emit) async {
    // ... (sin cambios)
    emit(AdminPlansLoading());
    final failureOrPlans = await getPlansUseCase(NoParams());
    failureOrPlans.fold(
          (failure) => emit(AdminPlansError(failure.message)),
          (plans) => emit(AdminPlansLoaded(plans)),
    );
  }

  Future<void> _onAddPlan(AddPlan event, Emitter<AdminPlansState> emit) async {
    emit(AdminPlanOperationInProgress());
    // >>> 1. SE PASA EL ARCHIVO DE IMAGEN DESDE EL EVENTO <<<
    final failureOrPlan = await createPlanUseCase(event.plan, event.imageFile);
    failureOrPlan.fold(
          (failure) => emit(AdminPlansError(failure.message)),
          (plan) => emit(const AdminPlanOperationSuccess('Plan creado con éxito')),
    );
  }

  Future<void> _onUpdatePlan(UpdatePlan event, Emitter<AdminPlansState> emit) async {
    emit(AdminPlanOperationInProgress());
    // >>> 2. SE PASA EL ARCHIVO DE IMAGEN DESDE EL EVENTO <<<
    final failureOrPlan = await updatePlanUseCase(event.plan, event.imageFile);
    failureOrPlan.fold(
          (failure) => emit(AdminPlansError(failure.message)),
          (plan) => emit(const AdminPlanOperationSuccess('Plan actualizado con éxito')),
    );
  }

  Future<void> _onDeletePlan(DeletePlan event, Emitter<AdminPlansState> emit) async {
    // ... (sin cambios)
    emit(AdminPlanOperationInProgress());
    final failureOrVoid = await deletePlanUseCase(event.id);
    failureOrVoid.fold(
          (failure) => emit(AdminPlansError(failure.message)),
          (_) => emit(const AdminPlanOperationSuccess('Plan eliminado con éxito')),
    );
  }
}