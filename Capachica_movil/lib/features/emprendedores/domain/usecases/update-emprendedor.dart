// domain/usecases/update-municipalidad.dart
import '../entities/emprendedor.dart';
import '../repositories/emprendedor_repository.dart';

class UpdateEmprendedor {
  final EmprendedorRepository repository;

  UpdateEmprendedor({required this.repository});

  Future<bool> call(EmprendedorEntity emprendedor) async {
    return await repository.updateEmprendedor(emprendedor);
  }
}
