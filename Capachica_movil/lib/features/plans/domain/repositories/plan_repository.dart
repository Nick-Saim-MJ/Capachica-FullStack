// features/plans/domain/repositories/plan_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/plan.dart';

abstract class PlanRepository {
  Future<Either<Failure, List<PlanEntity>>> getPublicPlans({Map<String, String> filters});
  // Aquí puedes añadir otros métodos que necesites para tu repositorio de planes
  // Ejemplo: Future<Either<Failure, PlanEntity>> getPlanById(String id);
  // Ejemplo: Future<Either<Failure, void>> createPlan(PlanEntity plan);
}
