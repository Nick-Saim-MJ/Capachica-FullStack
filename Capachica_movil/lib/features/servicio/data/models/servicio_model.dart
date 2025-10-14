import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'dart:convert';

class ServicioCapachica {
  final int id;
  final String nombre;
  final String descripcion;
  final String precioReferencial;
  final int emprendedorId;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final int capacidad;
  final String latitud;
  final String longitud;
  final String ubicacionReferencia;
  final EmprendedorCapachica emprendedor;
  final List<CategoriaCapachica> categorias;
  final List<HorarioCapachica> horarios;
  final List<dynamic> sliders;

  ServicioCapachica({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioReferencial,
    required this.emprendedorId,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.capacidad,
    required this.latitud,
    required this.longitud,
    required this.ubicacionReferencia,
    required this.emprendedor,
    required this.categorias,
    required this.horarios,
    required this.sliders,
  });

  factory ServicioCapachica.fromJson(Map<String, dynamic> json) {
    return ServicioCapachica(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioReferencial: json['precio_referencial'] ?? json['precioReferencial'] ?? '0',
      emprendedorId: json['emprendedor_id'] ?? json['emprendedorId'] ?? 0,
      estado: json['estado'] ?? false,
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      updatedAt: json['updated_at'] ?? json['updatedAt'] ?? '',
      capacidad: json['capacidad'] ?? 0,
      latitud: json['latitud'] ?? '',
      longitud: json['longitud'] ?? '',
      ubicacionReferencia: json['ubicacion_referencia'] ?? json['ubicacionReferencia'] ?? '',
      emprendedor: EmprendedorCapachica.fromJson(json['emprendedor'] ?? {}),
      categorias: (json['categorias'] as List? ?? [])
          .map((e) => CategoriaCapachica.fromJson(e))
          .toList(),
      horarios: (json['horarios'] as List? ?? [])
          .map((e) => HorarioCapachica.fromJson(e))
          .toList(),
      sliders: json['sliders'] ?? [],
    );
  }
}

class EmprendedorCapachica {
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
  final String createdAt;
  final String updatedAt;

  EmprendedorCapachica({
    required this.id,
    required this.nombre,
    required this.tipoServicio,
    required this.descripcion,
    required this.ubicacion,
    required this.telefono,
    required this.email,
    required this.paginaWeb,
    required this.horarioAtencion,
    required this.precioRango,
    required this.metodosPago,
    required this.capacidadAforo,
    required this.numeroPersonasAtiende,
    required this.comentariosResenas,
    required this.imagenes,
    required this.categoria,
    required this.certificaciones,
    required this.idiomasHablados,
    required this.opcionesAcceso,
    required this.facilidadesDiscapacidad,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.asociacionId,
  });

