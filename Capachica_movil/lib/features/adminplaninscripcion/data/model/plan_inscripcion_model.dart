import 'package:equatable/equatable.dart';

class PlanInscripcionModel extends Equatable {
  final int? id;
  final int planId;
  final int? userId;
  final String? userName;       // 👈 Nuevo: nombre del usuario
  final String? planTitulo;     // 👈 Nuevo: nombre del plan
  final String? estado;
  final String? fechaInscripcion;
  final int numeroParticipantes;
  final double? precioPagado;

  // Campos opcionales
  final String? notasUsuario;
  final String? requerimientosEspeciales;
  final String? metodoPago;
  final String? comentariosAdicionales;
  final String? fechaInicioPlan;

  const PlanInscripcionModel({
    this.id,
    required this.planId,
    this.userId,
    this.userName,
    this.planTitulo,
    this.estado,
    this.fechaInscripcion,
    this.numeroParticipantes = 1,
    this.precioPagado,
    this.notasUsuario,
    this.requerimientosEspeciales,
    this.metodoPago,
    this.comentariosAdicionales,
    this.fechaInicioPlan,
  });

  @override
  List<Object?> get props => [
    id,
    planId,
    userId,
    userName,
    planTitulo,
    estado,
    fechaInscripcion,
    numeroParticipantes,
    precioPagado,
    notasUsuario,
    requerimientosEspeciales,
    metodoPago,
    comentariosAdicionales,
    fechaInicioPlan,
  ];

  factory PlanInscripcionModel.fromJson(Map<String, dynamic> json) {
    return PlanInscripcionModel(
      id: json['id'] as int?,
      planId: json['plan_id'] as int,
      userId: json['user_id'] as int?,
      userName: json['user'] != null ? json['user']['name'] as String? : null, // 👈 Toma el nombre desde "user"
      planTitulo: json['plan'] != null ? json['plan']['titulo'] as String? : null, // 👈 Toma el nombre desde "plan"
      estado: json['estado'] as String?,
      fechaInscripcion: json['fecha_inscripcion'] as String?,
      numeroParticipantes:
      int.tryParse(json['numero_participantes']?.toString() ?? '1') ?? 1,
      precioPagado: json['precio_pagado'] != null
          ? double.tryParse(json['precio_pagado'].toString())
          : null,
      notasUsuario: json['notas_usuario'] as String?,
      requerimientosEspeciales: json['requerimientos_especiales'] as String?,
      metodoPago: json['metodo_pago'] as String?,
      comentariosAdicionales: json['comentarios_adicionales'] as String?,
      fechaInicioPlan: json['fecha_inicio_plan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'plan_id': planId,
      'numero_participantes': numeroParticipantes,
    };

    if (id != null) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    if (estado != null) map['estado'] = estado;
    if (fechaInscripcion != null) map['fecha_inscripcion'] = fechaInscripcion;
    if (precioPagado != null) map['precio_pagado'] = precioPagado;
    if (notasUsuario != null) map['notas_usuario'] = notasUsuario;
    if (requerimientosEspeciales != null)
      map['requerimientos_especiales'] = requerimientosEspeciales;
    if (metodoPago != null) map['metodo_pago'] = metodoPago;
    if (comentariosAdicionales != null)
      map['comentarios_adicionales'] = comentariosAdicionales;
    if (fechaInicioPlan != null) map['fecha_inicio_plan'] = fechaInicioPlan;

    return map;
  }

  PlanInscripcionModel copyWith({
    int? id,
    int? planId,
    int? userId,
    String? userName,
    String? planTitulo,
    String? estado,
    String? fechaInscripcion,
    int? numeroParticipantes,
    double? precioPagado,
    String? notasUsuario,
    String? requerimientosEspeciales,
    String? metodoPago,
    String? comentariosAdicionales,
    String? fechaInicioPlan,
  }) {
    return PlanInscripcionModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      planTitulo: planTitulo ?? this.planTitulo,
      estado: estado ?? this.estado,
      fechaInscripcion: fechaInscripcion ?? this.fechaInscripcion,
      numeroParticipantes: numeroParticipantes ?? this.numeroParticipantes,
      precioPagado: precioPagado ?? this.precioPagado,
      notasUsuario: notasUsuario ?? this.notasUsuario,
      requerimientosEspeciales:
      requerimientosEspeciales ?? this.requerimientosEspeciales,
      metodoPago: metodoPago ?? this.metodoPago,
      comentariosAdicionales:
      comentariosAdicionales ?? this.comentariosAdicionales,
      fechaInicioPlan: fechaInicioPlan ?? this.fechaInicioPlan,
    );
  }
}
