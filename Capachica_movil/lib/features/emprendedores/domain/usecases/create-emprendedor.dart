// domain/usecases/create-municipalidad.dart
import '../entities/emprendedor.dart';
import '../repositories/emprendedor_repository.dart';

class CreateEmprendedor {
  final EmprendedorRepository repository;

  CreateEmprendedor({required this.repository});

  Future<bool> call(EmprendedorEntity emprendedor) async {
    return await repository.createEmprendedor(emprendedor);
  }
}
