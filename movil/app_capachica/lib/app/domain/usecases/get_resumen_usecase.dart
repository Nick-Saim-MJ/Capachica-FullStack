import '../../data/models/api_response_model.dart';
import '../../data/models/slider_model.dart';
import '../../data/models/municipalidad_model.dart';
import '../../data/models/municipalidad_detalle_model.dart';
import '../repositories/municipalidad_repository.dart';

class ResumenData {
  final ApiResponse<Map<String, dynamic>> healthCheck;
  final List<Slider> sliders;
  final List<Municipalidad> municipalidades;
  final MunicipalidadDetalle? primeraMunicipalidadDetalle;

  ResumenData({
    required this.healthCheck,
    required this.sliders,
    required this.municipalidades,
    this.primeraMunicipalidadDetalle,
  });
}

class GetResumenUseCase {
  final MunicipalidadRepository _repository;

  GetResumenUseCase(this._repository);

  /// Ejecuta todas las llamadas necesarias para poblar el resumen
  Future<ResumenData> execute() async {
    try {
      print('🎯 GetResumenUseCase: Iniciando obtención de datos del resumen...');

      // 1. Health check para verificar que la app funciona
      print('🎯 GetResumenUseCase: Paso 1 - Health check...');
      final healthCheck = await _repository.healthCheck();
      
      if (!healthCheck.success) {
        throw Exception('Health check falló: ${healthCheck.message}');
      }

      // 2. Obtener sliders y municipalidades en paralelo
      print('🎯 GetResumenUseCase: Paso 2 - Obteniendo sliders y municipalidades en paralelo...');
      final futures = await Future.wait([
        _repository.getSliders(),
        _repository.listMunicipalidades(),
      ]);

      final sliders = futures[0] as List<Slider>;
      final municipalidades = futures[1] as List<Municipalidad>;

      // 3. Opcionalmente, obtener relaciones de la primera municipalidad
      MunicipalidadDetalle? primeraMunicipalidadDetalle;
      if (municipalidades.isNotEmpty) {
        try {
          print('🎯 GetResumenUseCase: Paso 3 - Obteniendo detalles de la primera municipalidad...');
          primeraMunicipalidadDetalle = await _repository.getMunicipalidadConRelaciones(
            municipalidades.first.id,
          );
        } catch (e) {
          print('⚠️ GetResumenUseCase: No se pudo obtener detalles de la primera municipalidad: $e');
          // No fallamos si no podemos obtener los detalles
        }
      }

      print('✅ GetResumenUseCase: Datos del resumen obtenidos exitosamente');
      print('   - Health check: ${healthCheck.success}');
      print('   - Sliders: ${sliders.length}');
      print('   - Municipalidades: ${municipalidades.length}');
      print('   - Primera municipalidad con detalles: ${primeraMunicipalidadDetalle != null}');

      return ResumenData(
        healthCheck: healthCheck,
        sliders: sliders,
        municipalidades: municipalidades,
        primeraMunicipalidadDetalle: primeraMunicipalidadDetalle,
      );
    } catch (e) {
      print('❌ GetResumenUseCase: Error obteniendo datos del resumen: $e');
      rethrow;
    }
  }
} 