import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/plan_inscripcion_repository.dart';
import '../../data/model/plan_inscripcion_model.dart';

class GetInscripcionesUseCase {
  final PlanInscripcionRepository repository;
  GetInscripcionesUseCase(this.repository);

  Future<Either<Failure, List<PlanInscripcionModel>>> call() async {
    return await repository.getInscripciones();
  }
}

class UpdateEstadoInscripcionUseCase {
  final PlanInscripcionRepository repository;
  UpdateEstadoInscripcionUseCase(this.repository);

  Future<Either<Failure, void>> call(int id, String estado) async {
    return await repository.updateEstadoInscripcion(id, estado);
  }
}