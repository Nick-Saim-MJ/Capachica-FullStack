// Archivo: lib/domain/entities/service_entity.dart

import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';

class ServiceEntity {
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
  final EmprendedorEntity emprendedor;
  final List<CategoryEntity> categorias;
  final List<HorarioCapachica> horarios;
  final List<dynamic> sliders;

  ServiceEntity({
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
  ServiceEntity copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? precioReferencial,
    int? emprendedorId,
    bool? estado,
    String? createdAt,
    String? updatedAt,
    int? capacidad,
    String? latitud,
    String? longitud,
    String? ubicacionReferencia,
    EmprendedorEntity? emprendedor,
    List<CategoryEntity>? categorias,
    List<HorarioCapachica>? horarios,
    List<dynamic>? sliders,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioReferencial: precioReferencial ?? this.precioReferencial,
      emprendedorId: emprendedorId ?? this.emprendedorId,
      // Esta es la propiedad clave para tu use case de toggle
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      capacidad: capacidad ?? this.capacidad,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      ubicacionReferencia: ubicacionReferencia ?? this.ubicacionReferencia,
      emprendedor: emprendedor ?? this.emprendedor,
      // Para listas, usamos el operador ?? para mantener la referencia original
      // si no se pasa un nuevo valor, o la nueva lista si se proporciona.
      categorias: categorias ?? this.categorias,
      horarios: horarios ?? this.horarios,
      sliders: sliders ?? this.sliders,
    );
  }
}