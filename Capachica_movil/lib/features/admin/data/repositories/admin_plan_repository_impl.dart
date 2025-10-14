import 'package:dartz/dartz.dart';
import 'dart:io'; // Para File y SocketException

import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart'; // Asegúrate de que esta importación sea la correcta
import '../../domain/repositories/admin_plan_repository.dart';
import '../models/admin_plan_model.dart';
import '../services/admin_plan_service.dart';

// La implementación concreta del repositorio.
// Conecta el 'QUÉ' (la interfaz) con el 'CÓMO' (el servicio).
class AdminPlanRepositoryImpl implements AdminPlanRepository {
  final AdminPlanService service;

  AdminPlanRepositoryImpl({required this.service});

  @override
  Future<Either<Failure, List<AdminPlanModel>>> getPlans() async {
    try {
      final plans = await service.getPlans();
      return Right(plans);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on SocketException {
      return const Left(NetworkFailure(message: 'No se pudo conectar a la red.'));
    } catch (e) {
      return Left(GenericFailure(message: 'Ocurrió un error inesperado: $e'));
    }
  }

  @override
  // >>> 1. SE AÑADE el File? imageFile A LA FIRMA <<<
  Future<Either<Failure, AdminPlanModel>> createPlan(AdminPlanModel plan, File? imageFile) async {
    try {
      // >>> 2. SE PASA el imageFile AL SERVICIO <<<
      final newPlan = await service.createPlan(plan, imageFile);
      return Right(newPlan);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on SocketException {
      return const Left(NetworkFailure(message: 'No se pudo conectar a la red.'));
    } catch (e) {
      return Left(GenericFailure(message: 'Ocurrió un error inesperado: $e'));
    }
  }

  @override
  // >>> 3. SE AÑADE el File? imageFile A LA FIRMA <<<
  Future<Either<Failure, AdminPlanModel>> updatePlan(AdminPlanModel plan, File? imageFile) async {
    try {
      // >>> 4. SE PASA el imageFile AL SERVICIO <<<
      final updatedPlan = await service.updatePlan(plan, imageFile);
      return Right(updatedPlan);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on SocketException {
      return const Left(NetworkFailure(message: 'No se pudo conectar a la red.'));
    } catch (e) {
      return Left(GenericFailure(message: 'Ocurrió un error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlan(int id) async {
    try {
      await service.deletePlan(id);
      return const Right(null); // Right(null) o Right(unit) para indicar éxito sin datos
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on SocketException {
      return const Left(NetworkFailure(message: 'No se pudo conectar a la red.'));
    } catch (e) {
      return Left(GenericFailure(message: 'Ocurrió un error inesperado: $e'));
    }
  }
}