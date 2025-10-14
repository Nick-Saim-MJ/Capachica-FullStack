// asociacion_local_data_source.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asociacion_model.dart';
import '../models/emprendedor_model.dart';
import '../models/paginated_response_model.dart';

abstract class AsociacionLocalDataSource {
  Future<LaravelPaginated<AsociacionModel>?> getCachedAsociaciones();
  Future<void> cacheAsociaciones(LaravelPaginated<AsociacionModel> asociaciones);
  
  Future<AsociacionModel?> getCachedAsociacionById(int id);
  Future<void> cacheAsociacion(AsociacionModel asociacion);
  
  Future<List<EmprendedorModel>?> getCachedEmprendedoresByAsociacion(int asociacionId);
  Future<void> cacheEmprendedoresByAsociacion(int asociacionId, List<EmprendedorModel> emprendedores);
  
  Future<List<AsociacionModel>?> getCachedAsociacionesByMunicipalidad(int municipalidadId);
  Future<void> cacheAsociacionesByMunicipalidad(int municipalidadId, List<AsociacionModel> asociaciones);
  
  Future<List<AsociacionModel>?> getCachedAsociacionesByUbicacion(String ubicacionKey);
  Future<void> cacheAsociacionesByUbicacion(String ubicacionKey, List<AsociacionModel> asociaciones);
}

class AsociacionLocalDataSourceImpl implements AsociacionLocalDataSource {
  final SharedPreferences sharedPreferences;

  AsociacionLocalDataSourceImpl({required this.sharedPreferences});

  // Cache keys
  static const String CACHED_ASOCIACIONES_KEY = 'CACHED_ASOCIACIONES';
  static const String CACHED_ASOCIACION_KEY = 'CACHED_ASOCIACION_';
  static const String CACHED_EMPRENDEDORES_KEY = 'CACHED_EMPRENDEDORES_';
  static const String CACHED_ASOCIACIONES_MUNICIPALIDAD_KEY = 'CACHED_ASOCIACIONES_MUNICIPALIDAD_';
  static const String CACHED_ASOCIACIONES_UBICACION_KEY = 'CACHED_ASOCIACIONES_UBICACION_';

  @override
  Future<LaravelPaginated<AsociacionModel>?> getCachedAsociaciones() async {
    final jsonString = sharedPreferences.getString(CACHED_ASOCIACIONES_KEY);
    if (jsonString != null) {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return LaravelPaginated.fromJson(
        jsonData,
        (json) => AsociacionModel.fromJson(json),
      );
    }
    return null;
  }

  @override
  Future<void> cacheAsociaciones(LaravelPaginated<AsociacionModel> asociaciones) async {
    final map = {
      'current_page': asociaciones.currentPage,
      'data': asociaciones.data.map((a) => a.toJson()).toList(),
      'per_page': asociaciones.perPage,
      'total': asociaciones.total,
      'last_page': asociaciones.lastPage,
      'next_page_url': asociaciones.nextPageUrl,
      'prev_page_url': asociaciones.prevPageUrl,
    };
    final jsonString = json.encode(map);
    await sharedPreferences.setString(CACHED_ASOCIACIONES_KEY, jsonString);
  }

  @override
  Future<AsociacionModel?> getCachedAsociacionById(int id) async {
    final jsonString = sharedPreferences.getString('$CACHED_ASOCIACION_KEY$id');
    if (jsonString != null) {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return AsociacionModel.fromJson(jsonData);
    }
    return null;
  }

  @override
  Future<void> cacheAsociacion(AsociacionModel asociacion) async {
    final jsonString = json.encode(asociacion.toJson());
    await sharedPreferences.setString('$CACHED_ASOCIACION_KEY${asociacion.id}', jsonString);
  }

  @override
  Future<List<EmprendedorModel>?> getCachedEmprendedoresByAsociacion(int asociacionId) async {
    final jsonString = sharedPreferences.getString('$CACHED_EMPRENDEDORES_KEY$asociacionId');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => EmprendedorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> cacheEmprendedoresByAsociacion(int asociacionId, List<EmprendedorModel> emprendedores) async {
    final jsonString = json.encode(emprendedores.map((e) => e.toJson()).toList());
    await sharedPreferences.setString('$CACHED_EMPRENDEDORES_KEY$asociacionId', jsonString);
  }

  @override
  Future<List<AsociacionModel>?> getCachedAsociacionesByMunicipalidad(int municipalidadId) async {
    final jsonString = sharedPreferences.getString('$CACHED_ASOCIACIONES_MUNICIPALIDAD_KEY$municipalidadId');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => AsociacionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> cacheAsociacionesByMunicipalidad(int municipalidadId, List<AsociacionModel> asociaciones) async {
    final jsonString = json.encode(asociaciones.map((a) => a.toJson()).toList());
    await sharedPreferences.setString('$CACHED_ASOCIACIONES_MUNICIPALIDAD_KEY$municipalidadId', jsonString);
  }

  @override
  Future<List<AsociacionModel>?> getCachedAsociacionesByUbicacion(String ubicacionKey) async {
    final jsonString = sharedPreferences.getString('$CACHED_ASOCIACIONES_UBICACION_KEY$ubicacionKey');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => AsociacionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> cacheAsociacionesByUbicacion(String ubicacionKey, List<AsociacionModel> asociaciones) async {
    final jsonString = json.encode(asociaciones.map((a) => a.toJson()).toList());
    await sharedPreferences.setString('$CACHED_ASOCIACIONES_UBICACION_KEY$ubicacionKey', jsonString);
  }
}

