import 'package:equatable/equatable.dart';

/// Representa la información básica de un emprendedor asociado a un plan.
class PlanEmprendedor extends Equatable {
  final int id;
  final String nombre;
  final String? telefono;
  final String? email;

  const PlanEmprendedor({
    required this.id,
    required this.nombre,
    this.telefono,
    this.email,
  });

  /// Constructor factory para crear una instancia desde un JSON.
  factory PlanEmprendedor.fromJson(Map<String, dynamic> json) {
    return PlanEmprendedor(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }

  @override
  List<Object?> get props => [id, nombre, telefono, email];
}