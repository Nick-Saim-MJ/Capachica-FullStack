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
  final String tipoServicio;
  final String descripcion;
  final String ubicacion;
  final String telefono;
  final String email;
  final String paginaWeb;
  final String horarioAtencion;
  final String precioRango;
  final String metodosPago;
  final int capacidadAforo;
  final int numeroPersonasAtiende;
  final String comentariosResenas;
  final String imagenes;
  final String categoria;
  final String certificaciones;
  final String idiomasHablados;
  final String opcionesAcceso;
  final bool facilidadesDiscapacidad;
  final bool estado;
  final String createdAt;
  final String updatedAt;
  final int asociacionId;

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

  factory EmprendedorCapachica.fromJson(Map<String, dynamic> json) {
    return EmprendedorCapachica(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      tipoServicio: json['tipo_servicio'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      paginaWeb: json['pagina_web'] ?? '',
      horarioAtencion: json['horario_atencion'] ?? '',
      precioRango: json['precio_rango'] ?? '',
      metodosPago: json['metodos_pago'] ?? '',
      capacidadAforo: json['capacidad_aforo'] ?? 0,
      numeroPersonasAtiende: json['numero_personas_atiende'] ?? 0,
      comentariosResenas: json['comentarios_resenas'] ?? '',
      imagenes: json['imagenes'] ?? '',
      categoria: json['categoria'] ?? '',
      certificaciones: json['certificaciones'] ?? '',
      idiomasHablados: json['idiomas_hablados'] ?? '',
      opcionesAcceso: json['opciones_acceso'] ?? '',
      facilidadesDiscapacidad: json['facilidades_discapacidad'] ?? false,
      estado: json['estado'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      asociacionId: json['asociacion_id'] ?? 0,
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
}

class HorarioCapachica {
  final int id;
  final int servicioId;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool activo;
  final String createdAt;
  final String updatedAt;

  HorarioCapachica({
    required this.id,
    required this.servicioId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

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
} 