// lib/features/plans/presentation/bloc/plan_state.dart

import 'package:aplicativo_capachica/features/plans/domain/entities/plan.dart';

abstract class PlanState {}

class PlanInitial extends PlanState {}

class PlanLoading extends PlanState {}

class PlanLoaded extends PlanState {
  final List<PlanEntity> plans;
  PlanLoaded({required this.plans});
}

class PlanError extends PlanState {
  final String message;
  PlanError({required this.message});
}
