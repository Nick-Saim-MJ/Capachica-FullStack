class Emprendedor {
  final int id;
  final String nombre;
  final String tipoServicio;
  final String ubicacion;
  final String? descripcion;
  final String? telefono;
  final String? email;
  final String? imagen;
  final String? imagenes;
  final bool estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final List<ServicioEmprendedor>? servicios;
  final List<RelacionEmprendedor>? relaciones;

  Emprendedor({
    required this.id,
    required this.nombre,
    required this.tipoServicio,
    required this.ubicacion,
    this.descripcion,
    this.telefono,
    this.email,
    this.imagen,
    this.imagenes,
    required this.estado,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.servicios,
    this.relaciones,
  });

  factory Emprendedor.fromJson(Map<String, dynamic> json) {
    return Emprendedor(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      tipoServicio: json['tipo_servicio'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      descripcion: json['descripcion'],
      telefono: json['telefono'],
      email: json['email'],
      imagen: json['imagen'],
      imagenes: json['imagenes'],
      estado: json['estado'] ?? false,
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : null,
      fechaActualizacion: json['fecha_actualizacion'] != null 
          ? DateTime.parse(json['fecha_actualizacion']) 
          : null,
      servicios: json['servicios'] != null 
          ? List<ServicioEmprendedor>.from(
              json['servicios'].map((x) => ServicioEmprendedor.fromJson(x)))
          : null,
      relaciones: json['relaciones'] != null 
          ? List<RelacionEmprendedor>.from(
              json['relaciones'].map((x) => RelacionEmprendedor.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo_servicio': tipoServicio,
      'ubicacion': ubicacion,
      'descripcion': descripcion,
      'telefono': telefono,
      'email': email,
      'imagen': imagen,
      'imagenes': imagenes,
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
      'servicios': servicios?.map((x) => x.toJson()).toList(),
      'relaciones': relaciones?.map((x) => x.toJson()).toList(),
    };
  }
}

class ServicioEmprendedor {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioReferencial;
  final String ubicacionReferencia;
  final int capacidad;
  final bool estado;
  final List<Categoria> categorias;
  final List<Horario> horarios;

  ServicioEmprendedor({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioReferencial,
    required this.ubicacionReferencia,
    required this.capacidad,
    required this.estado,
    required this.categorias,
    required this.horarios,
  });

  factory ServicioEmprendedor.fromJson(Map<String, dynamic> json) {
    return ServicioEmprendedor(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioReferencial: (json['precio_referencial'] ?? 0).toDouble(),
      ubicacionReferencia: json['ubicacion_referencia'] ?? '',
      capacidad: json['capacidad'] ?? 0,
      estado: json['estado'] ?? false,
      categorias: json['categorias'] != null 
          ? List<Categoria>.from(
              json['categorias'].map((x) => Categoria.fromJson(x)))
          : [],
      horarios: json['horarios'] != null 
          ? List<Horario>.from(
              json['horarios'].map((x) => Horario.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_referencial': precioReferencial,
      'ubicacion_referencia': ubicacionReferencia,
      'capacidad': capacidad,
      'estado': estado,
      'categorias': categorias.map((x) => x.toJson()).toList(),
      'horarios': horarios.map((x) => x.toJson()).toList(),
    };
  }
}

class RelacionEmprendedor {
  final int id;
  final String tipo;
  final String valor;
  final DateTime? fechaCreacion;

  RelacionEmprendedor({
    required this.id,
    required this.tipo,
    required this.valor,
    this.fechaCreacion,
  });

  factory RelacionEmprendedor.fromJson(Map<String, dynamic> json) {
    return RelacionEmprendedor(
      id: json['id'] ?? 0,
      tipo: json['tipo'] ?? '',
      valor: json['valor'] ?? '',
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'valor': valor,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }
}

class Categoria {
  final int id;
  final String nombre;
  final String? descripcion;

  Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}

class Horario {
  final int id;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'] ?? 0,
      diaSemana: json['dia_semana'] ?? '',
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
    };
  }
} 