  static List<String> _parseList(dynamic data) {
    if (data == null) return const [];

    if (data is String) {
      try {
        final decodedList = json.decode(data);
        if (decodedList is List) {
          return decodedList.map((e) => e.toString()).toList();
        }
      } catch (_) {
        return const [];
      }
    }

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return const [];
  }
  factory EmprendedorCapachica.fromJson(Map<String, dynamic> json) {
    return EmprendedorCapachica(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      tipoServicio: json['tipo_servicio'] as String?,
      descripcion: json['descripcion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      paginaWeb: json['pagina_web'] as String?,
      horarioAtencion: json['horario_atencion'] as String?,
      precioRango: json['precio_rango'] as String?,
      metodosPago: _parseList(json['metodos_pago']),
      capacidadAforo: json['capacidad_aforo'] as int?,
      numeroPersonasAtiende: json['numero_personas_atiende'] as int?,
      comentariosResenas: json['comentarios_resenas'] as String?,
      imagenes: _parseList(json['imagenes']),
      categoria: json['categoria'] as String,
      certificaciones: _parseList(json['certificaciones']),
      idiomasHablados: _parseList(json['idiomas_hablados']),
      opcionesAcceso: _parseList(json['opciones_acceso']),
      facilidadesDiscapacidad: json['facilidades_discapacidad'] as bool,
      asociacionId: json['asociacion_id'] as int?,
      estado: json['estado'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
  EmprendedorEntity toEntity() {
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
      metodosPago: metodosPago ?? const [],
      capacidadAforo: capacidadAforo,
      numeroPersonasAtiende: numeroPersonasAtiende,
      comentariosResenas: comentariosResenas,
      imagenes: imagenes ?? const [],
      categoria: categoria ?? '',
      certificaciones: certificaciones ?? const [],
      idiomasHablados: idiomasHablados ?? const [],
      opcionesAcceso: opcionesAcceso ?? const [],
      facilidadesDiscapacidad: facilidadesDiscapacidad,
      asociacionId: asociacionId,
      estado: estado,
    );
  }
}

class CategoriaCapachica {
  final int id;
  final String nombre;
  final String descripcion;
  final String iconoUrl;
  final String createdAt;
  final String updatedAt;

  CategoriaCapachica({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.iconoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoriaCapachica.fromJson(Map<String, dynamic> json) {
    return CategoriaCapachica(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      iconoUrl: json['icono_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono_url': iconoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      iconoUrl: iconoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class HorarioCapachica {
  final int? id;
  final int? servicioId;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool activo;
  final String? createdAt;
  final String? updatedAt;

  HorarioCapachica({
    this.id,
    this.servicioId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  HorarioCapachica copyWith({
    int? id,
    int? servicioId,
    String? diaSemana,
    String? horaInicio,
    String? horaFin,
    bool? activo,
    String? createdAt,
    String? updatedAt
  }) {
    return HorarioCapachica(
      id: id ?? this.id,
      diaSemana: diaSemana ?? this.diaSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      activo: activo ?? this.activo,
      servicioId: servicioId ?? this.servicioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HorarioCapachica.fromJson(Map<String, dynamic> json) {
    return HorarioCapachica(
      id: json['id'] ?? 0,
      servicioId: json['servicio_id'] ?? 0,
      diaSemana: json['dia_semana'] ?? '',
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      activo: json['activo'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicio_id': servicioId,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'activo': activo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null && id! > 0) 'id': id,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'activo': activo,
    };
  }
}

const List<String> diasSemana = [
  'lunes', 'martes', 'miercoles', 'jueves',
  'viernes', 'sabado', 'domingo'
];

class ServicioRequestDTO {
  final String nombre;
  final int capacidad;
  final int emprendedorId;

  final String? descripcion;
  final String? precioReferencial;
  final String? latitud;
  final String? longitud;
  final String? ubicacionReferencia;
  final bool? estado;

  final List<int> categoriaIds;
  final List<HorarioRequestDTO> horarios;
  ServicioRequestDTO({
    required this.nombre,
    required this.capacidad,
    required this.emprendedorId,

    this.descripcion,
    this.precioReferencial,
    this.latitud,
    this.longitud,
    this.ubicacionReferencia,
    this.estado,

    this.categoriaIds = const [],
    this.horarios = const [],
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'nombre': nombre,
      'capacidad': capacidad,
      'emprendedor_id': emprendedorId,
      'categorias': categoriaIds,
      'horarios': horarios.map((h) => h.toJson()).toList(),
    };
    if (descripcion != null) jsonMap['descripcion'] = descripcion;
    if (precioReferencial != null) jsonMap['precio_referencial'] = precioReferencial;
    if (latitud != null) jsonMap['latitud'] = latitud;
    if (longitud != null) jsonMap['longitud'] = longitud;
    if (ubicacionReferencia != null) jsonMap['ubicacion_referencia'] = ubicacionReferencia;
    if (estado != null) jsonMap['estado'] = estado;
    return jsonMap;
  }
}
class HorarioRequestDTO {
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool? activo;

  HorarioRequestDTO({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.activo,
  });

  Map<String, dynamic> toJson() {
    return {
      'dia_semana': diaSemana,   // snake_case
      'hora_inicio': horaInicio, // snake_case
      'hora_fin': horaFin,       // snake_case
      'activo': activo,
    };
  }
}