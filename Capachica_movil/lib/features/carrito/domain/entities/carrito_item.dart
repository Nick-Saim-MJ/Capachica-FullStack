import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'package:equatable/equatable.dart';
import '../../../servicio/domain/entities/servicio.dart';
import '../../../servicio/data/models/servicio_model.dart';

class CarritoItem extends Equatable {
  final String id;
  final ServiceEntity servicio;
  final DateTime fechaSeleccionada;
  final String horaInicio;
  final String horaFin;
  final int cantidad;
  final String notas;
  final DateTime fechaAgregado;

  const CarritoItem({
    required this.id,
    required this.servicio,
    required this.fechaSeleccionada,
    required this.horaInicio,
    required this.horaFin,
    required this.cantidad,
    required this.notas,
    required this.fechaAgregado,
  });

  @override
  List<Object?> get props => [
    id,
    servicio,
    fechaSeleccionada,
    horaInicio,
    horaFin,
    cantidad,
    notas,
    fechaAgregado,
  ];

  CarritoItem copyWith({
    String? id,
    ServiceEntity? servicio,
    DateTime? fechaSeleccionada,
    String? horaInicio,
    String? horaFin,
    int? cantidad,
    String? notas,
    DateTime? fechaAgregado,
  }) {
    return CarritoItem(
      id: id ?? this.id,
      servicio: servicio ?? this.servicio,
      fechaSeleccionada: fechaSeleccionada ?? this.fechaSeleccionada,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      cantidad: cantidad ?? this.cantidad,
      notas: notas ?? this.notas,
      fechaAgregado: fechaAgregado ?? this.fechaAgregado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicio_id': servicio.id,
      'servicio_nombre': servicio.nombre,
      'servicio_descripcion': servicio.descripcion,
      'servicio_precio': servicio.precioReferencial,
      'servicio_emprendedor_id': servicio.emprendedorId,
      'servicio_estado': servicio.estado,
      'servicio_created_at': servicio.createdAt,
      'servicio_updated_at': servicio.updatedAt,
      'servicio_capacidad': servicio.capacidad,
      'servicio_latitud': servicio.latitud,
      'servicio_longitud': servicio.longitud,
      'servicio_ubicacion': servicio.ubicacionReferencia,
      'fecha_seleccionada': fechaSeleccionada.toIso8601String(),
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'cantidad': cantidad,
      'notas': notas,
      'fecha_agregado': fechaAgregado.toIso8601String(),
    };
  }

  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? s = json['servicio'] as Map<String, dynamic>?;

