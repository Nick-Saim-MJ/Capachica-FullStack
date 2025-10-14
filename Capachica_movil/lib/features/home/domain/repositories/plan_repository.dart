// lib/features/plans/domain/repositories/plan_repository.dart

import 'package:aplicativo_capachica/features/plans/domain/entities/plan.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/plan.dart';

/// El Either<Failure, Success> es para un manejo de errores robusto.
abstract class PlanRepository {
  /// Corresponde a GET /api/planes/publicos
  Future<Either<Failure, List<PlanEntity>>> getPublicPlans({Map<String, String> filters});

  /// Corresponde a GET /api/public/planes/{id}
  Future<Either<Failure, PlanEntity>> getPlanById(int id);

  /// Corresponde a POST /api/planes (ruta protegida)
  Future<Either<Failure, PlanEntity>> createPlan(Map<String, dynamic> planData);

  /// Corresponde a PUT /api/planes/{id} (ruta protegida)
  Future<Either<Failure, PlanEntity>> updatePlan(int id, Map<String, dynamic> planData);

  /// Corresponde a DELETE /api/planes/{id} (ruta protegida)
  Future<Either<Failure, void>> deletePlan(int id);
}
