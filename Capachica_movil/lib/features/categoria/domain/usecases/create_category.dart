import 'package:aplicativo_capachica/features/categoria/data/datasources/categoria_remote_data_source.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import '../repository/categoria_repository.dart';
import '../../data/models/categoria_model.dart';

abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}
class CreateCategory implements UseCase<CategoryEntity, CategoryDTO>{
  final CategoryRepository repository;

  CreateCategory({required this.repository});

  Future<CategoryEntity> call(CategoryDTO dto) async {
    return await repository.createCategory(dto);
  }
}