import 'package:aplicativo_capachica/core/usecase/usecase.dart';
import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/categoria/domain/repository/categoria_repository.dart';

class GetCategories implements NoParamsUseCase<List<CategoryEntity>> {
  final CategoryRepository repository;
  GetCategories({required this.repository});

  @override
  Future<List<CategoryEntity>> call() async {
    return await repository.getCategories();
  }
}
