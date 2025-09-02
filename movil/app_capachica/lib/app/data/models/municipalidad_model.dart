import 'slider_model.dart';

class Municipalidad {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? redFacebook;
  final String? redInstagram;
  final String? redYoutube;
  final String? coordenadasX;
  final String? coordenadasY;
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
  final String? horarioDeAtencion;
  final List<Slider> slidersPrincipales;
  final List<Slider> slidersSecundarios;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Municipalidad({
    required this.id,
    required this.nombre,
    this.descripcion,
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
    this.horarioDeAtencion,
    this.slidersPrincipales = const [],
    this.slidersSecundarios = const [],
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Municipalidad.fromJson(Map<String, dynamic> json) {
    return Municipalidad(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      redFacebook: json['red_facebook'],
      redInstagram: json['red_instagram'],
      redYoutube: json['red_youtube'],
      coordenadasX: json['coordenadas_x'],
      coordenadasY: json['coordenadas_y'],
      frase: json['frase'],
      comunidades: json['comunidades'],
      historiaFamilias: json['historiafamilias'],
      historiaCapachica: json['historiacapachica'],
      comite: json['comite'],
      mision: json['mision'],
      vision: json['vision'],
      valores: json['valores'],
      ordenanzaMunicipal: json['ordenanzamunicipal'],
      alianzas: json['alianzas'],
      correo: json['correo'],
      horarioDeAtencion: json['horariodeatencion'],
      slidersPrincipales: (json['sliders_principales'] as List<dynamic>?)?.map((e) => Slider.fromJson(e)).toList() ?? [],
      slidersSecundarios: (json['sliders_secundarios'] as List<dynamic>?)?.map((e) => Slider.fromJson(e)).toList() ?? [],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'horariodeatencion': horarioDeAtencion,
      'sliders_principales': slidersPrincipales.map((e) => e.toJson()).toList(),
      'sliders_secundarios': slidersSecundarios.map((e) => e.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 