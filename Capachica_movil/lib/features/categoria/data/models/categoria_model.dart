import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';

class CategoryModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String? iconoUrl;
  final String? createdAt;
  final String? updatedAt;

  const CategoryModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.iconoUrl,
    this.createdAt,
    this.updatedAt,
  });

  CategoryModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? iconoUrl,
    String? createdAt,
    String? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      iconoUrl: iconoUrl ?? this.iconoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      iconoUrl: iconoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class CategoryDTO {
  final String nombre;
  final String? descripcion;
  final String? iconoUrl;

  CategoryDTO({
    required this.nombre,
    this.descripcion,
    this.iconoUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'nombre': nombre,
    };
    if (descripcion != null) {
      jsonMap['descripcion'] = descripcion;
    }
    if (iconoUrl != null) {
      jsonMap['icono_url'] = iconoUrl;
    }
    return jsonMap;
  }
}

class CategoriaRequestDTO {
  final int categoriaId;

  CategoriaRequestDTO({required this.categoriaId});

  Map<String, dynamic> toJson() {
    return {
      'categoria_id': categoriaId,
    };
  }
}