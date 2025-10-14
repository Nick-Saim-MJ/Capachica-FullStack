import '../repository/categoria_repository.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory({required this.repository});

  Future<void> call(int id) {
    return repository.deleteCategory(id);
  }
}