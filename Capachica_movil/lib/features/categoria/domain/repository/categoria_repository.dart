// category_repository.dart

import 'package:aplicativo_capachica/features/categoria/data/datasources/categoria_remote_data_source.dart';
import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';

abstract class CategoryRepository {
  // Las funciones del repositorio devuelven el Modelo de Dominio (Category)

  Future<List<CategoryEntity>> getCategories();

  Future<CategoryEntity> getCategory(int id);

  Future<CategoryEntity> createCategory(CategoryDTO categoryDto);

  Future<CategoryEntity> updateCategory(int id, CategoryDTO categoryDto);

  Future<void> deleteCategory(int id);

  Future<CategoryEntity> toggleStatus(int id, bool status);
}