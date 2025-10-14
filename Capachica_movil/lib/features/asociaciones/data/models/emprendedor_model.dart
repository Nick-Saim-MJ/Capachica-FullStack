// lib/features/asociaciones/data/models/emprendedor_model.dart
import '../../../../core/utils/json_utils.dart';

class EmprendedorModel {
  final int id;
  final String nombre;

  final String? tipoServicio;
  final String? descripcion;
  final String? ubicacion;
  final String? telefono;
  final String? email;
  final String? categoria;

  final List<String> imagenes;
  final List<String> metodosPago;
  final List<String> idiomasHablados;
  final List<String> opcionesAcceso;

  final int? capacidadAforo;
  final int? numeroPersonasAtiende;
  final bool? facilidadesDiscapacidad;
  final int? asociacionId;
  final bool? estado;

  final String? createdAt;
  final String? updatedAt;

  EmprendedorModel({
    required this.id,
    required this.nombre,
    this.tipoServicio,
    this.descripcion,
    this.ubicacion,
    this.telefono,
    this.email,
    this.categoria,
    this.imagenes = const [],
    this.metodosPago = const [],
    this.idiomasHablados = const [],
    this.opcionesAcceso = const [],
    this.capacidadAforo,
    this.numeroPersonasAtiende,
    this.facilidadesDiscapacidad,
    this.asociacionId,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory EmprendedorModel.fromJson(Map<String, dynamic> json) {
    return EmprendedorModel(
      id: asInt(json['id']) ?? 0,
      nombre: asString(json['nombre']),
      tipoServicio: json['tipo_servicio']?.toString(),
      descripcion: json['descripcion']?.toString(),
      ubicacion: json['ubicacion']?.toString(),
      telefono: json['telefono']?.toString(),
      email: json['email']?.toString(),
      categoria: json['categoria']?.toString(),
      imagenes: asStringList(json['imagenes']),
      metodosPago: asStringList(json['metodos_pago']),
      idiomasHablados: asStringList(json['idiomas_hablados']),
      opcionesAcceso: asStringList(json['opciones_acceso']),
      capacidadAforo: asInt(json['capacidad_aforo']),
      numeroPersonasAtiende: asInt(json['numero_personas_atiende']),
      facilidadesDiscapacidad: asBool(json['facilidades_discapacidad']),
      asociacionId: asInt(json['asociacion_id']),
      estado: asBool(json['estado']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'tipo_servicio': tipoServicio,
    'descripcion': descripcion,
    'ubicacion': ubicacion,
    'telefono': telefono,
    'email': email,
    'categoria': categoria,
    'imagenes': imagenes,
    'metodos_pago': metodosPago,
    'idiomas_hablados': idiomasHablados,
    'opciones_acceso': opcionesAcceso,
    'capacidad_aforo': capacidadAforo,
    'numero_personas_atiende': numeroPersonasAtiende,
    'facilidades_discapacidad': facilidadesDiscapacidad,
    'asociacion_id': asociacionId,
    'estado': estado,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
