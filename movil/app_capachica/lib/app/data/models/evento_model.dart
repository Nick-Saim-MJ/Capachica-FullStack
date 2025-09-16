class Evento {
  final int id;
  final String titulo;
  final String descripcion;
  final String fecha;
  final String hora;
  final String ubicacion;
  final String? imagenUrl;
  final int emprendedorId;
  final String emprendedorNombre;
  final String? emprendedorImagen;
  final bool isActivo;
  final bool isProximo;
  final String? categoria;
  final double? precio;
  final int? capacidadMaxima;
  final String? estado;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.ubicacion,
    this.imagenUrl,
    required this.emprendedorId,
    required this.emprendedorNombre,
    this.emprendedorImagen,
    required this.isActivo,
    required this.isProximo,
    this.categoria,
    this.precio,
    this.capacidadMaxima,
    this.estado,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      imagenUrl: json['imagen_url'],
      emprendedorId: json['emprendedor_id'] ?? 0,
      emprendedorNombre: json['emprendedor_nombre'] ?? '',
      emprendedorImagen: json['emprendedor_imagen'],
      isActivo: json['is_activo'] ?? false,
      isProximo: json['is_proximo'] ?? false,
      categoria: json['categoria'],
      precio: json['precio']?.toDouble(),
      capacidadMaxima: json['capacidad_maxima'],
      estado: json['estado'],
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.tryParse(json['fecha_creacion']) 
          : null,
      fechaActualizacion: json['fecha_actualizacion'] != null 
          ? DateTime.tryParse(json['fecha_actualizacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha,
      'hora': hora,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'emprendedor_id': emprendedorId,
      'emprendedor_nombre': emprendedorNombre,
      'emprendedor_imagen': emprendedorImagen,
      'is_activo': isActivo,
      'is_proximo': isProximo,
      'categoria': categoria,
      'precio': precio,
      'capacidad_maxima': capacidadMaxima,
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  Evento copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? fecha,
    String? hora,
    String? ubicacion,
    String? imagenUrl,
    int? emprendedorId,
    String? emprendedorNombre,
    String? emprendedorImagen,
    bool? isActivo,
    bool? isProximo,
    String? categoria,
    double? precio,
    int? capacidadMaxima,
    String? estado,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Evento(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      ubicacion: ubicacion ?? this.ubicacion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      emprendedorId: emprendedorId ?? this.emprendedorId,
      emprendedorNombre: emprendedorNombre ?? this.emprendedorNombre,
      emprendedorImagen: emprendedorImagen ?? this.emprendedorImagen,
      isActivo: isActivo ?? this.isActivo,
      isProximo: isProximo ?? this.isProximo,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return 'Evento(id: $id, titulo: $titulo, fecha: $fecha, emprendedor: $emprendedorNombre)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Evento && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 