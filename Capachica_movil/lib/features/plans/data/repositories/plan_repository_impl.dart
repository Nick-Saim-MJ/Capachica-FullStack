// features/plans/data/repositories/plan_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/plan_remote_data_source.dart';
import '../datasources/plan_local_data_source.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlanRemoteDataSource remoteDataSource;
  final PlanLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PlanRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PlanEntity>>> getPublicPlans({Map<String, String> filters = const {}}) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePlans = await remoteDataSource.getPublicPlans(filters: filters);
        // Cachear los planes localmente
        await localDataSource.cachePlans(remotePlans);
        return Right(remotePlans);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      // Si no hay conexión, intentar obtener datos del cache local
      try {
        final localPlans = await localDataSource.getCachedPlans();
        return Right(localPlans);
      } on CacheException {
        return Left(NetworkFailure());
      }
    }
  }

  @override
  Future<Either<Failure, PlanEntity>> getPlanById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePlan = await remoteDataSource.getPlanById(id);
        // Cachear el plan localmente
        await localDataSource.cachePlan(remotePlan);
        return Right(remotePlan);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      // Si no hay conexión, intentar obtener del cache local
      try {
        final localPlan = await localDataSource.getCachedPlan(id);
        return Right(localPlan);
      } on CacheException {
        return Left(NetworkFailure());
      }
    }
  }
}