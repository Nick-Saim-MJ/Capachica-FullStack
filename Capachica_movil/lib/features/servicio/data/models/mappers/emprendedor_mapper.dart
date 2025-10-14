import 'package:aplicativo_capachica/features/categoria/domain/entities/categoria.dart';
import 'package:aplicativo_capachica/features/emprendedores/domain/entities/emprendedor.dart';
import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';

class EmprendedorMapper{

  static Map<String, dynamic> toJson(EmprendedorCapachica model) {
    return {
      'id': model.id,
      'nombre': model.nombre,
      'tipo_servicio': model.tipoServicio,
      'descripcion': model.descripcion,
      'ubicacion': model.ubicacion,
      'telefono': model.telefono,
      'email': model.email,
      'pagina_web': model.paginaWeb,
      'horario_atencion': model.horarioAtencion,
      'precio_rango': model.precioRango,
      'metodos_pago': model.metodosPago,
      'capacidad_aforo': model.capacidadAforo,
      'numero_personas_atiende': model.numeroPersonasAtiende,
      'comentarios_resenas': model.comentariosResenas,
      'imagenes': model.imagenes,
      'categoria': model.categoria,
      'certificaciones': model.certificaciones,
      'idiomas_hablados': model.idiomasHablados,
      'opciones_acceso': model.opcionesAcceso,
      'facilidades_discapacidad': model.facilidadesDiscapacidad,
      'estado': model.estado,
      'created_at': model.createdAt,
      'updated_at': model.updatedAt,
      'asociacion_id': model.asociacionId,
    };
  }

  static EmprendedorCapachica toServicioModel(EmprendedorEntity e) {
    return EmprendedorCapachica(
      id: e.id,
      nombre: e.nombre,
      tipoServicio: e.tipoServicio,
      descripcion: e.descripcion,
      ubicacion: e.ubicacion,
      telefono: e.telefono,
      email: e.email,
      paginaWeb: e.paginaWeb,
      horarioAtencion: e.horarioAtencion,
      precioRango: e.precioRango,
      metodosPago: e.metodosPago ?? const [],
      capacidadAforo: e.capacidadAforo,
      numeroPersonasAtiende: e.numeroPersonasAtiende,
      comentariosResenas: e.comentariosResenas,
      imagenes: e.imagenes ?? const [],
      categoria: e.categoria ?? '',
      certificaciones: e.certificaciones ?? const [],
      idiomasHablados: e.idiomasHablados ?? const [],
      opcionesAcceso: e.opcionesAcceso ?? const [],
      facilidadesDiscapacidad: e.facilidadesDiscapacidad,
      asociacionId: e.asociacionId,
      estado: e.estado, createdAt: '', updatedAt: '',
    );
  }
  static CategoriaCapachica toCategoryModel(CategoryEntity e){
      return CategoriaCapachica(
        id: e.id,
        nombre: e.nombre,
        descripcion: e.descripcion!,
        iconoUrl: e.iconoUrl!,
        createdAt: e.createdAt!,
        updatedAt: e.updatedAt!,
      );
    }
}