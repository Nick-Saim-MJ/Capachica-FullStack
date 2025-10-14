// data/models/emprendedor_model.dart
import 'dart:convert';
import 'package:meta/meta.dart';
import '../../domain/entities/emprendedor.dart';

@immutable
class EmprendedorModel {
  final int id;
  final String nombre;
  final String tipoServicio;
  final String descripcion;
  final String ubicacion;
  final String telefono;
  final String email;
  final String? paginaWeb;
  final String? horarioAtencion;
  final String? precioRango;
  final List<String> metodosPago;
  final int? capacidadAforo;
  final int? numeroPersonasAtienden;
  final String? comentariosResenas;
  final List<String> imagenes;
  final String categoria;
  final List<String> certificaciones;
  final List<String> idiomasHablados;
  final List<String> opcionesAcceso;
  final bool facilidadesDiscapacidad;
  final int? asociacionId;
  final bool estado;
  final List<Map<String, dynamic>> slidersPrincipales;
  final List<Map<String, dynamic>> slidersSecundarios;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmprendedorModel({
    required this.id,
    required this.nombre,
    required this.tipoServicio,
    required this.descripcion,
    required this.ubicacion,
    required this.telefono,
    required this.email,
    this.paginaWeb,
    this.horarioAtencion,
    this.precioRango,
    this.metodosPago = const [],
    this.capacidadAforo,
    this.numeroPersonasAtienden,
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

  /// Función auxiliar universal para parsear listas
  /// Maneja: JSON strings, arrays, strings separados por comas
  static List<String> _safeList(dynamic value) {
    if (value == null) return [];

    // Si ya es una lista
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }

    // Si es un String
    if (value is String) {
      value = value.trim();
      if (value.isEmpty) return [];

      // Intentar decodificar como JSON primero
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
        }
      } catch (_) {
        // No es JSON válido
      }

      // Separar por comas si es string plano
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Función auxiliar para parsear booleanos
  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == '1' || lower == 'true' || lower == 'yes';
    }
    return false;
  }

  /// Convertir JSON -> Model con soporte snake_case y camelCase
  factory EmprendedorModel.fromJson(Map<String, dynamic> json) {
    try {
      return EmprendedorModel(
        id: json['id'] ?? 0,
        nombre: json['nombre'] ?? '',

        // Soporte snake_case y camelCase
        tipoServicio: json['tipo_servicio'] ?? json['tipoServicio'] ?? '',
        descripcion: json['descripcion'] ?? '',
        ubicacion: json['ubicacion'] ?? '',
        telefono: json['telefono'] ?? '',
        email: json['email'] ?? '',
        paginaWeb: json['pagina_web'] ?? json['paginaWeb'],
        horarioAtencion: json['horario_atencion'] ?? json['horarioAtencion'],
        precioRango: json['precio_rango'] ?? json['precioRango'],
        capacidadAforo: json['capacidad_aforo'] ?? json['capacidadAforo'],
        numeroPersonasAtienden: json['numero_personas_atiende'] ?? json['numeroPersonasAtiende'],
        comentariosResenas: json['comentarios_resenas'] ?? json['comentariosResenas'],
        categoria: json['categoria'] ?? '',
        asociacionId: json['asociacion_id'] ?? json['asociacionId'],

        // Booleanos
        facilidadesDiscapacidad: _safeBool(json['facilidades_discapacidad'] ?? json['facilidadesDiscapacidad']),
        estado: _safeBool(json['estado']),

        // Listas usando _safeList
        metodosPago: _safeList(json['metodos_pago'] ?? json['metodosPago']),
        idiomasHablados: _safeList(json['idiomas_hablados'] ?? json['idiomasHablados']),
        imagenes: _safeList(json['imagenes']),
        certificaciones: _safeList(json['certificaciones']),
        opcionesAcceso: _safeList(json['opciones_acceso'] ?? json['opcionesAcceso']),

        // Sliders (listas de Maps)
        slidersPrincipales: (json['sliders_principales'] ?? json['slidersPrincipales']) is List
            ? List<Map<String, dynamic>>.from(json['sliders_principales'] ?? json['slidersPrincipales'] ?? [])
            : [],
        slidersSecundarios: (json['sliders_secundarios'] ?? json['slidersSecundarios']) is List
            ? List<Map<String, dynamic>>.from(json['sliders_secundarios'] ?? json['slidersSecundarios'] ?? [])
            : [],

        // Fechas
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
        updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      );
    } catch (e, stackTrace) {
      print('❌ Error en EmprendedorModel.fromJson: $e');
      print('📋 JSON recibido: $json');
      print('🔍 Stack trace: $stackTrace');
      rethrow;
    }
  }
  /// Convertir Model -> JSON
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
      'numero_personas_atiende': numeroPersonasAtienden,
      'comentarios_resenas': comentariosResenas,
      'imagenes': imagenes,
      'categoria': categoria,
      'certificaciones': certificaciones,
      'idiomas_hablados': idiomasHablados,
      'opciones_acceso': opcionesAcceso,
      'facilidades_discapacidad': facilidadesDiscapacidad,
      'asociacion_id': asociacionId,
      'estado': estado,
      'sliders_principales': slidersPrincipales,
      'sliders_secundarios': slidersSecundarios,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convertir Model -> Entity (para capa de dominio)
  EmprendedorEntity toEntity() {
    // Convertir sliders a URLs simples
    List<String> extractUrls(List<Map<String, dynamic>> sliders) {
      return sliders
          .map((e) => e['url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return EmprendedorEntity(
      id: id,
      nombre: nombre,
      tipoServicio: tipoServicio,
      descripcion: descripcion,
      ubicacion: ubicacion,
      telefono: telefono,
      email: email,
      paginaWeb: paginaWeb,
      horarioAtencion: horarioAtencion,
      precioRango: precioRango,
      categoria: categoria,
      metodosPago: metodosPago,
      capacidadAforo: capacidadAforo,
      numeroPersonasAtiende: numeroPersonasAtienden,
      comentariosResenas: comentariosResenas,
      imagenes: imagenes,
      certificaciones: certificaciones,
      idiomasHablados: idiomasHablados,
      opcionesAcceso: opcionesAcceso,
      facilidadesDiscapacidad: facilidadesDiscapacidad,
      asociacionId: asociacionId,
      estado: estado,
      slidersPrincipales: slidersPrincipales.map((e) => SliderEntity(
        id: e['id'] ?? 0,
        nombre: e['nombre']?.toString(),
        titulo: e['titulo']?.toString(),
        descripcion: e['descripcion']?.toString(),
        url: e['url']?.toString(),
        esPrincipal: e['es_principal'] == true || e['es_principal'] == 1,
        orden: e['orden'] is int ? e['orden'] : int.tryParse(e['orden']?.toString() ?? '0'),
      )).toList(),
      slidersSecundarios: slidersSecundarios.map((e) => SliderEntity(
        id: e['id'] ?? 0,
        nombre: e['nombre']?.toString(),
        titulo: e['titulo']?.toString(),
        descripcion: e['descripcion']?.toString(),
        url: e['url']?.toString(),
        esPrincipal: e['es_principal'] == true || e['es_principal'] == 1,
        orden: e['orden'] is int ? e['orden'] : int.tryParse(e['orden']?.toString() ?? '0'),
      )).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
