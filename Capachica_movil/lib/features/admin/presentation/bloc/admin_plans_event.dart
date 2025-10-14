import 'dart:io'; // <-- AÑADIDO: Necesario para usar el tipo 'File'
import 'package:equatable/equatable.dart';

import '../../data/models/admin_plan_model.dart';

abstract class AdminPlansEvent extends Equatable {
  const AdminPlansEvent();

  @override
  // Se cambia a List<Object?> para permitir propiedades nulas como imageFile
  List<Object?> get props => [];
}

// Evento para solicitar la carga de todos los planes (SIN CAMBIOS)
class LoadAdminPlans extends AdminPlansEvent {}

// ==================================================
// >>>>>>>> CLASE AddPlan ACTUALIZADA <<<<<<<<<<<
// ==================================================
class AddPlan extends AdminPlansEvent {
  final AdminPlanModel plan;
  final File? imageFile; // <-- 1. Se añade la propiedad para el archivo

  // 2. Se añade al constructor
  const AddPlan(this.plan, this.imageFile);

  @override
  // 3. Se añade a props para la comparación de Equatable
  List<Object?> get props => [plan, imageFile];
}

// ==================================================
// >>>>>>>> CLASE UpdatePlan ACTUALIZADA <<<<<<<<<<<
// ==================================================
class UpdatePlan extends AdminPlansEvent {
  final AdminPlanModel plan;
  final File? imageFile; // <-- 4. Se añade la propiedad para el archivo

  // 5. Se añade al constructor
  const UpdatePlan(this.plan, this.imageFile);

  @override
  // 6. Se añade a props para la comparación de Equatable
  List<Object?> get props => [plan, imageFile];
}

// Evento para eliminar un plan (SIN CAMBIOS)
class DeletePlan extends AdminPlansEvent {
  final int id;

  const DeletePlan(this.id);

  @override
  List<Object> get props => [id];
}