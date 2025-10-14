
import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicios_relacionados_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiciosRelacionadosCubit extends Cubit<ServiciosRelacionadosState> {
  final ServiceRepository _repository;

  ServiciosRelacionadosCubit({required ServiceRepository repository})
      : _repository = repository,
        super(ServiciosRelacionadosInitial());

  // Método para cargar los servicios relacionados
  Future<void> fetchServiciosRelacionados(
      int categoriaId, int servicioActualId) async {
    if (categoriaId <= 0) {
      emit(const ServiciosRelacionadosLoaded([]));
      return;
    }

    emit(ServiciosRelacionadosLoading());

    try {
      print("fetchServiciosRelacionados");
      print(_repository.getServiciosByCategoria(categoriaId));
      // 1. Llamar al repositorio
      final todosServicios = await _repository.getServiciosByCategoria(categoriaId);

      // 2. Aplicar lógica de filtrado (excluir el actual y tomar los primeros 3)
      final relacionados = todosServicios
          .where((s) => s.id != servicioActualId)
          .take(3)
          .toList();

      emit(ServiciosRelacionadosLoaded(relacionados));
    } catch (e) {
      // ⚠️ El error 'String is not a subtype of int' probablemente se origine aquí.
      // Aquí manejaríamos el error y podrías hacer un debug de 'e'.
      print('Error al cargar relacionados: $e');
      emit(ServiciosRelacionadosError('Error al cargar servicios relacionados: $e'));
    }
  }
}