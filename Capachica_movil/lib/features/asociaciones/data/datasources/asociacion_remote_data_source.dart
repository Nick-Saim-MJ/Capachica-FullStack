// lib/features/asociaciones/data/datasources/asociacion_remote_data_source.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert' show utf8;

import '../../../../core/network/api_config.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/asociacion_model.dart';
import '../models/emprendedor_model.dart';
import '../models/municipalidad_model.dart';
import 'package:aplicativo_capachica/features/asociaciones/data/models/laravel_paginated.dart';
import '../../domain/usecases/create_asociacion.dart';
import '../../domain/usecases/update_asociacion.dart';


abstract class AsociacionRemoteDataSource {
  // ✅ usar el tipo real de paginación
  Future<LaravelPaginated<AsociacionModel>> getAsociaciones({
    int page = 1,
    int perPage = 10,
  });

  Future<AsociacionModel> getAsociacionById(int id);

  Future<List<EmprendedorModel>> getEmprendedoresByAsociacion(int asociacionId);

  Future<List<AsociacionModel>> getAsociacionesByMunicipalidad(int municipalidadId);

  Future<List<AsociacionModel>> buscarAsociacionesPorUbicacion({
    required double latitud,
    required double longitud,
    int distanciaKm = 10, // ✅ opcional, default 10
  });

  // Municipalidades
  Future<List<MunicipalidadModel>> getMunicipalidades();

  // CRUD Operations
  Future<AsociacionModel> createAsociacion(CreateAsociacionParams params);
  Future<AsociacionModel> updateAsociacion(UpdateAsociacionParams params);
  Future<void> deleteAsociacion(int id);
}

class AsociacionRemoteDataSourceImpl implements AsociacionRemoteDataSource {
  final http.Client client;
  final AppSecureStorage secureStorage;

  AsociacionRemoteDataSourceImpl({required this.client, required this.secureStorage});

  // Helper para obtener headers con autenticación
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await secureStorage.getToken();
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  @override
  Future<LaravelPaginated<AsociacionModel>> getAsociaciones({
    int page = 1,
    int perPage = 10,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones').replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
    });

    final headers = await _getAuthHeaders();
    final res = await client.get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> body =
    json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('API error: ${body['message'] ?? 'Unknown'}');
    }

    // body['data'] es el OBJETO paginado; su lista está en data.data[]
    final Map<String, dynamic> paginated = body['data'] as Map<String, dynamic>;

    return LaravelPaginated<AsociacionModel>.fromJson(
      paginated,
          (obj) => AsociacionModel.fromJson(obj as Map<String, dynamic>),
    );
  }

  @override
  Future<AsociacionModel> getAsociacionById(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones/$id');
    final headers = await _getAuthHeaders();
    final res = await client.get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> body =
    json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('API error: ${body['message'] ?? 'Unknown'}');
    }

    return AsociacionModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<EmprendedorModel>> getEmprendedoresByAsociacion(int asociacionId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones/$asociacionId/emprendedores');
    final headers = await _getAuthHeaders();
    final res = await client.get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> body =
    json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('API error: ${body['message'] ?? 'Unknown'}');
    }

    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => EmprendedorModel.fromJson(j)).toList();
  }

  @override
  Future<List<AsociacionModel>> getAsociacionesByMunicipalidad(int municipalidadId) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones/municipalidad/$municipalidadId');
    final headers = await _getAuthHeaders();
    final res = await client.get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> body =
    json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('API error: ${body['message'] ?? 'Unknown'}');
    }

    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => AsociacionModel.fromJson(j)).toList();
  }

  @override
  Future<List<AsociacionModel>> buscarAsociacionesPorUbicacion({
    required double latitud,
    required double longitud,
    int distanciaKm = 10,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones/ubicacion/buscar').replace(
      queryParameters: {
        'latitud': '$latitud',
        'longitud': '$longitud',
        'distancia': '$distanciaKm',
      },
    );

    final headers = await _getAuthHeaders();
    final res = await client.get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> body =
    json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('API error: ${body['message'] ?? 'Unknown'}');
    }

    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => AsociacionModel.fromJson(j)).toList();
  }

  // CRUD Operations
  @override
  Future<AsociacionModel> createAsociacion(CreateAsociacionParams params) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones');
    
    final body = {
      'nombre': params.nombre,
      if (params.descripcion != null) 'descripcion': params.descripcion,
      if (params.direccion != null) 'direccion': params.direccion,
      if (params.telefono != null) 'telefono': params.telefono,
      if (params.email != null) 'email': params.email,
      if (params.latitud != null) 'latitud': params.latitud,
      if (params.longitud != null) 'longitud': params.longitud,
      'municipalidad_id': params.municipalidadId,
      if (params.estado != null) 'estado': params.estado,
      if (params.imagen != null) 'imagen': params.imagen,
    };

    final headers = await _getAuthHeaders();
    final res = await client.post(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> responseBody =
        json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (responseBody['success'] != true) {
      throw Exception('API error: ${responseBody['message'] ?? 'Unknown'}');
    }

    return AsociacionModel.fromJson(responseBody['data'] as Map<String, dynamic>);
  }

  @override
  Future<AsociacionModel> updateAsociacion(UpdateAsociacionParams params) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones/${params.id}');
    
    final body = {
      'nombre': params.nombre,
      if (params.descripcion != null) 'descripcion': params.descripcion,
      if (params.direccion != null) 'direccion': params.direccion,
      if (params.telefono != null) 'telefono': params.telefono,
      if (params.email != null) 'email': params.email,
      if (params.latitud != null) 'latitud': params.latitud,
      if (params.longitud != null) 'longitud': params.longitud,
      'municipalidad_id': params.municipalidadId,
      if (params.estado != null) 'estado': params.estado,
      if (params.imagen != null) 'imagen': params.imagen,
    };

    final headers = await _getAuthHeaders();
    final res = await client.put(
      uri,
      headers: headers,
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> responseBody =
        json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (responseBody['success'] != true) {
      throw Exception('API error: ${responseBody['message'] ?? 'Unknown'}');
    }

    return AsociacionModel.fromJson(responseBody['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAsociacion(int id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/asociaciones/$id');

    final headers = await _getAuthHeaders();
    final res = await client.delete(
      uri,
      headers: headers,
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    // Verificar si hay respuesta con contenido
    if (res.body.isNotEmpty) {
      final Map<String, dynamic> responseBody =
          json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

      if (responseBody['success'] != true) {
        throw Exception('API error: ${responseBody['message'] ?? 'Unknown'}');
      }
    }
  }

  @override
  Future<List<MunicipalidadModel>> getMunicipalidades() async {
    // Usar el endpoint correcto del backend: /api/municipalidad/
    final uri = Uri.parse('${ApiConfig.baseUrl}/municipalidad');
    final headers = await _getAuthHeaders();
    final res = await client.get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> body =
        json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('API error: ${body['message'] ?? 'Unknown'}');
    }

    final list = (body['data'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => MunicipalidadModel.fromJson(j)).toList();
  }
}
