import 'package:equatable/equatable.dart';
import 'plan_dia_servicio.dart'; // <-- 1. Importamos la clase que acabamos de crear

/// Representa el itinerario completo para un día específico dentro de un plan.
class PlanDia extends Equatable {
  final int numeroDia;
  final String titulo;
  final String descripcion;
  final List<PlanDiaServicio> servicios; // <-- 2. Contiene una lista de servicios

  const PlanDia({
    required this.numeroDia,
    required this.titulo,
    required this.descripcion,
    required this.servicios,
  });

  /// Constructor factory para crear una instancia de [PlanDia] desde un JSON.
  factory PlanDia.fromJson(Map<String, dynamic> json) {
    // Se procesa la lista de servicios anidada.
    // Si 'servicios' no existe o es nulo, se crea una lista vacía para evitar errores.
    final serviciosData = json['servicios'] as List? ?? [];

    final listaDeServicios = serviciosData
        .map((servicioJson) => PlanDiaServicio.fromJson(servicioJson))
        .toList();

    return PlanDia(
      numeroDia: json['numero_dia'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      servicios: listaDeServicios, // Se asigna la lista de servicios ya procesada
    );
  }

  @override
  List<Object?> get props => [numeroDia, titulo, descripcion, servicios];
}