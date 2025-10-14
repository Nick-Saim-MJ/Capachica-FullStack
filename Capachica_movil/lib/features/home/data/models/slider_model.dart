// lib/features/home/data/models/slider_model.dart

class SliderDescripcionModel {
  final int id;
  final String? titulo;
  final String? descripcion;

  SliderDescripcionModel({
    required this.id,
    this.titulo,
    this.descripcion,
  });

  factory SliderDescripcionModel.fromJson(Map<String, dynamic> json) {
    return SliderDescripcionModel(
      id: json['id'] ?? 0,
      titulo: json['titulo'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() {
    return 'SliderDescripcionModel(id: $id, titulo: $titulo)';
  }
}

class SliderModel {
  final int id;
  final String url;
  final String nombre;
  final bool esPrincipal;
  final String tipoEntidad;
  final int entidadId;
  final int orden;
  final bool activo;
  final SliderDescripcionModel? descripcion;

  SliderModel({
    required this.id,
    required this.url,
    required this.nombre,
    required this.esPrincipal,
    required this.tipoEntidad,
    required this.entidadId,
    required this.orden,
    required this.activo,
    this.descripcion,
  });

  // Método auxiliar para convertir valores booleanos que pueden venir como int
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'],
      url: json['url_completa'] ?? json['url'] ?? '',
      nombre: json['nombre'] ?? '',
      esPrincipal: _parseBool(json['es_principal']),
      tipoEntidad: json['tipo_entidad'] ?? '',
      entidadId: json['entidad_id'] ?? 0,
      orden: json['orden'] ?? 0,
      activo: _parseBool(json['activo']),
      descripcion: json['descripcion'] != null
          ? SliderDescripcionModel.fromJson(json['descripcion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'nombre': nombre,
      'es_principal': esPrincipal,
      'tipo_entidad': tipoEntidad,
      'entidad_id': entidadId,
      'orden': orden,
      'activo': activo,
      'descripcion': descripcion?.toJson(),
    };
  }

  SliderModel copyWith({
    int? id,
    String? url,
    String? nombre,
    bool? esPrincipal,
    String? tipoEntidad,
    int? entidadId,
    int? orden,
    bool? activo,
    SliderDescripcionModel? descripcion,
  }) {
    return SliderModel(
      id: id ?? this.id,
      url: url ?? this.url,
      nombre: nombre ?? this.nombre,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      tipoEntidad: tipoEntidad ?? this.tipoEntidad,
      entidadId: entidadId ?? this.entidadId,
      orden: orden ?? this.orden,
      activo: activo ?? this.activo,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  @override
  String toString() {
    return 'SliderModel(id: $id, nombre: $nombre, url: $url)';
  }
}