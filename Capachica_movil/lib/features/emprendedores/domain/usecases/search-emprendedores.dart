// domain/usecases/search_emprendedores.dart
import '../entities/emprendedor.dart';
import '../repositories/emprendedor_repository.dart';

class SearchEmprendedores {
  final EmprendedorRepository repository;

  SearchEmprendedores({required this.repository});

  Future<List<EmprendedorEntity>> call(String query) async {
    return await repository.searchEmprendedores(query);
  }
}
