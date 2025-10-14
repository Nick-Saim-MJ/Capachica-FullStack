// domain/usecases/delete_emprendedor.dart
import '../repositories/emprendedor_repository.dart';

class DeleteEmprendedor {
  final EmprendedorRepository repository;

  DeleteEmprendedor({required this.repository});

  Future<bool> call(int id) async {
    return await repository.deleteEmprendedor(id);
  }
}
