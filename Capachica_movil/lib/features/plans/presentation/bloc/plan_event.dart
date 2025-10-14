// lib/features/plans/presentation/bloc/plan_event.dart

abstract class PlanEvent {}

class FetchPublicPlans extends PlanEvent {
  final Map<String, String> filters;
  FetchPublicPlans({this.filters = const {}});
}