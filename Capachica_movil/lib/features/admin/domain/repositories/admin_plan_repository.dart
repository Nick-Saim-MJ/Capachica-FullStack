import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/admin_plan_model.dart';

// El repositorio actúa como un contrato entre los casos de uso y la fuente de datos.
// Define QUÉ se puede hacer, pero no CÓMO.
// Usamos Either<Failure, Success> para manejar errores de forma explícita.
abstract class AdminPlanRepository {
  // Obtener todos los planes
  Future<Either<Failure, List<AdminPlanModel>>> getPlans();

  // Crear un nuevo plan
  Future<Either<Failure, AdminPlanModel>> createPlan(AdminPlanModel plan, File? imageFile);
  Future<Either<Failure, AdminPlanModel>> updatePlan(AdminPlanModel plan, File? imageFile);

  // Eliminar un plan por su ID
  Future<Either<Failure, void>> deletePlan(int id);
}
