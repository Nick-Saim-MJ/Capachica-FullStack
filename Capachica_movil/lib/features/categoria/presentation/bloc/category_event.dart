import 'package:aplicativo_capachica/features/categoria/data/datasources/categoria_remote_data_source.dart';
import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// 1. Carga inicial de categorías con o sin filtros.
class LoadCategories extends CategoryEvent {}

/// 2. Evento para refrescar la lista (ej: Pull-to-refresh).
class RefreshCategories extends CategoryEvent {}

/// 3. Evento cuando el usuario cambia el texto de búsqueda.
class SearchCategoryChanged extends CategoryEvent {
  final String searchTerm;
  const SearchCategoryChanged(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

/// 4. Evento para limpiar filtros y recargar la lista base.
class ClearFilters extends CategoryEvent {}

/// 5. Evento para actualizar una categoría después de una operación (ej: toggleStatus).
class CategoryUpdated extends CategoryEvent {
  final CategoryEntity category;
  const CategoryUpdated(this.category);

  @override
  List<Object?> get props => [category];
}

class CreateCategoryEvent extends CategoryEvent {
  final CategoryDTO categoryDto;
  const CreateCategoryEvent(this.categoryDto);

  @override
  List<Object?> get props => [categoryDto];
}

class UpdateCategoryEvent extends CategoryEvent {
  final int id;
  final CategoryDTO categoryDto;
  const UpdateCategoryEvent(this.id, this.categoryDto);

  @override
  List<Object?> get props => [id, categoryDto];
}

class DeleteCategoryEvent extends CategoryEvent {
  final int id;
  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

