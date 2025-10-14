import 'package:aplicativo_capachica/features/categoria/data/datasources/categoria_remote_data_source.dart';
import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/categoria/domain/repository/categoria_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final models = await remoteDataSource.getCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<CategoryEntity> getCategory(int id) async {
    final model = await remoteDataSource.getCategory(id);
    return model.toEntity();
  }

  @override
  Future<CategoryEntity> createCategory(CategoryDTO categoryDto) async {
    final model = await remoteDataSource.createCategory(categoryDto);
    return model.toEntity();
  }

  @override
  Future<CategoryEntity> updateCategory(int id, CategoryDTO categoryDto) async {
    final model = await remoteDataSource.updateCategory(id, categoryDto);
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(int id) async {
    return await remoteDataSource.deleteCategory(id);
  }

  @override
  Future<CategoryEntity> toggleStatus(int id, bool status) async {
    final model = await remoteDataSource.toggleStatus(id, status);
    return model.toEntity();
  }
}