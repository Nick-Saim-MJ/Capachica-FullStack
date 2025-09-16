import '../../data/models/api_response_model.dart';
import '../../data/models/slider_model.dart';
import '../../data/models/municipalidad_model.dart';
import '../../data/models/municipalidad_detalle_model.dart';

abstract class MunicipalidadRepository {
  /// Verifica que la aplicación funciona correctamente
  Future<ApiResponse<Map<String, dynamic>>> healthCheck();
  
  /// Obtiene la lista de banners promocionales
  Future<List<Slider>> getSliders();
  
  /// Obtiene la lista de municipalidades
  Future<List<Municipalidad>> listMunicipalidades();
  
  /// Obtiene una municipalidad específica por ID
  Future<Municipalidad> getMunicipalidad(int id);
  
  /// Obtiene una municipalidad con todas sus relaciones (servicios, negocios, etc.)
  Future<MunicipalidadDetalle> getMunicipalidadConRelaciones(int id);
} 