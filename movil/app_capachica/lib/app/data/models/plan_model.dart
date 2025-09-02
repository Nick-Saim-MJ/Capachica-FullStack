class Plan {
  final int id;
  final String titulo;
  final String? descripcion;
  final String? imagenUrl;
  final double? precio;
  final int? duracion; // en días
  final String? ubicacion;
  final bool isPublico;
  final String? categoria;
  final double? rating;
  final int? numResenas;
  final bool isActivo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? servicioId;
  final int? emprendedorId;

  Plan({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.imagenUrl,
    this.precio,
    this.duracion,
    this.ubicacion,
    required this.isPublico,
    this.categoria,
    this.rating,
    this.numResenas,
    required this.isActivo,
    this.createdAt,
    this.updatedAt,
    this.servicioId,
    this.emprendedorId,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      imagenUrl: json['imagen_url'] ?? json['imagenUrl'],
      precio: json['precio']?.toDouble(),
      duracion: json['duracion'],
      ubicacion: json['ubicacion'],
      isPublico: json['is_publico'] ?? json['isPublico'] ?? false,
      categoria: json['categoria'],
      rating: json['rating']?.toDouble(),
      numResenas: json['num_resenas'] ?? json['numResenas'],
      isActivo: json['is_activo'] ?? json['isActivo'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
      servicioId: json['servicio_id'],
      emprendedorId: json['emprendedor_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagen_url': imagenUrl,
      'precio': precio,
      'duracion': duracion,
      'ubicacion': ubicacion,
      'is_publico': isPublico,
      'categoria': categoria,
      'rating': rating,
      'num_resenas': numResenas,
      'is_activo': isActivo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'servicio_id': servicioId,
      'emprendedor_id': emprendedorId,
    };
  }
} 