    final ServiceEntity servicio = s != null
        ? ServiceEntity(
            id: s['id'],
            nombre: s['nombre'] ?? 'Servicio',
            descripcion: s['descripcion'] ?? '',
            precioReferencial: s['precio_referencial'] ?? '0',
            emprendedorId: s['emprendedor_id'] ?? 0,
            estado: s['estado'] ?? true,
            createdAt: s['created_at'] ?? '',
            updatedAt: s['updated_at'] ?? '',
            capacidad: s['capacidad'] ?? 1,
            latitud: s['latitud'] ?? '0',
            longitud: s['longitud'] ?? '0',
            ubicacionReferencia: s['ubicacion'] ?? '',
            emprendedor: EmprendedorEntity(
              id: s['emprendedor_id'] ?? 0,
              nombre: s['emprendedor_nombre'] ?? '',
              tipoServicio: s['emprendedor_tipo_servicio'] ?? '',
              descripcion: s['emprendedor_descripcion'] ?? '',
              ubicacion: s['emprendedor_ubicacion'] ?? '',
              telefono: s['emprendedor_telefono'] ?? '',
              email: s['emprendedor_email'] ?? '',
              paginaWeb: s['emprendedor_pagina_web'] ?? '',
              horarioAtencion: s['emprendedor_horario_atencion'] ?? '',
              precioRango: s['emprendedor_precio_rango'] ?? '',
              metodosPago: s['emprendedor_metodos_pago'] ?? '',
              capacidadAforo: s['emprendedor_capacidad_aforo'] ?? 0,
              numeroPersonasAtiende: s['emprendedor_numero_personas_atiende'] ?? 0,
              comentariosResenas: s['emprendedor_comentarios_resenas'] ?? '',
              imagenes: s['emprendedor_imagenes'] ?? '',
              categoria: s['emprendedor_categoria'] ?? '',
              certificaciones: s['emprendedor_certificaciones'] ?? '',
              idiomasHablados: s['emprendedor_idiomas_hablados'] ?? '',
              opcionesAcceso: s['emprendedor_opciones_acceso'] ?? '',
              facilidadesDiscapacidad: s['emprendedor_facilidades_discapacidad'] ?? false,
              estado: s['emprendedor_estado'] ?? true,
              createdAt: s['emprendedor_created_at'] ?? '',
              updatedAt: s['emprendedor_updated_at'] ?? '',
              asociacionId: s['emprendedor_asociacion_id'] ?? 0,
            ),
            categorias: s['categorias'] ?? [],
            horarios: s['horarios'] ?? [],
            sliders: s['sliders'] ?? [],
          )
        : ServiceEntity(
            id: json['servicio_id'],
            nombre: json['servicio_nombre'] ?? 'Servicio',
            descripcion: json['servicio_descripcion'] ?? '',
            precioReferencial: json['servicio_precio'] ?? '0',
            emprendedorId: json['servicio_emprendedor_id'] ?? 0,
            estado: json['servicio_estado'] ?? true,
            createdAt: json['servicio_created_at'] ?? '',
            updatedAt: json['servicio_updated_at'] ?? '',
            capacidad: json['servicio_capacidad'] ?? 1,
            latitud: json['servicio_latitud'] ?? '0',
            longitud: json['servicio_longitud'] ?? '0',
            ubicacionReferencia: json['servicio_ubicacion'] ?? '',
            emprendedor: EmprendedorEntity(
              id: json['emprendedor_id'] ?? 0,
              nombre: json['emprendedor_nombre'] ?? '',
              tipoServicio: json['emprendedor_tipo_servicio'] ?? '',
              descripcion: json['emprendedor_descripcion'] ?? '',
              ubicacion: json['emprendedor_ubicacion'] ?? '',
              telefono: json['emprendedor_telefono'] ?? '',
              email: json['emprendedor_email'] ?? '',
              paginaWeb: json['emprendedor_pagina_web'] ?? '',
              horarioAtencion: json['emprendedor_horario_atencion'] ?? '',
              precioRango: json['emprendedor_precio_rango'] ?? '',
              metodosPago: json['emprendedor_metodos_pago'] ?? '',
              capacidadAforo: json['emprendedor_capacidad_aforo'] ?? 0,
              numeroPersonasAtiende: json['emprendedor_numero_personas_atiende'] ?? 0,
              comentariosResenas: json['emprendedor_comentarios_resenas'] ?? '',
              imagenes: json['emprendedor_imagenes'] ?? '',
              categoria: json['emprendedor_categoria'] ?? '',
              certificaciones: json['emprendedor_certificaciones'] ?? '',
              idiomasHablados: json['emprendedor_idiomas_hablados'] ?? '',
              opcionesAcceso: json['emprendedor_opciones_acceso'] ?? '',
              facilidadesDiscapacidad: json['emprendedor_facilidades_discapacidad'] ?? false,
              estado: json['emprendedor_estado'] ?? true,
              createdAt: json['emprendedor_created_at'] ?? '',
              updatedAt: json['emprendedor_updated_at'] ?? '',
              asociacionId: json['emprendedor_asociacion_id'] ?? 0,
            ),
            categorias: json['categorias'] ?? [],
            horarios: json['horarios'] ?? [],
            sliders: json['sliders'] ?? [],
          );

    return CarritoItem(
      id: json['id'],
      servicio: servicio,
      fechaSeleccionada: DateTime.parse(json['fecha_seleccionada']),
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      cantidad: json['cantidad'],
      notas: json['notas'] ?? '',
      fechaAgregado: DateTime.parse(json['fecha_agregado']),
    );
  }
}


