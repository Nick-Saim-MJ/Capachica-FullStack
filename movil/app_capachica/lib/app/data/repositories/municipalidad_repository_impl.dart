import '../../domain/repositories/municipalidad_repository.dart';
import '../../data/models/api_response_model.dart';
import '../../data/models/slider_model.dart';
import '../../data/models/municipalidad_model.dart';
import '../../data/models/municipalidad_detalle_model.dart';
import '../../services/municipalidad_service.dart';

class MunicipalidadRepositoryImpl implements MunicipalidadRepository {
  final MunicipalidadService _service;

  MunicipalidadRepositoryImpl(this._service);

  @override
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      print('🏛️ MunicipalidadRepository: Ejecutando health check...');
      return await _service.healthCheck();
    } catch (e) {
      print('❌ MunicipalidadRepository: Error en health check: $e');
      rethrow;
    }
  }

  @override
  Future<List<Slider>> getSliders() async {
    try {
      print('🏛️ MunicipalidadRepository: Obteniendo sliders...');
      return await _service.getSliders();
    } catch (e) {
      print('❌ MunicipalidadRepository: Error obteniendo sliders: $e');
      rethrow;
    }
  }

  @override
  Future<List<Municipalidad>> listMunicipalidades() async {
    try {
      print('🏛️ MunicipalidadRepository: Obteniendo lista de municipalidades...');
      return await _service.listMunicipalidades();
    } catch (e) {
      print('❌ MunicipalidadRepository: Error obteniendo municipalidades: $e');
      rethrow;
    }
  }

  @override
  Future<Municipalidad> getMunicipalidad(int id) async {
    try {
      print('🏛️ MunicipalidadRepository: Obteniendo municipalidad con ID: $id');
      return await _service.getMunicipalidad(id);
    } catch (e) {
      print('❌ MunicipalidadRepository: Error obteniendo municipalidad $id: $e');
      rethrow;
    }
  }

  @override
  Future<MunicipalidadDetalle> getMunicipalidadConRelaciones(int id) async {
    try {
      print('🏛️ MunicipalidadRepository: Obteniendo municipalidad $id con relaciones...');
      return await _service.getMunicipalidadConRelaciones(id);
    } catch (e) {
      print('❌ MunicipalidadRepository: Error obteniendo municipalidad $id con relaciones: $e');
      rethrow;
    }
  }
} 