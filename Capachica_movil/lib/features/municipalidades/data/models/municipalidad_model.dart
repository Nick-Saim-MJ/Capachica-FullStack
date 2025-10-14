import '../../domain/entities/municipalidad.dart';

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

  factory MunicipalidadModel.fromJson(Map<String, dynamic> json) {
    print('✅ JSON recibido en MunicipalidadModel: $json');
    return MunicipalidadModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      redFacebook: json['red_facebook']?.toString(),
      redInstagram: json['red_instagram']?.toString(),
      redYoutube: json['red_youtube']?.toString(),

      coordenadasX: _parseDouble(
          json['coordenadas_x'] ?? json['coordenadasX'] ?? json['lat'] ?? json['x']
      ),
      coordenadasY: _parseDouble(
          json['coordenadas_y'] ?? json['coordenadasY'] ?? json['lng'] ?? json['y']
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
  }


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

  @override
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
