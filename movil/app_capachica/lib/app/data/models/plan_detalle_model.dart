import 'plan_model.dart';

class Itinerario {
  final int id;
  final String titulo;
  final String? descripcion;
  final int? dia;
  final String? horaInicio;
  final String? horaFin;
  final String? ubicacion;

  Itinerario({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.dia,
    this.horaInicio,
    this.horaFin,
    this.ubicacion,
  });

  factory Itinerario.fromJson(Map<String, dynamic> json) {
    return Itinerario(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      dia: json['dia'],
      horaInicio: json['hora_inicio'] ?? json['horaInicio'],
      horaFin: json['hora_fin'] ?? json['horaFin'],
      ubicacion: json['ubicacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'dia': dia,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'ubicacion': ubicacion,
    };
  }
}

class Incluye {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool isIncluido;

  Incluye({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.isIncluido,
  });

  factory Incluye.fromJson(Map<String, dynamic> json) {
    return Incluye(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      isIncluido: json['is_incluido'] ?? json['isIncluido'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'is_incluido': isIncluido,
    };
  }
}

class PlanDetalle {
  final Plan plan;
  final List<Itinerario> itinerario;
  final List<Incluye> incluye;
  final List<Incluye> noIncluye;
  final Map<String, dynamic>? informacionAdicional;

  PlanDetalle({
    required this.plan,
    required this.itinerario,
    required this.incluye,
    required this.noIncluye,
    this.informacionAdicional,
  });

  factory PlanDetalle.fromJson(Map<String, dynamic> json) {
    return PlanDetalle(
      plan: Plan.fromJson(json['plan'] ?? json),
      itinerario: (json['itinerario'] as List<dynamic>?)
          ?.map((e) => Itinerario.fromJson(e))
          .toList() ?? [],
      incluye: (json['incluye'] as List<dynamic>?)
          ?.map((e) => Incluye.fromJson(e))
          .toList() ?? [],
      noIncluye: (json['no_incluye'] as List<dynamic>?)
          ?.map((e) => Incluye.fromJson(e))
          .toList() ?? [],
      informacionAdicional: json['informacion_adicional'] != null 
          ? Map<String, dynamic>.from(json['informacion_adicional']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.toJson(),
      'itinerario': itinerario.map((e) => e.toJson()).toList(),
      'incluye': incluye.map((e) => e.toJson()).toList(),
      'no_incluye': noIncluye.map((e) => e.toJson()).toList(),
      'informacion_adicional': informacionAdicional,
    };
  }
} 