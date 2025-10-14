// lib/features/municipalidades/domain/entities/municipalidad.dart
class MunicipalidadEntity {
  final int id;
  final String nombre;
  final String descripcion;
  final String? redFacebook;
  final String? redInstagram;
  final String? redYoutube;
  final double? coordenadasX;
  final double? coordenadasY;
  final String? frase;
  final String? comunidades;
  final String? historiaFamilias;
  final String? historiaCapachica;
  final String? comite;
  final String? mision;
  final String? vision;
  final String? valores;
  final String? ordenanzaMunicipal;
  final String? alianzas;
  final String? correo;
  final String? horarioAtencion;

  MunicipalidadEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.redFacebook,
    this.redInstagram,
    this.redYoutube,
    this.coordenadasX,
    this.coordenadasY,
    this.frase,
    this.comunidades,
    this.historiaFamilias,
    this.historiaCapachica,
    this.comite,
    this.mision,
    this.vision,
    this.valores,
    this.ordenanzaMunicipal,
    this.alianzas,
    this.correo,
    this.horarioAtencion,
  });
}

class MunicipalidadModel extends MunicipalidadEntity {
  MunicipalidadModel({
    required int id,
    required String nombre,
    required String descripcion,
    String? redFacebook,
    String? redInstagram,
    String? redYoutube,
    double? coordenadasX,
    double? coordenadasY,
    String? frase,
    String? comunidades,
    String? historiaFamilias,
    String? historiaCapachica,
    String? comite,
    String? mision,
    String? vision,
    String? valores,
    String? ordenanzaMunicipal,
    String? alianzas,
    String? correo,
    String? horarioAtencion,
  }) : super(
    id: id,
    nombre: nombre,
    descripcion: descripcion,
    redFacebook: redFacebook,
    redInstagram: redInstagram,
    redYoutube: redYoutube,
    coordenadasX: coordenadasX,
    coordenadasY: coordenadasY,
    frase: frase,
    comunidades: comunidades,
    historiaFamilias: historiaFamilias,
    historiaCapachica: historiaCapachica,
    comite: comite,
    mision: mision,
    vision: vision,
    valores: valores,
    ordenanzaMunicipal: ordenanzaMunicipal,
    alianzas: alianzas,
    correo: correo,
    horarioAtencion: horarioAtencion,
  );

  factory MunicipalidadModel.fromJson(Map<String, dynamic> json) => MunicipalidadModel(
    id: json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id'].toString()) ?? 0,
    nombre: json['nombre']?.toString() ?? '',
    descripcion: json['descripcion']?.toString() ?? '',
    redFacebook: json['red_facebook']?.toString(),
    redInstagram: json['red_instagram']?.toString(),
    redYoutube: json['red_youtube']?.toString(),

    // Ignoramos coordenadas para evitar errores
    coordenadasX: _parseDouble(
        json['coordenadas_x'] ?? json['coordenadasX']
    ),
    coordenadasY: _parseDouble(
        json['coordenadas_y'] ?? json['coordenadasY']
    ),

    frase: json['frase']?.toString(),
    comunidades: json['comunidades']?.toString(),
    historiaFamilias: json['historiafamilias']?.toString(),
    historiaCapachica: json['historiacapachica']?.toString(),
    comite: json['comite']?.toString(),
    mision: json['mision']?.toString(),
    vision: json['vision']?.toString(),
    valores: json['valores']?.toString(),
    ordenanzaMunicipal: json['ordenanzamunicipal']?.toString(),
    alianzas: json['alianzas']?.toString(),
    correo: json['correo']?.toString(),
    horarioAtencion: json['horariodeatencion']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'red_facebook': redFacebook,
    'red_instagram': redInstagram,
    'red_youtube': redYoutube,
    'coordenadas_x': coordenadasX,
    'coordenadas_y': coordenadasY,
    'frase': frase,
    'comunidades': comunidades,
    'historiafamilias': historiaFamilias,
    'historiacapachica': historiaCapachica,
    'comite': comite,
    'mision': mision,
    'vision': vision,
    'valores': valores,
    'ordenanzamunicipal': ordenanzaMunicipal,
    'alianzas': alianzas,
    'correo': correo,
    'horariodeatencion': horarioAtencion,
  };

  MunicipalidadEntity toEntity() => this;

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}