import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import '../repository/categoria_repository.dart';

class GetCategory {
  final CategoryRepository repository;

  GetCategory({required this.repository});

  Future<CategoryEntity> call(int id) {
    return repository.getCategory(id);
  }
}