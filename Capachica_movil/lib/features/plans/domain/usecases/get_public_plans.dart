// features/plans/domain/usecases/get_public_plans.dart

import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/plan.dart';
import '../repositories/plan_repository.dart';

class GetPublicPlans implements UseCase<List<PlanEntity>, GetPublicPlansParams> {
  final PlanRepository repository;

  GetPublicPlans(this.repository);

  @override
  Future<Either<Failure, List<PlanEntity>>> call(GetPublicPlansParams params) async {
    return await repository.getPublicPlans(filters: params.filters);
  }
}

// Clase para pasar parámetros al caso de uso de forma segura y estructurada
class GetPublicPlansParams extends Equatable {
  final Map<String, String> filters;

  const GetPublicPlansParams({this.filters = const {}});

  @override
  List<Object> get props => [filters];
}
