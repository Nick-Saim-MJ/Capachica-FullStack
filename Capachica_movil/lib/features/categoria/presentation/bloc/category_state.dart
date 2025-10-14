// category_state.dart

import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:equatable/equatable.dart';

class CategoryState extends Equatable {
  final bool isLoading;
  final String error;
  final String searchTerm;

  final List<CategoryEntity> categories;

  const CategoryState({
    this.isLoading = false,
    this.error = '',
    this.searchTerm = '',
    this.categories = const [],
  });

  CategoryState copyWith({
    bool? isLoading,
    String? error,
    String? searchTerm,
    List<CategoryEntity>? categories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchTerm: searchTerm ?? this.searchTerm,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    searchTerm,
    categories,
  ];
}