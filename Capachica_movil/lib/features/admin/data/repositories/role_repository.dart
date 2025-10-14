import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/role_model.dart';

abstract class RoleRepository {
  Future<Result<List<RoleModel>>> list();
  Future<Result<RoleModel>> create(String name, List<String> permissions);
  Future<Result<RoleModel>> update(int id, String name, List<String> permissions);
  Future<Result<bool>> delete(int id);
}

class RoleRepositoryImpl implements RoleRepository {
  final ApiClient _api;
  RoleRepositoryImpl(this._api);

  @override
  Future<Result<List<RoleModel>>> list() async {
    try {
      final res = await _api.get('/roles');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List).map((j) => RoleModel.fromJson(j)).toList();
        return Result.success(list);
      }
      return Result.error(res.data['message'] ?? 'Error al listar roles');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<RoleModel>> create(String name, List<String> permissions) async {
    try {
      final res = await _api.post('/roles', data: {'name': name, 'permissions': permissions}, options: Options(contentType: Headers.jsonContentType));
      if (res.data['success'] == true) {
        return Result.success(RoleModel.fromJson(res.data['data']));
      }
      return Result.error(res.data['message'] ?? 'No se pudo crear el rol');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<RoleModel>> update(int id, String name, List<String> permissions) async {
    try {
      final res = await _api.put('/roles/$id', data: {'name': name, 'permissions': permissions}, options: Options(contentType: Headers.jsonContentType));
      if (res.data['success'] == true) {
        return Result.success(RoleModel.fromJson(res.data['data']));
      }
      return Result.error(res.data['message'] ?? 'No se pudo actualizar el rol');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> delete(int id) async {
    try {
      final res = await _api.delete('/roles/$id');
      return res.data['success'] == true ? Result.success(true) : Result.error(res.data['message'] ?? 'No se pudo eliminar el rol');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }
}
