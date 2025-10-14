import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/emprendedor_model.dart';

abstract class EmprendedorRemoteDataSource {
  Future<List<EmprendedorModel>> getAllEmprendedores();
  Future<EmprendedorModel?> getEmprendedorById(int id);
  Future<bool> createEmprendedor(EmprendedorModel emprendedor);
  Future<bool> updateEmprendedor(EmprendedorModel emprendedor);
  Future<bool> deleteEmprendedor(int id);
  Future<List<EmprendedorModel>> searchEmprendedores(String query);
}

class EmprendedorRemoteDataSourceImpl implements EmprendedorRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  EmprendedorRemoteDataSourceImpl({
    required this.baseUrl,
    required this.client,
  });

  @override
  Future<List<EmprendedorModel>> getAllEmprendedores() async {
    List<EmprendedorModel> all = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      final response = await client.get(Uri.parse('$baseUrl/emprendedores?page=$page'));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data']['data'];
        all.addAll(data.map((e) => EmprendedorModel.fromJson(e)).toList());

        // Validamos si hay más páginas
        hasMore = body['data']['next_page_url'] != null;
        page++;
      } else {
        hasMore = false;
      }
    }

    return all;
  }

  @override
  Future<EmprendedorModel?> getEmprendedorById(int id) async {
    try {
      final response = await client.get(Uri.parse("$baseUrl/emprendedores/$id"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final Map<String, dynamic> data = body['data'] ?? body;
        return EmprendedorModel.fromJson(data);
      } else {
        print("❌ Error al obtener emprendedor $id: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("⚠️ Excepción en getEmprendedorById: $e");
      return null;
    }
  }

  @override
  Future<bool> createEmprendedor(EmprendedorModel emprendedor) async {
    try {
      final response = await client.post(
        Uri.parse("$baseUrl/emprendedores"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(emprendedor.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("⚠️ Excepción en createEmprendedor: $e");
      return false;
    }
  }

  @override
  Future<bool> updateEmprendedor(EmprendedorModel emprendedor) async {
    try {
      final response = await client.put(
        Uri.parse("$baseUrl/emprendedores/${emprendedor.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(emprendedor.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("⚠️ Excepción en updateEmprendedor: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteEmprendedor(int id) async {
    try {
      final response = await client.delete(Uri.parse("$baseUrl/emprendedores/$id"));
      return response.statusCode == 204;
    } catch (e) {
      print("⚠️ Excepción en deleteEmprendedor: $e");
      return false;
    }
  }

  @override
  Future<List<EmprendedorModel>> searchEmprendedores(String query) async {
    final response = await client.get(Uri.parse('$baseUrl/emprendedores/search?q=$query'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> dataList = body['data'];
      return dataList.map((e) => EmprendedorModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar emprendedores');
    }
  }
}
