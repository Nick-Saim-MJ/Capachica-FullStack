// category_entity.dart

import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';

class CategoryEntity {
  // Las entidades suelen usar tipos nulos si los datos JSON pueden faltar
  final int id;
  final String nombre;
  final String? descripcion;
  final String? iconoUrl;
  final String? createdAt;
  final String? updatedAt;

  const CategoryEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.iconoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      iconoUrl: json['icono_url'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  CategoryModel toCategory() {
    final String safeDescription = (descripcion == null || descripcion!.trim().isEmpty)
        ? "Sin descripción"
        : descripcion!;
    return CategoryModel(
      id: id,
      nombre: nombre,
      descripcion: safeDescription,
      iconoUrl: iconoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data; // Lista de entidades (e.g., CategoryEntity)
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  const PaginatedResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  // Constructor de fábrica para mapear desde JSON
  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PaginatedResponse<T>(
      currentPage: json['current_page'] as int,
      data: (json['data'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'] as String,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      lastPageUrl: json['last_page_url'] as String,
      nextPageUrl: json['next_page_url'] as String,
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }
}