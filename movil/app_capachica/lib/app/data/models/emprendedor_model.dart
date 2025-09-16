import '../../core/utils/case_converter.dart';

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
    final caseConverter = CaseConverter();
    
    return Emprendedor(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      nombre: caseConverter.getValueWithFallback<String>(json, 'nombre', 'nombre') ?? '',
      tipoServicio: caseConverter.getValueWithFallback<String>(json, 'tipoServicio', 'tipo_servicio') ?? '',
      ubicacion: caseConverter.getValueWithFallback<String>(json, 'ubicacion', 'ubicacion') ?? '',
      descripcion: caseConverter.getValueWithFallback<String>(json, 'descripcion', 'descripcion'),
      telefono: caseConverter.getValueWithFallback<String>(json, 'telefono', 'telefono'),
      email: caseConverter.getValueWithFallback<String>(json, 'email', 'email'),
      imagen: caseConverter.getValueWithFallback<String>(json, 'imagen', 'imagen'),
      imagenes: caseConverter.getValueWithFallback<String>(json, 'imagenes', 'imagenes'),
      estado: caseConverter.getValueWithFallback<bool>(json, 'estado', 'estado') ?? false,
      fechaCreacion: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaCreacion', 'fecha_creacion')),
      fechaActualizacion: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaActualizacion', 'fecha_actualizacion')),
      servicios: _parseServicios(caseConverter.getValueWithFallback<List<dynamic>>(json, 'servicios', 'servicios')),
      relaciones: _parseRelaciones(caseConverter.getValueWithFallback<List<dynamic>>(json, 'relaciones', 'relaciones')),
    );
  }

  static DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static List<ServicioEmprendedor>? _parseServicios(List<dynamic>? serviciosJson) {
    if (serviciosJson == null) return null;
    return serviciosJson.map((x) => ServicioEmprendedor.fromJson(x)).toList();
  }

  static List<RelacionEmprendedor>? _parseRelaciones(List<dynamic>? relacionesJson) {
    if (relacionesJson == null) return null;
    return relacionesJson.map((x) => RelacionEmprendedor.fromJson(x)).toList();
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

  /// Crear copia con nuevos valores
  Emprendedor copyWith({
    int? id,
    String? nombre,
    String? tipoServicio,
    String? ubicacion,
    String? descripcion,
    String? telefono,
    String? email,
    String? imagen,
    String? imagenes,
    bool? estado,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    List<ServicioEmprendedor>? servicios,
    List<RelacionEmprendedor>? relaciones,
  }) {
    return Emprendedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      ubicacion: ubicacion ?? this.ubicacion,
      descripcion: descripcion ?? this.descripcion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      imagen: imagen ?? this.imagen,
      imagenes: imagenes ?? this.imagenes,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      servicios: servicios ?? this.servicios,
      relaciones: relaciones ?? this.relaciones,
    );
  }

  /// Obtener imagen principal
  String? get imagenPrincipal => imagen ?? imagenes;

  /// Verificar si tiene servicios
  bool get tieneServicios => servicios != null && servicios!.isNotEmpty;

  /// Verificar si tiene relaciones
  bool get tieneRelaciones => relaciones != null && relaciones!.isNotEmpty;

  /// Obtener teléfono formateado
  String? get telefonoFormateado {
    if (telefono == null || telefono!.isEmpty) return null;
    // Formato básico para números peruanos
    final cleanPhone = telefono!.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length == 9) {
      return '${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    }
    return telefono;
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
    final caseConverter = CaseConverter();
    
    return ServicioEmprendedor(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      nombre: caseConverter.getValueWithFallback<String>(json, 'nombre', 'nombre') ?? '',
      descripcion: caseConverter.getValueWithFallback<String>(json, 'descripcion', 'descripcion') ?? '',
      precioReferencial: (caseConverter.getValueWithFallback<num>(json, 'precioReferencial', 'precio_referencial') ?? 0).toDouble(),
      ubicacionReferencia: caseConverter.getValueWithFallback<String>(json, 'ubicacionReferencia', 'ubicacion_referencia') ?? '',
      capacidad: caseConverter.getValueWithFallback<int>(json, 'capacidad', 'capacidad') ?? 0,
      estado: caseConverter.getValueWithFallback<bool>(json, 'estado', 'estado') ?? false,
      categorias: _parseCategorias(caseConverter.getValueWithFallback<List<dynamic>>(json, 'categorias', 'categorias')),
      horarios: _parseHorarios(caseConverter.getValueWithFallback<List<dynamic>>(json, 'horarios', 'horarios')),
    );
  }

  static List<Categoria> _parseCategorias(List<dynamic>? categoriasJson) {
    if (categoriasJson == null) return [];
    return categoriasJson.map((x) => Categoria.fromJson(x)).toList();
  }

  static List<Horario> _parseHorarios(List<dynamic>? horariosJson) {
    if (horariosJson == null) return [];
    return horariosJson.map((x) => Horario.fromJson(x)).toList();
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

  /// Crear copia con nuevos valores
  ServicioEmprendedor copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precioReferencial,
    String? ubicacionReferencia,
    int? capacidad,
    bool? estado,
    List<Categoria>? categorias,
    List<Horario>? horarios,
  }) {
    return ServicioEmprendedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioReferencial: precioReferencial ?? this.precioReferencial,
      ubicacionReferencia: ubicacionReferencia ?? this.ubicacionReferencia,
      capacidad: capacidad ?? this.capacidad,
      estado: estado ?? this.estado,
      categorias: categorias ?? this.categorias,
      horarios: horarios ?? this.horarios,
    );
  }

  /// Obtener precio formateado
  String get precioFormateado => 'S/ ${precioReferencial.toStringAsFixed(2)}';

  /// Verificar si tiene categorías
  bool get tieneCategorias => categorias.isNotEmpty;

  /// Verificar si tiene horarios
  bool get tieneHorarios => horarios.isNotEmpty;
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
    final caseConverter = CaseConverter();
    
    return RelacionEmprendedor(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      tipo: caseConverter.getValueWithFallback<String>(json, 'tipo', 'tipo') ?? '',
      valor: caseConverter.getValueWithFallback<String>(json, 'valor', 'valor') ?? '',
      fechaCreacion: Emprendedor._parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaCreacion', 'fecha_creacion')),
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

  /// Crear copia con nuevos valores
  RelacionEmprendedor copyWith({
    int? id,
    String? tipo,
    String? valor,
    DateTime? fechaCreacion,
  }) {
    return RelacionEmprendedor(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  /// Verificar si es una relación de contacto
  bool get esContacto => tipo.toLowerCase().contains('contacto') || 
                        tipo.toLowerCase().contains('telefono') ||
                        tipo.toLowerCase().contains('email');

  /// Verificar si es una relación social
  bool get esSocial => tipo.toLowerCase().contains('facebook') ||
                      tipo.toLowerCase().contains('instagram') ||
                      tipo.toLowerCase().contains('whatsapp') ||
                      tipo.toLowerCase().contains('web');
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
    final caseConverter = CaseConverter();
    
    return Categoria(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      nombre: caseConverter.getValueWithFallback<String>(json, 'nombre', 'nombre') ?? '',
      descripcion: caseConverter.getValueWithFallback<String>(json, 'descripcion', 'descripcion'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  /// Crear copia con nuevos valores
  Categoria copyWith({
    int? id,
    String? nombre,
    String? descripcion,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
    );
  }

  /// Verificar si tiene descripción
  bool get tieneDescripcion => descripcion != null && descripcion!.isNotEmpty;
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
    final caseConverter = CaseConverter();
    
    return Horario(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      diaSemana: caseConverter.getValueWithFallback<String>(json, 'diaSemana', 'dia_semana') ?? '',
      horaInicio: caseConverter.getValueWithFallback<String>(json, 'horaInicio', 'hora_inicio') ?? '',
      horaFin: caseConverter.getValueWithFallback<String>(json, 'horaFin', 'hora_fin') ?? '',
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

  /// Crear copia con nuevos valores
  Horario copyWith({
    int? id,
    String? diaSemana,
    String? horaInicio,
    String? horaFin,
  }) {
    return Horario(
      id: id ?? this.id,
      diaSemana: diaSemana ?? this.diaSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
    );
  }

  /// Obtener horario formateado
  String get horarioFormateado => '$horaInicio - $horaFin';

  /// Verificar si el horario cruza medianoche
  bool get cruzaMedianoche {
    try {
      final inicio = _parseTime(horaInicio);
      final fin = _parseTime(horaFin);
      return fin.isBefore(inicio);
    } catch (e) {
      return false;
    }
  }

  /// Ajustar hora fin si cruza medianoche
  String get horaFinAjustada {
    if (cruzaMedianoche) {
      try {
        final fin = _parseTime(horaFin);
        final finAjustada = fin.add(Duration(days: 1));
        return '${finAjustada.hour.toString().padLeft(2, '0')}:${finAjustada.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return horaFin;
      }
    }
    return horaFin;
  }

  /// Parsear tiempo desde string HH:MM
  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) throw FormatException('Invalid time format');
    
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(2024, 1, 1, hour, minute);
  }

  /// Verificar si está abierto en un día específico
  bool estaAbiertoEnDia(String dia) {
    return diaSemana.toLowerCase() == dia.toLowerCase();
  }
} 