import '../../data/models/evento_model.dart';

abstract class EventoRepository {
  Future<List<Evento>> getAllEventos();
  Future<List<Evento>> getEventosProximos();
  Future<List<Evento>> getEventosActivos();
  Future<Evento> getEventoById(int id);
  Future<List<Evento>> getEventosByEmprendedor(int emprendedorId);
} 