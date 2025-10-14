// lib/features/home/domain/bloc/evento_bloc.dart
import 'package:aplicativo_capachica/features/home/data/models/evento_model.dart';
import 'package:aplicativo_capachica/features/home/data/repositories/evento_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// Events
abstract class EventoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEventos extends EventoEvent {
  final int? page;
  final bool refresh;

  LoadEventos({this.page, this.refresh = false});

  @override
  List<Object?> get props => [page, refresh];
}

class LoadEventoById extends EventoEvent {
  final int id;

  LoadEventoById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateEvento extends EventoEvent {
  final CreateEventoRequest request;

  CreateEvento(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateEvento extends EventoEvent {
  final int id;
  final CreateEventoRequest request;

  UpdateEvento(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}

class DeleteEvento extends EventoEvent {
  final int id;

  DeleteEvento(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadEventosActivos extends EventoEvent {}

class LoadProximosEventos extends EventoEvent {
  final int limite;

  LoadProximosEventos({this.limite = 5});

  @override
  List<Object?> get props => [limite];
}

class LoadEventosByEmprendedor extends EventoEvent {
  final int emprendedorId;

  LoadEventosByEmprendedor(this.emprendedorId);

  @override
  List<Object?> get props => [emprendedorId];
}

// States
abstract class EventoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventoInitial extends EventoState {}

class EventoLoading extends EventoState {}

class EventoLoaded extends EventoState {
  final List<EventoModel> eventos;
  final bool hasMore;
  final int currentPage;

  EventoLoaded({
    required this.eventos,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [eventos, hasMore, currentPage];

  EventoLoaded copyWith({
    List<EventoModel>? eventos,
    bool? hasMore,
    int? currentPage,
  }) {
    return EventoLoaded(
      eventos: eventos ?? this.eventos,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class EventoDetailLoaded extends EventoState {
  final EventoModel evento;

  EventoDetailLoaded(this.evento);

  @override
  List<Object?> get props => [evento];
}

class EventoCreated extends EventoState {
  final EventoModel evento;

  EventoCreated(this.evento);

  @override
  List<Object?> get props => [evento];
}

class EventoUpdated extends EventoState {
  final EventoModel evento;

  EventoUpdated(this.evento);

  @override
  List<Object?> get props => [evento];
}

class EventoDeleted extends EventoState {}

class EventoError extends EventoState {
  final String message;

  EventoError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventosActivosLoaded extends EventoState {
  final List<EventoModel> eventos;

  EventosActivosLoaded(this.eventos);

  @override
  List<Object?> get props => [eventos];
}

class ProximosEventosLoaded extends EventoState {
  final List<EventoModel> eventos;

  ProximosEventosLoaded(this.eventos);

  @override
  List<Object?> get props => [eventos];
}

class EventosByEmprendedorLoaded extends EventoState {
  final List<EventoModel> eventos;
  final int emprendedorId;

  EventosByEmprendedorLoaded(this.eventos, this.emprendedorId);

  @override
  List<Object?> get props => [eventos, emprendedorId];
}

// BLoC
class EventoBloc extends Bloc<EventoEvent, EventoState> {
  final EventoRepository _repository;
  List<EventoModel> _allEventos = [];
  int _currentPage = 1;
  bool _hasMore = true;

  EventoBloc(this._repository) : super(EventoInitial()) {
    on<LoadEventos>(_onLoadEventos);
    on<LoadEventoById>(_onLoadEventoById);
    on<CreateEvento>(_onCreateEvento);
    on<UpdateEvento>(_onUpdateEvento);
    on<DeleteEvento>(_onDeleteEvento);
    on<LoadEventosActivos>(_onLoadEventosActivos);
    on<LoadProximosEventos>(_onLoadProximosEventos);
    on<LoadEventosByEmprendedor>(_onLoadEventosByEmprendedor);
  }

  Future<void> _onLoadEventos(LoadEventos event, Emitter<EventoState> emit) async {
    if (event.refresh) {
      _allEventos.clear();
      _currentPage = 1;
      _hasMore = true;
      emit(EventoLoading());
    } else if (event.page == null && _allEventos.isEmpty) {
      emit(EventoLoading());
    }

    try {
      final result = await _repository.getEventos(page: event.page ?? _currentPage);

      result.fold(
            (error) => emit(EventoError(error)),
            (eventos) {
          if (event.refresh) {
            _allEventos = eventos;
          } else {
            _allEventos.addAll(eventos);
          }

          _currentPage++;
          _hasMore = eventos.isNotEmpty && eventos.length >= 10; // Asumiendo 10 items por página

          emit(EventoLoaded(
            eventos: List.from(_allEventos),
            hasMore: _hasMore,
            currentPage: _currentPage,
          ));
        },
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEventoById(LoadEventoById event, Emitter<EventoState> emit) async {
    emit(EventoLoading());

    try {
      final result = await _repository.getEventoById(event.id);

      result.fold(
            (error) => emit(EventoError(error)),
            (evento) => emit(EventoDetailLoaded(evento)),
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onCreateEvento(CreateEvento event, Emitter<EventoState> emit) async {
    emit(EventoLoading());

    try {
      final result = await _repository.createEvento(event.request);

      result.fold(
            (error) => emit(EventoError(error)),
            (evento) {
          _allEventos.insert(0, evento); // Agregar al inicio de la lista
          emit(EventoCreated(evento));
        },
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateEvento(UpdateEvento event, Emitter<EventoState> emit) async {
    emit(EventoLoading());

    try {
      final result = await _repository.updateEvento(event.id, event.request);

      result.fold(
            (error) => emit(EventoError(error)),
            (evento) {
          // Actualizar en la lista local
          final index = _allEventos.indexWhere((e) => e.id == evento.id);
          if (index != -1) {
            _allEventos[index] = evento;
          }
          emit(EventoUpdated(evento));
        },
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteEvento(DeleteEvento event, Emitter<EventoState> emit) async {
    emit(EventoLoading());

    try {
      final result = await _repository.deleteEvento(event.id);

      result.fold(
            (error) => emit(EventoError(error)),
            (success) {
          if (success) {
            // Remover de la lista local
            _allEventos.removeWhere((e) => e.id == event.id);
            emit(EventoDeleted());
          } else {
            emit(EventoError('No se pudo eliminar el evento'));
          }
        },
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEventosActivos(LoadEventosActivos event, Emitter<EventoState> emit) async {
    emit(EventoLoading());

    try {
      final result = await _repository.getEventosActivos();

      result.fold(
            (error) => emit(EventoError(error)),
            (eventos) => emit(EventosActivosLoaded(eventos)),
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoadProximosEventos(LoadProximosEventos event, Emitter<EventoState> emit) async {
    emit(EventoLoading());

    try {
      final result = await _repository.getProximosEventos(limite: event.limite);

      result.fold(
            (error) => emit(EventoError(error)),
            (eventos) => emit(ProximosEventosLoaded(eventos)),
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoadEventosByEmprendedor(LoadEventosByEmprendedor event, Emitter<EventoState> emit) async {
    emit(EventoLoading());

    try {
      final result = await _repository.getEventosByEmprendedor(event.emprendedorId);

      result.fold(
            (error) => emit(EventoError(error)),
            (eventos) => emit(EventosByEmprendedorLoaded(eventos, event.emprendedorId)),
      );
    } catch (e) {
      emit(EventoError('Error inesperado: ${e.toString()}'));
    }
  }
}