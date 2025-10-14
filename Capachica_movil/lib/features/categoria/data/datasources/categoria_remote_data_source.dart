// category_remote_data_source.dart

import 'dart:convert';

import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/core/storage/secure_storage.dart';
import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:http/http.dart' as http;

class CategoryRemoteDataSource {
  final AppSecureStorage secureStorage;
  final http.Client client;
  final String _baseUrl = BackendConfig.baseUrl;

  CategoryRemoteDataSource({
    required this.client,
    required this.secureStorage
  });

  Future<List<CategoryModel>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categorias');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Accedemos a la lista que está directamente bajo la clave 'data'
      final List<dynamic> dataList = responseBody['data'] as List<dynamic>;

      // Mapeamos a Entity y luego a Model
      return dataList
          .map((item) => CategoryEntity.fromJson(item as Map<String, dynamic>).toCategory())
          .toList();
    } else {
      throw Exception('Error al obtener categorías. Status: ${response.statusCode}');
    }
  }


  Future<CategoryModel> getCategory(int id) async {
    final url = Uri.parse('$_baseUrl/categorias/$id');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        // Decodificación del JSON
        final responseBody = json.decode(response.body) as Map<String, dynamic>;

        // Asumimos que la respuesta es { "success": true, "data": { /* CATEGORIA */ } }
        final entity = CategoryEntity.fromJson(responseBody['data'] as Map<String, dynamic>);
        return entity.toCategory();
      }
      throw Exception('Categoría no encontrada, código: ${response.statusCode}');
    } catch (e) {
      // Capturamos cualquier error de decodificación o red
      throw Exception('Error al obtener categoría por ID: $e');
    }
  }

  Future<CategoryModel> createCategory(CategoryDTO categoryDto) async {
    final url = Uri.parse('$_baseUrl/categorias');
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await secureStorage.getToken()}',
      },
      body: json.encode(categoryDto.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final entity = CategoryEntity.fromJson(responseBody['data'] as Map<String, dynamic>);
      return entity.toCategory();
    } else {
      throw Exception('Fallo al crear categoría. Status: ${response.statusCode}');
    }
  }

  Future<CategoryModel> updateCategory(int id, CategoryDTO categoryDto) async {
    final url = Uri.parse('$_baseUrl/categorias/$id');
    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await secureStorage.getToken()}',
      },
      body: json.encode(categoryDto.toJson()),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final entity = CategoryEntity.fromJson(responseBody['data'] as Map<String, dynamic>);
      return entity.toCategory();
    } else {
      throw Exception('Fallo al actualizar categoría. Status: ${response.statusCode}');
    }
  }

  Future<void> deleteCategory(int id) async {
    final url = Uri.parse('$_baseUrl/categorias/$id');
    final response = await client.delete(url,
      headers: {
        'Authorization': 'Bearer ${await secureStorage.getToken()}',
      },);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Fallo al eliminar categoría. Status: ${response.statusCode}');
    }
  }

  Future<CategoryModel> toggleStatus(int id, bool status) async {
    final url = Uri.parse('$_baseUrl/categorias/$id/estado');
    final body = json.encode({'estado': status}); // Serializamos el cuerpo

    try {
      final response = await client.patch(
        url,
        headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await secureStorage.getToken()}'
        }, // Necesario para JSON
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;

        final categoryEntity = CategoryEntity.fromJson(
          responseBody['data'] as Map<String, dynamic>,
        );
        return categoryEntity.toCategory();
      }
      throw Exception('Fallo al cambiar el estado. Status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de red al cambiar el estado: $e');
    }
  }
  Future<List<CategoryModel>> searchCategories(String query) async {
    final url = Uri.parse('$_baseUrl/categorias/search?q=$query');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> dataList = responseBody['data'] as List<dynamic>;

        return dataList
            .map((item) => CategoryEntity.fromJson(item as Map<String, dynamic>).toCategory())
            .toList();
      }
      throw Exception('Error al buscar categorías. Status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error inesperado al buscar categorías: $e');
    }
  }
}