// category_bloc.dart

import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/delete_category.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/getCategories.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/create_category.dart';
import 'package:aplicativo_capachica/features/categoria/domain/usecases/update_category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategoriesUseCase;
  final CreateCategory createCategoryUseCase;
  final UpdateCategory updateCategoryUseCase;
  final DeleteCategory deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  })
      : super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<RefreshCategories>(_onRefreshCategories);
    on<SearchCategoryChanged>(_onSearchCategoryChanged);
    on<ClearFilters>(_onClearFilters);
    on<CategoryUpdated>(_onCategoryUpdated);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }
  List<CategoryEntity> _allCategories = [];
  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    if (state.categories.isNotEmpty && state.searchTerm.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoading: true, error: '', categories: []));

    try {
      _allCategories = await getCategoriesUseCase();

      final filteredList = _filterCategories(_allCategories, state.searchTerm);

      emit(state.copyWith(
        isLoading: false,
        categories: filteredList,
        error: '',
      ));

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: "Error al cargar categorías: ${e.toString()}",
      ));
    }
  }

  Future<void> _onRefreshCategories(
      RefreshCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(isLoading: true, error: ''));
    await _onLoadCategories(LoadCategories(), emit);
  }

  Future<void> _onSearchCategoryChanged(
    SearchCategoryChanged event, Emitter<CategoryState> emit) async {
    final filteredList = _filterCategories(_allCategories, event.searchTerm);
    emit(state.copyWith(
      isLoading: false,
      searchTerm: event.searchTerm,
      categories: filteredList,
      error: '',
    ));
  }

  void _onClearFilters(ClearFilters event, Emitter<CategoryState> emit) {
    emit(state.copyWith(searchTerm: ''));
  }

  void _onCategoryUpdated(CategoryUpdated event, Emitter<CategoryState> emit) {
    final updatedList = state.categories.map((cat) {
      return cat.id == event.category.id ? event.category : cat;
    }).toList();

    emit(state.copyWith(categories: updatedList));
  }
  List<CategoryEntity> _filterCategories(List<CategoryEntity> all, String term) {
    if (term.isEmpty) {
      return all;
    }
    final lowerTerm = term.toLowerCase();
    return all.where((category) {
      final nombre = category.nombre.toLowerCase();
      return nombre.contains(lowerTerm);
    }).toList();
  }

  Future<void> _onCreateCategory(
      CreateCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      final newCategory = await createCategoryUseCase(event.categoryDto);

      final updatedList = [newCategory, ...state.categories];

      emit(state.copyWith(
        categories: updatedList,
        error: '',
        isLoading: false,
      ));

    } catch (e) {
      emit(state.copyWith(
        error: "Error al crear categoría: ${e.toString()}",
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      final params = UpdateCategoryParams(
        id: event.id,
        categoryDto: event.categoryDto,
      );
      final updatedCategory = await updateCategoryUseCase(params);

      final updatedList = state.categories.map((cat) {
        return cat.id == event.id ? updatedCategory : cat;
      }).toList();

      emit(state.copyWith(
        categories: updatedList,
        error: '',
        isLoading: false,
      ));

    } catch (e) {
      emit(state.copyWith(
        error: "Error al actualizar categoría: ${e.toString()}",
        isLoading: false,
      ));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await deleteCategoryUseCase(event.id);
      final updatedList = state.categories.where((cat) => cat.id != event.id).toList();

      emit(state.copyWith(
        categories: updatedList,
        error: '',
        isLoading: false,
      ));

    } catch (e) {
      emit(state.copyWith(
        error: "Error al eliminar categoría: ${e.toString()}",
        isLoading: false,
      ));
    }
  }
}