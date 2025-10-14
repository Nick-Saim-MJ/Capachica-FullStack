// lib/features/home/data/models/emprendedor_model.dart

import 'package:aplicativo_capachica/features/home/data/models/asociacion_model.dart';
import 'package:aplicativo_capachica/features/home/data/models/slider_model.dart';
import 'dart:convert';

class EmprendedorModel {
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
  final List<String>? metodosPago;
  final int? capacidadAforo;
  final int? numeroPersonasAtiende;
  final String? comentariosResenas;
  final List<String>? imagenes;
  final String? categoria;
  final List<String>? certificaciones;
  final List<String>? idiomasHablados;
  final List<String>? opcionesAcceso;
  final bool? facilidadesDiscapacidad;
  final int? asociacionId;
  final bool? estado;
  final AsociacionModel? asociacion;
  final List<SliderModel>? sliders;
  final List<dynamic>? eventos; // Changed to dynamic to avoid circular import

  EmprendedorModel({
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
    this.metodosPago,
    this.capacidadAforo,
    this.numeroPersonasAtiende,
    this.comentariosResenas,
    this.imagenes,
    this.categoria,
    this.certificaciones,
    this.idiomasHablados,
    this.opcionesAcceso,
    this.facilidadesDiscapacidad,
    this.asociacionId,
    this.estado,
    this.asociacion,
    this.sliders,
    this.eventos,
  });

  // Método auxiliar para parsear JSON strings a List<String>
  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      try {
        // Si es un string JSON, parsearlo
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // Si no es JSON válido, dividir por comas
        return value.split(',').map((e) => e.trim()).toList();
      }
    } else if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    return null;
  }

  factory EmprendedorModel.fromJson(Map<String, dynamic> json) {
    return EmprendedorModel(
      id: json['id'],
      nombre: json['nombre'],
      tipoServicio: json['tipo_servicio'],
      descripcion: json['descripcion'],
      ubicacion: json['ubicacion'],
      telefono: json['telefono'],
      email: json['email'],
      paginaWeb: json['pagina_web'],
      horarioAtencion: json['horario_atencion'],
      precioRango: json['precio_rango'],
      metodosPago: _parseStringList(json['metodos_pago']),
      capacidadAforo: json['capacidad_aforo'],
      numeroPersonasAtiende: json['numero_personas_atiende'],
      comentariosResenas: json['comentarios_resenas'],
      imagenes: _parseStringList(json['imagenes']),
      categoria: json['categoria'],
      certificaciones: _parseStringList(json['certificaciones']),
      idiomasHablados: _parseStringList(json['idiomas_hablados']),
      opcionesAcceso: _parseStringList(json['opciones_acceso']),
      facilidadesDiscapacidad: json['facilidades_discapacidad'],
      asociacionId: json['asociacion_id'],
      estado: json['estado'],
      asociacion: json['asociacion'] != null
          ? AsociacionModel.fromJson(json['asociacion'])
          : null,
      sliders: json['sliders'] != null
          ? (json['sliders'] as List).map((s) => SliderModel.fromJson(s)).toList()
          : null,
      eventos: json['eventos'], // Keep as dynamic for now
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo_servicio': tipoServicio,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'telefono': telefono,
      'email': email,
      'pagina_web': paginaWeb,
      'horario_atencion': horarioAtencion,
      'precio_rango': precioRango,
      'metodos_pago': metodosPago,
      'capacidad_aforo': capacidadAforo,
      'numero_personas_atiende': numeroPersonasAtiende,
      'comentarios_resenas': comentariosResenas,
      'imagenes': imagenes,
      'categoria': categoria,
      'certificaciones': certificaciones,
      'idiomas_hablados': idiomasHablados,
      'opciones_acceso': opcionesAcceso,
      'facilidades_discapacidad': facilidadesDiscapacidad,
      'asociacion_id': asociacionId,
      'estado': estado,
      'asociacion': asociacion?.toJson(),
      'sliders': sliders?.map((s) => s.toJson()).toList(),
      'eventos': eventos,
    };
  }

  EmprendedorModel copyWith({
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
    AsociacionModel? asociacion,
    List<SliderModel>? sliders,
    List<dynamic>? eventos,
  }) {
    return EmprendedorModel(
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
      asociacion: asociacion ?? this.asociacion,
      sliders: sliders ?? this.sliders,
      eventos: eventos ?? this.eventos,
    );
  }

  @override
  String toString() {
    return 'EmprendedorModel(id: $id, nombre: $nombre, tipoServicio: $tipoServicio)';
  }
}