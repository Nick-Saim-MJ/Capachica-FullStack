class ServicioModel {
  final String id;
  final String emprendedorId;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;
  final bool disponible;

  ServicioModel({
    required this.id,
    required this.emprendedorId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
    this.disponible = true,
  });

  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: json['id'] as String,
      emprendedorId: json['emprendedorId'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagenUrl'] as String,
      categoria: json['categoria'] as String,
      disponible: json['disponible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emprendedorId': emprendedorId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoria': categoria,
      'disponible': disponible,
    };
  }
} 