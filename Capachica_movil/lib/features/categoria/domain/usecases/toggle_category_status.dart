import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import '../repository/categoria_repository.dart';

class ToggleCategoryStatus {
  final CategoryRepository repository;

  ToggleCategoryStatus({required this.repository});

  Future<CategoryEntity> call(int id, bool status) {
    return repository.toggleStatus(id, status);
  }
}