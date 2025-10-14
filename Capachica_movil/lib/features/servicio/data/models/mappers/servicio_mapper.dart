// Archivo: lib/data/mappers/service_mapper.dart

import 'package:aplicativo_capachica/features/categoria/data/models/categoria_model.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/mappers/emprendedor_mapper.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';

class ServiceMapper {
  static ServiceEntity toEntity(ServicioCapachica model) {
    return ServiceEntity(
      id: model.id,
      nombre: model.nombre,
      descripcion: model.descripcion,
      precioReferencial: model.precioReferencial,
      emprendedorId: model.emprendedorId,
      estado: model.estado,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      capacidad: model.capacidad,
      latitud: model.latitud,
      longitud: model.longitud,
      ubicacionReferencia: model.ubicacionReferencia,
      emprendedor: model.emprendedor.toEntity(),
      categorias: model.categorias.map((c) => c.toEntity()).toList(),
      horarios: model.horarios,
      sliders: model.sliders,
    );
  }

  static ServicioCapachica toModel(ServiceEntity entity) {
    return ServicioCapachica(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      precioReferencial: entity.precioReferencial,
      emprendedorId: entity.emprendedorId,
      estado: entity.estado,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      capacidad: entity.capacidad,
      latitud: entity.latitud,
      longitud: entity.longitud,
      ubicacionReferencia: entity.ubicacionReferencia,
      emprendedor: EmprendedorMapper.toServicioModel(entity.emprendedor),
      categorias: entity.categorias.map((c) => EmprendedorMapper.toCategoryModel(c)).toList(),
      horarios: entity.horarios,
      sliders: entity.sliders,
    );
  }
  static Map<String, dynamic> toJson(ServicioCapachica model) {
    return {
      'id': model.id,
      'nombre': model.nombre,
      'descripcion': model.descripcion,
      'precio_referencial': model.precioReferencial, // Asegúrate de usar snake_case para la API
      'emprendedor_id': model.emprendedorId,
      'estado': model.estado,
      'created_at': model.createdAt,
      'updated_at': model.updatedAt,
      'capacidad': model.capacidad,
      'latitud': model.latitud,
      'longitud': model.longitud,
      'ubicacion_referencia': model.ubicacionReferencia,
      'emprendedor': EmprendedorMapper.toJson(model.emprendedor) ,
      'categorias': model.categorias.map((c) => c.toJson()).toList(),
      'horarios': model.horarios.map((h) => h.toJson()).toList(),
      'sliders': model.sliders,
    };
  }
  static ServicioRequestDTO toDTO(ServiceEntity entity) {

    // Mapea List<CategoryEntity> a List<CategoriaRequestDTO>
    final categoriaIds = entity.categorias
        .map((catEntity) => catEntity.id)
        .whereType<int>()
        .toList();

    final horarioDtos = entity.horarios.map((horarioEntity) {
      return HorarioRequestDTO(
        diaSemana: horarioEntity.diaSemana,
        horaInicio: horarioEntity.horaInicio,
        horaFin: horarioEntity.horaFin,
        activo: horarioEntity.activo,
      );
    }).toList();

    return ServicioRequestDTO(
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      precioReferencial: entity.precioReferencial,
      capacidad: entity.capacidad,
      latitud: entity.latitud,
      longitud: entity.longitud,
      ubicacionReferencia: entity.ubicacionReferencia,
      estado: entity.estado,
      emprendedorId: entity.emprendedorId,

      categoriaIds: categoriaIds,
      horarios: horarioDtos,
    );
  }
}