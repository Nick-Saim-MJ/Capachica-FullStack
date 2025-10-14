import 'package:equatable/equatable.dart';

class AdminPlanModel extends Equatable {
  final int? id;
  final String title;
  final String description;
  final double price;
  final int duration;
  final bool isActive;
  final int capacidad;
  final String? imagenPrincipalUrl;

  // >>> 1. SE AÑADEN LAS PROPIEDADES DE FECHA <<<
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminPlanModel({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.isActive,
    required this.capacidad,
    this.imagenPrincipalUrl,
    // >>> 2. SE AÑADEN AL CONSTRUCTOR <<<
    this.createdAt,
    this.updatedAt,
  });

  @override
  // >>> 3. SE AÑADEN A PROPS <<<
  List<Object?> get props => [id, title, description, price, duration, isActive, capacidad, imagenPrincipalUrl, createdAt, updatedAt];

  factory AdminPlanModel.fromJson(Map<String, dynamic> json) {
    return AdminPlanModel(
      id: json['id'] as int?,
      title: json['nombre'] as String? ?? '',
      description: json['descripcion'] as String? ?? '',
      price: double.tryParse(json['precio_total'].toString()) ?? 0.0,
      duration: int.tryParse(json['duracion_dias'].toString()) ?? 0,
      isActive: json['estado'] == 'activo',
      capacidad: int.tryParse(json['capacidad'].toString()) ?? 0,
      imagenPrincipalUrl: json['imagen_principal_url'] as String?,

      // >>> 4. SE LEEN LAS FECHAS DESDE EL JSON <<<
      // Se usa DateTime.parse para convertir el texto de la fecha a un objeto DateTime.
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': title,
      'descripcion': description,
      'precio_total': price,
      'duracion_dias': duration,
      'estado': isActive ? 'activo' : 'inactivo',
      'capacidad': capacidad,
    };
  }

  AdminPlanModel copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    int? duration,
    bool? isActive,
    int? capacidad,
    String? imagenPrincipalUrl,
    // >>> 5. SE AÑADEN A copyWith <<<
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminPlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      capacidad: capacidad ?? this.capacidad,
      imagenPrincipalUrl: imagenPrincipalUrl ?? this.imagenPrincipalUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}