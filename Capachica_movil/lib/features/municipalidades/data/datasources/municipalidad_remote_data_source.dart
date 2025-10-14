// lib/features/municipalidades/data/datasources/municipalidad_remote_data_source_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'municipalidad_remote_data_source.dart';



// lib/features/municipalidades/data/datasources/municipalidad_remote_data_source.dart
import '../../domain/entities/municipalidad.dart';


abstract class MunicipalidadRemoteDataSource {
  Future<List<MunicipalidadModel>> getAllMunicipalidades();
  Future<MunicipalidadModel?> getMunicipalidadById(int id);
  Future<void> createMunicipalidad(MunicipalidadModel municipalidad);
  Future<void> updateMunicipalidad(MunicipalidadModel municipalidad);
  Future<void> deleteMunicipalidad(int id);
}


class MunicipalidadRemoteDataSourceImpl implements MunicipalidadRemoteDataSource {
  final String baseUrl;

  MunicipalidadRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<MunicipalidadModel>> getAllMunicipalidades() async {
    final response = await http.get(Uri.parse('$baseUrl/municipalidades'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => MunicipalidadModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener municipalidades');
    }
  }

  @override
  Future<MunicipalidadModel?> getMunicipalidadById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/municipalidades/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return MunicipalidadModel.fromJson(data);
    } else {
      return null;
    }
  }

  @override
  Future<void> createMunicipalidad(MunicipalidadModel municipalidad) async {
    final response = await http.post(
      Uri.parse('$baseUrl/municipalidades'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(municipalidad.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear municipalidad');
    }
  }

  @override
  Future<void> updateMunicipalidad(MunicipalidadModel municipalidad) async {
    final response = await http.put(
      Uri.parse('$baseUrl/municipalidades/${municipalidad.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(municipalidad.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar municipalidad');
    }
  }

  @override
  Future<void> deleteMunicipalidad(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/municipalidades/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar municipalidad');
    }
  }
}
