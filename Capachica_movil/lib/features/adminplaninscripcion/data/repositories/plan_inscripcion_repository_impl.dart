import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/plan_inscripcion_repository.dart';
import '../model/plan_inscripcion_model.dart';
import '../services/plan_inscripcion_service.dart';

class PlanInscripcionRepositoryImpl implements PlanInscripcionRepository {
  final PlanInscripcionService service;

  PlanInscripcionRepositoryImpl({required this.service});

  @override
  Future<Either<Failure, List<PlanInscripcionModel>>> getInscripciones() async {
    try {
      final inscripciones = await service.getInscripciones();
      return Right(inscripciones);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEstadoInscripcion(int id, String estado) async {
    try {
      await service.updateEstadoInscripcion(id, estado);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PlanInscripcionModel>> createInscripcion(PlanInscripcionModel inscripcion) async {
    try {
      final result = await service.createInscripcion(inscripcion);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: 'Error inesperado: $e'));
    }
  }

}