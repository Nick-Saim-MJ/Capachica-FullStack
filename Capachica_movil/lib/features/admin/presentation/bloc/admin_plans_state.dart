// Ruta: lib/features/admin/presentation/bloc/admin_plans_state.dart

// 1. Asegúrate de que estas importaciones están presentes.
import 'package:equatable/equatable.dart';
import '../../data/models/admin_plan_model.dart'; // Ajusta la ruta a tu modelo si es necesario

// (Aquí ya NO hay ninguna línea 'part of ...')

// Clase base abstracta
abstract class AdminPlansState extends Equatable {
  const AdminPlansState();

  @override
  List<Object> get props => [];
}

// Estado inicial
class AdminPlansInitial extends AdminPlansState {}

// Estado para cuando se carga la lista de planes
class AdminPlansLoading extends AdminPlansState {}

// Estado para cuando una operación (Crear/Editar/Borrar) está en proceso
class AdminPlanOperationInProgress extends AdminPlansState {}

// Estado para cuando los planes se han cargado exitosamente
class AdminPlansLoaded extends AdminPlansState {
  final List<AdminPlanModel> plans;

  const AdminPlansLoaded(this.plans);

  @override
  List<Object> get props => [plans];
}

// Estado para cuando una operación (Crear/Editar/Borrar) fue exitosa
class AdminPlanOperationSuccess extends AdminPlansState {
  final String message;

  const AdminPlanOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Estado para manejar cualquier error
class AdminPlansError extends AdminPlansState {
  final String message;

  const AdminPlansError(this.message);

  @override
  List<Object> get props => [message];
}