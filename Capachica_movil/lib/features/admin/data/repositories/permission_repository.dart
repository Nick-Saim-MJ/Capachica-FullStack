import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/permission_model.dart';

abstract class PermissionRepository {
  Future<Result<List<PermissionModel>>> list();
}

class PermissionRepositoryImpl implements PermissionRepository {
  final ApiClient _api;
  PermissionRepositoryImpl(this._api);

  @override
  Future<Result<List<PermissionModel>>> list() async {
    try {
      final res = await _api.get('/permissions');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List).map((j) => PermissionModel.fromJson(j)).toList();
        return Result.success(list);
      }
      return Result.error(res.data['message'] ?? 'Error al listar permisos');
    } catch (e) {
      return Result.error('Error de conexión: ${e.toString()}');
    }
  }
}
