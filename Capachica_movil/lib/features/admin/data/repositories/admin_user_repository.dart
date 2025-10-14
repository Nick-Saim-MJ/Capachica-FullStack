import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/admin_user_model.dart';
import '../../../../core/constants/api_constants.dart';

abstract class AdminUserRepository {
  Future<Result<List<AdminUserModel>>> list({
    String? search,
    String? estado, // 'activo' | 'inactivo' | null
    String? rol,    // nombre del rol
    int page,
  });

  Future<Result<bool>> activate(int id);
  Future<Result<bool>> deactivate(int id);
  Future<Result<bool>> delete(int id);
  Future<Result<bool>> assignRoles(int id, List<String> roles);

  Future<Result<AdminUserModel>> create(Map<String, dynamic> fields, {String? fotoPerfilPath});
  Future<Result<AdminUserModel>> update(int id, Map<String, dynamic> fields, {String? fotoPerfilPath});

}

class AdminUserRepositoryImpl implements AdminUserRepository {
  final ApiClient _api;
  AdminUserRepositoryImpl(this._api);

  @override
  Future<Result<List<AdminUserModel>>> list({String? search, String? estado, String? rol, int page = 1}) async {
    try {
      final qp = <String, dynamic>{'page': page};
      if (search != null && search.trim().isNotEmpty) qp['search'] = search.trim();
      if (estado != null && estado.isNotEmpty) qp['estado'] = estado;
      if (rol != null && rol.isNotEmpty) qp['rol'] = rol;

      final res = await _api.get('/users', queryParameters: qp);
      if (res.data['success'] == true) {
        final data = res.data['data'];
        final list = (data is Map && data['data'] is List ? data['data'] : data) as List;
        final users = list.map((j) => AdminUserModel.fromJson(j)).toList();
        return Result.success(users);
      }
      return Result.error(res.data['message'] ?? 'Error al listar usuarios');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> activate(int id) async {
    try {
      final res = await _api.post('/users/$id/activate');
      return res.data['success'] == true ? Result.success(true) : Result.error(res.data['message'] ?? 'No se pudo activar');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> deactivate(int id) async {
    try {
      final res = await _api.post('/users/$id/deactivate');
      return res.data['success'] == true ? Result.success(true) : Result.error(res.data['message'] ?? 'No se pudo desactivar');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> delete(int id) async {
    try {
      final res = await _api.delete('/users/$id');
      return res.data['success'] == true ? Result.success(true) : Result.error(res.data['message'] ?? 'No se pudo eliminar');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> assignRoles(int id, List<String> roles) async {
    try {
      final res = await _api.post('/users/$id/roles', data: {'roles': roles});
      return res.data['success'] == true ? Result.success(true) : Result.error(res.data['message'] ?? 'No se pudo asignar roles');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }
  @override
  Future<Result<AdminUserModel>> create(Map<String, dynamic> fields, {String? fotoPerfilPath}) async {
    try {
      // si hay foto => multipart
      if (fotoPerfilPath != null && fotoPerfilPath.trim().isNotEmpty) {
        final form = FormData();
        fields.forEach((k, v) { if (v != null) form.fields.add(MapEntry(k, v.toString())); });
        final file = File(fotoPerfilPath);
        if (await file.exists()) {
          form.files.add(MapEntry('foto_perfil', await MultipartFile.fromFile(file.path)));
        }
        final res = await _api.post('/users', data: form, options: Options(contentType: 'multipart/form-data'));
        if (res.data['success'] == true) {
          return Result.success(AdminUserModel.fromJson(res.data['data']));
        }
        return Result.error(res.data['message'] ?? 'No se pudo crear el usuario');
      } else {
        // json simple
        final data = Map<String, dynamic>.from(fields)..removeWhere((k,v)=>v==null);
        final res = await _api.post('/users', data: data, options: Options(contentType: Headers.jsonContentType));
        if (res.data['success'] == true) {
          return Result.success(AdminUserModel.fromJson(res.data['data']));
        }
        return Result.error(res.data['message'] ?? 'No se pudo crear el usuario');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<AdminUserModel>> update(int id, Map<String, dynamic> fields, {String? fotoPerfilPath}) async {
    try {
      final hasPhoto = fotoPerfilPath != null && fotoPerfilPath.trim().isNotEmpty;
      if (hasPhoto) {
        // multipart + method spoofing para PUT
        final form = FormData();
        fields.forEach((k, v) { if (v != null) form.fields.add(MapEntry(k, v.toString())); });
        form.fields.add(const MapEntry('_method', 'PUT'));
        final file = File(fotoPerfilPath!);
        if (await file.exists()) {
          form.files.add(MapEntry('foto_perfil', await MultipartFile.fromFile(file.path)));
        }
        final res = await _api.post('/users/$id', data: form, options: Options(contentType: 'multipart/form-data'));
        if (res.data['success'] == true) {
          return Result.success(AdminUserModel.fromJson(res.data['data']));
        }
        return Result.error(res.data['message'] ?? 'No se pudo actualizar el usuario');
      } else {
        final data = Map<String, dynamic>.from(fields)..removeWhere((k,v)=>v==null);
        final res = await _api.put('/users/$id', data: data, options: Options(contentType: Headers.jsonContentType));
        if (res.data['success'] == true) {
          return Result.success(AdminUserModel.fromJson(res.data['data']));
        }
        return Result.error(res.data['message'] ?? 'No se pudo actualizar el usuario');
      }
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }
}
