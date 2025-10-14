import '../../domain/entities/plan.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required int id,
    required String nombre,
    required String descripcion,
    required int duracionDias,
    required int capacidad,
    required int cuposDisponibles,
    double? precioTotal,
    String? dificultad,
    String? queIncluye,
    String? imagenPrincipalUrl,
    String? estado, // 👈 agregado
    List<EmprendedorEntity> emprendedores = const [],
    List<DiaEntity> dias = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
    id: id,
    nombre: nombre,
    descripcion: descripcion,
    duracionDias: duracionDias,
    capacidad: capacidad,
    cuposDisponibles: cuposDisponibles,
    precioTotal: precioTotal,
    dificultad: dificultad,
    queIncluye: queIncluye,
    imagenPrincipalUrl: imagenPrincipalUrl,
    estado: estado, // 👈 agregado
    emprendedores: emprendedores,
    dias: dias,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // ✅ Factory constructor para crear desde JSON
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel.fromLaravelJson(json);
  }

  // ✅ Adaptado para tu backend Laravel
  factory PlanModel.fromLaravelJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      duracionDias: json['duracion_dias'] is int
          ? json['duracion_dias']
          : int.tryParse(json['duracion_dias'].toString()) ?? 1,
      capacidad: json['capacidad'] is int
          ? json['capacidad']
          : int.tryParse(json['capacidad'].toString()) ?? 0,
      cuposDisponibles: json['cupos_disponibles'] is int
          ? json['cupos_disponibles']
          : int.tryParse(json['cupos_disponibles'].toString()) ?? 0,
      precioTotal: _parseDouble(json['precio_total']),
      dificultad: json['dificultad'],
      queIncluye: json['que_incluye'],
      imagenPrincipalUrl: json['imagen_principal_url'],
      estado: json['estado'] as String?, // 👈 agregado
      emprendedores: const [],
      dias: const [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,

    );
  }

  // ✅ Conversión segura de número/dinero
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ✅ Serialización a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion_dias': duracionDias,
      'capacidad': capacidad,
      'cupos_disponibles': cuposDisponibles,
      'precio_total': precioTotal,
      'dificultad': dificultad,
      'que_incluye': queIncluye,
      'imagen_principal_url': imagenPrincipalUrl,
      'estado': estado, // 👈 agregado
      'emprendedores': [], // placeholder
      'dias': [], // placeholder
    };
  }
}