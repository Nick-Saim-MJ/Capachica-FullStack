import 'package:aplicativo_capachica/features/categoria/data/datasources/categoria_remote_data_source.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import '../repository/categoria_repository.dart';
import '../../data/models/categoria_model.dart';

abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

class UpdateCategoryParams {
  final int id;
  final CategoryDTO categoryDto;
  UpdateCategoryParams({required this.id, required this.categoryDto});
}

class UpdateCategory implements UseCase<CategoryEntity, UpdateCategoryParams> {
  final CategoryRepository repository;

  UpdateCategory({required this.repository});

  @override
  Future<CategoryEntity> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(params.id, params.categoryDto);
  }
}