import 'package:equatable/equatable.dart';

/// Representa un servicio específico (actividad) dentro de un día del plan.
class PlanDiaServicio extends Equatable {
  final int id;
  final String nombre;
  final String descripcion;
  final double? precio; // El precio del servicio si lo tuviera

  const PlanDiaServicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.precio,
  });

  /// Constructor factory para crear una instancia de [PlanDiaServicio] desde un JSON.
  /// El backend, en la ruta pública, devuelve estos campos para cada servicio.
  factory PlanDiaServicio.fromJson(Map<String, dynamic> json) {
    return PlanDiaServicio(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      // Se convierte el precio a double, asegurando que sea numérico y manejando nulos.
      precio: (json['precio'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, nombre, descripcion, precio];
}