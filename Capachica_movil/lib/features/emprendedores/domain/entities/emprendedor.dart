// domain/entities/emprendedor_entity.dart
// Entity (dominio) que representa un Emprendedor en la capa limpia.
// Clase inmutable, sin dependencia de JSON ni frameworks.

import 'dart:convert';
// domain/entities/emprendedor.dart
// Entity (dominio) que representa un Emprendedor en la capa limpia.
// Clase inmutable, sin dependencia de JSON ni frameworks.

import 'package:meta/meta.dart';

@immutable
class EmprendedorEntity {
  final int id;
  final String nombre;
  final String? tipoServicio;
  final String? descripcion;
  final String? ubicacion;
  final String? telefono;
  final String? email;
  final String? paginaWeb;
  final String? horarioAtencion;
  final String? precioRango;
  final List<String> metodosPago;
  final int? capacidadAforo;
  final int? numeroPersonasAtiende;
  final String? comentariosResenas;
  final List<String> imagenes;
  final String categoria;
  final List<String> certificaciones;
  final List<String> idiomasHablados;
  final List<String> opcionesAcceso;
  final bool facilidadesDiscapacidad;
  final int? asociacionId;
  final bool estado;

  /// Relación opcional con sliders principales y secundarios
  final List<SliderEntity> slidersPrincipales;
  final List<SliderEntity> slidersSecundarios;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmprendedorEntity({
    required this.id,
    required this.nombre,
    this.tipoServicio,
    this.descripcion,
    this.ubicacion,
    this.telefono,
    this.email,
    this.paginaWeb,
    this.horarioAtencion,
    this.precioRango,
    this.metodosPago = const [],
    this.capacidadAforo,
    this.numeroPersonasAtiende,
    this.comentariosResenas,
    this.imagenes = const [],
    required this.categoria,
    this.certificaciones = const [],
    this.idiomasHablados = const [],
    this.opcionesAcceso = const [],
    this.facilidadesDiscapacidad = false,
    this.asociacionId,
    this.estado = true,
    this.slidersPrincipales = const [],
    this.slidersSecundarios = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// copyWith para crear nuevas instancias modificando solo algunos campos
  EmprendedorEntity copyWith({
    int? id,
    String? nombre,
    String? tipoServicio,
    String? descripcion,
    String? ubicacion,
    String? telefono,
    String? email,
    String? paginaWeb,
    String? horarioAtencion,
    String? precioRango,
    List<String>? metodosPago,
    int? capacidadAforo,
    int? numeroPersonasAtiende,
    String? comentariosResenas,
    List<String>? imagenes,
    String? categoria,
    List<String>? certificaciones,
    List<String>? idiomasHablados,
    List<String>? opcionesAcceso,
    bool? facilidadesDiscapacidad,
    int? asociacionId,
    bool? estado,
    List<SliderEntity>? slidersPrincipales,
    List<SliderEntity>? slidersSecundarios,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmprendedorEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      descripcion: descripcion ?? this.descripcion,
      ubicacion: ubicacion ?? this.ubicacion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      paginaWeb: paginaWeb ?? this.paginaWeb,
      horarioAtencion: horarioAtencion ?? this.horarioAtencion,
      precioRango: precioRango ?? this.precioRango,
      metodosPago: metodosPago ?? this.metodosPago,
      capacidadAforo: capacidadAforo ?? this.capacidadAforo,
      numeroPersonasAtiende: numeroPersonasAtiende ?? this.numeroPersonasAtiende,
      comentariosResenas: comentariosResenas ?? this.comentariosResenas,
      imagenes: imagenes ?? this.imagenes,
      categoria: categoria ?? this.categoria,
      certificaciones: certificaciones ?? this.certificaciones,
      idiomasHablados: idiomasHablados ?? this.idiomasHablados,
      opcionesAcceso: opcionesAcceso ?? this.opcionesAcceso,
      facilidadesDiscapacidad: facilidadesDiscapacidad ?? this.facilidadesDiscapacidad,
      asociacionId: asociacionId ?? this.asociacionId,
      estado: estado ?? this.estado,
      slidersPrincipales: slidersPrincipales ?? this.slidersPrincipales,
      slidersSecundarios: slidersSecundarios ?? this.slidersSecundarios,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EmprendedorEntity{'
        'id: $id, '
        'nombre: $nombre, '
        'descripcion: $descripcion, '
        'categoria: $categoria, '
        'tipoServicio: $tipoServicio, '
        'ubicacion: $ubicacion, '
        'telefono: $telefono, '
        'email: $email, '
        'paginaWeb: $paginaWeb, '
        'horarioAtencion: $horarioAtencion, '
        'precioRango: $precioRango, '
        'capacidadAforo: $capacidadAforo, '
        'numeroPersonasAtiende: $numeroPersonasAtiende, '
        'opcionesAcceso: $opcionesAcceso, '
        'asociacionId: $asociacionId, '
        'facilidadesDiscapacidad: $facilidadesDiscapacidad, '
        'metodosPago: $metodosPago, '
        'idiomasHablados: $idiomasHablados, '
        'slidersPrincipales: $slidersPrincipales, '
        'slidersSecundarios: $slidersSecundarios, '
        'estado: $estado'
        '}';
  }
}

/// Extensión para conversión desde JSON directamente
extension EmprendedorEntityJson on EmprendedorEntity {
  static EmprendedorEntity fromJson(Map<String, dynamic> json) {
    // Función para parsear listas de strings
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        if (value.isEmpty) return [];
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
        return value.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '')
            .split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    // Función para parsear booleanos
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value == '1' || value.toLowerCase() == 'true';
      return false;
    }

    // Función para parsear enteros
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    // Función para parsear sliders
    List<SliderEntity> parseSliders(dynamic value) {
      if (value == null || value is! List) return [];
      return value.map((e) {
        final map = e as Map<String, dynamic>;
        return SliderEntity(
          id: parseInt(map['id']) ?? 0,
          nombre: map['nombre']?.toString(),
          titulo: map['titulo']?.toString(),
          descripcion: map['descripcion']?.toString(),
          url: map['url']?.toString(),
          esPrincipal: map['es_principal'] is bool
              ? map['es_principal']
              : map['es_principal'] is int
              ? map['es_principal'] == 1
              : false,
          orden: parseInt(map['orden']),
        );
      }).toList();
    }

    return EmprendedorEntity(
      id: parseInt(json['id']) ?? 0,
      nombre: json['nombre'] ?? '',
      tipoServicio: json['tipo_servicio'],
      descripcion: json['descripcion'],
      ubicacion: json['ubicacion'],
      telefono: json['telefono'],
      email: json['email'],
      paginaWeb: json['pagina_web'],
      horarioAtencion: json['horario_atencion'],
      precioRango: json['precio_rango'],
      metodosPago: parseStringList(json['metodos_pago']),
      capacidadAforo: parseInt(json['capacidad_aforo']),
      numeroPersonasAtiende: parseInt(json['numero_personas_atiende']),
      comentariosResenas: json['comentarios_resenas'],
      imagenes: parseStringList(json['imagenes']),
      categoria: json['categoria'] ?? '',
      certificaciones: parseStringList(json['certificaciones']),
      idiomasHablados: parseStringList(json['idiomas_hablados']),
      opcionesAcceso: parseStringList(json['opciones_acceso']),
      facilidadesDiscapacidad: parseBool(json['facilidades_discapacidad']),
      asociacionId: parseInt(json['asociacion_id']),
      estado: parseBool(json['estado'] ?? true),
      slidersPrincipales: parseSliders(json['sliders_principales']),
      slidersSecundarios: parseSliders(json['sliders_secundarios']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

@immutable
class SliderEntity {
  final int id;
  final String? nombre;
  final String? titulo;
  final String? descripcion;
  final String? url;
  final bool? esPrincipal;
  final int? orden;

  const SliderEntity({
    required this.id,
    this.nombre,
    this.titulo,
    this.descripcion,
    this.url,
    this.esPrincipal,
    this.orden,
  });

  @override
  String toString() =>
      'SliderEntity{id: $id, url: $url, esPrincipal: $esPrincipal}';
}
