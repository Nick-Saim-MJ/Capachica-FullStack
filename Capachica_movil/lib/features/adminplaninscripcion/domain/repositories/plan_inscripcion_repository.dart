import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../data/model/plan_inscripcion_model.dart';

abstract class PlanInscripcionRepository {
  Future<Either<Failure, List<PlanInscripcionModel>>> getInscripciones();
  Future<Either<Failure, void>> updateEstadoInscripcion(int id, String estado);
  Future<Either<Failure, PlanInscripcionModel>> createInscripcion(PlanInscripcionModel inscripcion);
}