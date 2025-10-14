// lib/features/home/data/models/evento_model.dart
import 'package:aplicativo_capachica/features/home/data/models/emprendedor_model.dart';
import 'package:aplicativo_capachica/features/home/data/models/slider_model.dart';
import 'dart:convert';

class EventoModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String tipoEvento;
  final String idiomaPrincipal;
  final DateTime fechaInicio;
  final String horaInicio;
  final DateTime fechaFin;
  final String horaFin;
  final int? duracionHoras;
  final double? coordenadaX;
  final double? coordenadaY;
  final int idEmprendedor;
  final String? queLlevar;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final EmprendedorModel? emprendedor;
  final List<SliderModel>? sliders;

  EventoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoEvento,
    required this.idiomaPrincipal,
    required this.fechaInicio,
    required this.horaInicio,
    required this.fechaFin,
    required this.horaFin,
    this.duracionHoras,
    this.coordenadaX,
    this.coordenadaY,
    required this.idEmprendedor,
    this.queLlevar,
    this.createdAt,
    this.updatedAt,
    this.emprendedor,
    this.sliders,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      tipoEvento: json['tipo_evento'],
      idiomaPrincipal: json['idioma_principal'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      horaInicio: json['hora_inicio'],
      fechaFin: DateTime.parse(json['fecha_fin']),
      horaFin: json['hora_fin'],
      duracionHoras: json['duracion_horas'],
      // Manejo seguro de coordenadas que pueden venir como string
      coordenadaX: _parseDouble(json['coordenada_x']),
      coordenadaY: _parseDouble(json['coordenada_y']),
      idEmprendedor: json['id_emprendedor'],
      queLlevar: json['que_llevar'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      emprendedor: json['emprendedor'] != null
          ? EmprendedorModel.fromJson(json['emprendedor'])
          : null,
      sliders: json['sliders'] != null
          ? (json['sliders'] as List).map((s) => SliderModel.fromJson(s)).toList()
          : null,
    );
  }

  // Método auxiliar para parsear double de manera segura
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo_evento': tipoEvento,
      'idioma_principal': idiomaPrincipal,
      'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'fecha_fin': fechaFin.toIso8601String().split('T')[0],
      'hora_fin': horaFin,
      'duracion_horas': duracionHoras,
      'coordenada_x': coordenadaX,
      'coordenada_y': coordenadaY,
      'id_emprendedor': idEmprendedor,
      'que_llevar': queLlevar,
      'emprendedor': emprendedor?.toJson(),
      'sliders': sliders?.map((s) => s.toJson()).toList(),
    };
  }

  EventoModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? tipoEvento,
    String? idiomaPrincipal,
    DateTime? fechaInicio,
    String? horaInicio,
    DateTime? fechaFin,
    String? horaFin,
    int? duracionHoras,
    double? coordenadaX,
    double? coordenadaY,
    int? idEmprendedor,
    String? queLlevar,
    DateTime? createdAt,
    DateTime? updatedAt,
    EmprendedorModel? emprendedor,
    List<SliderModel>? sliders,
  }) {
    return EventoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipoEvento: tipoEvento ?? this.tipoEvento,
      idiomaPrincipal: idiomaPrincipal ?? this.idiomaPrincipal,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      horaInicio: horaInicio ?? this.horaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      horaFin: horaFin ?? this.horaFin,
      duracionHoras: duracionHoras ?? this.duracionHoras,
      coordenadaX: coordenadaX ?? this.coordenadaX,
      coordenadaY: coordenadaY ?? this.coordenadaY,
      idEmprendedor: idEmprendedor ?? this.idEmprendedor,
      queLlevar: queLlevar ?? this.queLlevar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emprendedor: emprendedor ?? this.emprendedor,
      sliders: sliders ?? this.sliders,
    );
  }

  @override
  String toString() {
    return 'EventoModel(id: $id, nombre: $nombre, tipoEvento: $tipoEvento, fechaInicio: $fechaInicio)';
  }
}

// Modelo auxiliar para crear/actualizar eventos
class CreateEventoRequest {
  final String nombre;
  final String? descripcion;
  final String tipoEvento;
  final String idiomaPrincipal;
  final DateTime fechaInicio;
  final String horaInicio;
  final DateTime fechaFin;
  final String horaFin;
  final int? duracionHoras;
  final double? coordenadaX;
  final double? coordenadaY;
  final int idEmprendedor;
  final String? queLlevar;
  final List<CreateSliderRequest>? sliders;
  final List<int>? deletedSliders;

  CreateEventoRequest({
    required this.nombre,
    this.descripcion,
    required this.tipoEvento,
    required this.idiomaPrincipal,
    required this.fechaInicio,
    required this.horaInicio,
    required this.fechaFin,
    required this.horaFin,
    this.duracionHoras,
    this.coordenadaX,
    this.coordenadaY,
    required this.idEmprendedor,
    this.queLlevar,
    this.sliders,
    this.deletedSliders,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo_evento': tipoEvento,
      'idioma_principal': idiomaPrincipal,
      'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'fecha_fin': fechaFin.toIso8601String().split('T')[0],
      'hora_fin': horaFin,
      'duracion_horas': duracionHoras,
      'coordenada_x': coordenadaX,
      'coordenada_y': coordenadaY,
      'id_emprendedor': idEmprendedor,
      'que_llevar': queLlevar,
      'sliders': sliders?.asMap().entries.map((entry) {
        var slider = entry.value.toJson();
        slider['orden'] = entry.key + 1;
        return slider;
      }).toList(),
      'deleted_sliders': deletedSliders,
    };
  }
}

class CreateSliderRequest {
  final int? id;
  final String? nombre;
  final String? titulo;
  final String? descripcion;
  final String? url;
  final int? orden;
  final bool? activo;
  final bool? esPrincipal;
  final String? imagenPath; // Ruta local de la imagen

  CreateSliderRequest({
    this.id,
    this.nombre,
    this.titulo,
    this.descripcion,
    this.url,
    this.orden,
    this.activo,
    this.esPrincipal,
    this.imagenPath,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'titulo': titulo,
      'descripcion': descripcion,
      'url': url,
      'orden': orden,
      'activo': activo ?? true,
      'es_principal': esPrincipal ?? true,
    };
  }
}