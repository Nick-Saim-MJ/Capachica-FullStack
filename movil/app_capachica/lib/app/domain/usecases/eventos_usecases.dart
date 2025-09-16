import '../../data/models/evento_model.dart';
import '../repositories/evento_repository.dart';

class GetAllEventosUseCase {
  final EventoRepository _eventoRepository;

  GetAllEventosUseCase(this._eventoRepository);

  Future<List<Evento>> execute() async {
    return await _eventoRepository.getAllEventos();
  }
}

class GetEventosProximosUseCase {
  final EventoRepository _eventoRepository;

  GetEventosProximosUseCase(this._eventoRepository);

  Future<List<Evento>> execute() async {
    return await _eventoRepository.getEventosProximos();
  }
}

class GetEventosActivosUseCase {
  final EventoRepository _eventoRepository;

  GetEventosActivosUseCase(this._eventoRepository);

  Future<List<Evento>> execute() async {
    return await _eventoRepository.getEventosActivos();
  }
}

class GetEventoByIdUseCase {
  final EventoRepository _eventoRepository;

  GetEventoByIdUseCase(this._eventoRepository);

  Future<Evento> execute(int id) async {
    return await _eventoRepository.getEventoById(id);
  }
}

class GetEventosByEmprendedorUseCase {
  final EventoRepository _eventoRepository;

  GetEventosByEmprendedorUseCase(this._eventoRepository);

  Future<List<Evento>> execute(int emprendedorId) async {
    return await _eventoRepository.getEventosByEmprendedor(emprendedorId);
  }
} 