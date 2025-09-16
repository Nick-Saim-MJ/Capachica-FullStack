import '../../domain/repositories/evento_repository.dart';
import '../../data/models/evento_model.dart';
import '../../services/evento_service.dart';

class EventoRepositoryImpl implements EventoRepository {
  final EventoService _eventoService;

  EventoRepositoryImpl(this._eventoService);

  @override
  Future<List<Evento>> getAllEventos() async {
    return await _eventoService.getAllEventos();
  }

  @override
  Future<List<Evento>> getEventosProximos() async {
    return await _eventoService.getEventosProximos();
  }

  @override
  Future<List<Evento>> getEventosActivos() async {
    return await _eventoService.getEventosActivos();
  }

  @override
  Future<Evento> getEventoById(int id) async {
    return await _eventoService.getEventoById(id);
  }

  @override
  Future<List<Evento>> getEventosByEmprendedor(int emprendedorId) async {
    return await _eventoService.getEventosByEmprendedor(emprendedorId);
  }
} 