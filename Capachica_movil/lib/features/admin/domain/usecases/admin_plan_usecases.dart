import 'dart:io'; // <-- 1. AÑADE LA IMPORTACIÓN
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/admin_plan_model.dart';
import '../repositories/admin_plan_repository.dart';

// 1. Caso de Uso para Obtener la lista de planes (SIN CAMBIOS)
class GetPlansUseCase implements UseCase<List<AdminPlanModel>, NoParams> {
  final AdminPlanRepository repository;

  GetPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<AdminPlanModel>>> call(NoParams params) async {
    return await repository.getPlans();
  }
}

// 2. Caso de Uso para Crear un plan (MODIFICADO)
// Ya no implementa UseCase directamente porque la firma de call() cambia.
class CreatePlanUseCase {
  final AdminPlanRepository repository;

  CreatePlanUseCase(this.repository);

  // >>> 2. AÑADE File? imageFile A LA FIRMA <<<
  Future<Either<Failure, AdminPlanModel>> call(AdminPlanModel plan, File? imageFile) async {
    // >>> 3. PASA EL imageFile AL REPOSITORIO <<<
    return await repository.createPlan(plan, imageFile);
  }
}

// 3. Caso de Uso para Actualizar un plan (MODIFICADO)
class UpdatePlanUseCase {
  final AdminPlanRepository repository;

  UpdatePlanUseCase(this.repository);

  // >>> 4. AÑADE File? imageFile A LA FIRMA <<<
  Future<Either<Failure, AdminPlanModel>> call(AdminPlanModel plan, File? imageFile) async {
    // >>> 5. PASA EL imageFile AL REPOSITORIO <<<
    return await repository.updatePlan(plan, imageFile);
  }
}

// 4. Caso de Uso para Eliminar un plan (SIN CAMBIOS)
class DeletePlanUseCase implements UseCase<void, int> {
  final AdminPlanRepository repository;

  DeletePlanUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deletePlan(id);
  }
}