// Archivo: lib/presentation/blocs/service/servicio_state.dart

import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:equatable/equatable.dart';

enum ServicioStatus { initial, loading, success, failure, updating }

class ServicioState extends Equatable {
  final ServicioStatus status;
  final List<ServiceEntity> servicios;
  final List<ServiceEntity> serviciosFiltrados;
  final bool isLoading;
  final String error;
  final String searchQuery;
  final int categoriaSeleccionada;
  final int emprendedorSeleccionadoId;
  final ServiceEntity? lastOperationService;

  const ServicioState({
    this.status = ServicioStatus.initial,
    this.servicios = const [],
    this.serviciosFiltrados = const [],
    this.isLoading = false,
    this.error = '',
    this.searchQuery = '',
    this.categoriaSeleccionada = 0,
    this.emprendedorSeleccionadoId = 0,
    this.lastOperationService,
  });

  // Método copyWith para crear nuevos estados inmutables
  ServicioState copyWith({
    ServicioStatus? status,
    List<ServiceEntity>? servicios,
    List<ServiceEntity>? serviciosFiltrados,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? categoriaSeleccionada,
    int? emprendedorSeleccionadoId,
    ServiceEntity? lastOperationService,
  }) {
    return ServicioState(
      status: status ?? this.status,
      servicios: servicios ?? this.servicios,
      serviciosFiltrados: serviciosFiltrados ?? this.serviciosFiltrados,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      emprendedorSeleccionadoId: emprendedorSeleccionadoId ?? this.emprendedorSeleccionadoId,
      lastOperationService: lastOperationService,
    );
  }

  @override
  List<Object?> get props => [
    status,
    servicios,
    serviciosFiltrados,
    isLoading,
    error,
    searchQuery,
    categoriaSeleccionada,
    emprendedorSeleccionadoId,
    lastOperationService,
  ];
}