import '../../core/utils/case_converter.dart';

/// Modelo de Servicio con normalización camelCase
class Servicio {
  final int id;
  final int emprendedorId;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagenUrl;
  final String categoria;
  final bool disponible;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? horaInicio;
  final String? horaFin;
  final int? capacidad;
  final String? ubicacion;
  final List<String>? imagenes;
  final List<ServicioHorario>? horarios;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Servicio({
    required this.id,
    required this.emprendedorId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl,
    required this.categoria,
    this.disponible = true,
    this.fechaInicio,
    this.fechaFin,
    this.horaInicio,
    this.horaFin,
    this.capacidad,
    this.ubicacion,
    this.imagenes,
    this.horarios,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    final caseConverter = CaseConverter();
    
    return Servicio(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      emprendedorId: caseConverter.getValueWithFallback<int>(json, 'emprendedorId', 'emprendedor_id') ?? 0,
      nombre: caseConverter.getValueWithFallback<String>(json, 'nombre', 'nombre') ?? '',
      descripcion: caseConverter.getValueWithFallback<String>(json, 'descripcion', 'descripcion') ?? '',
      precio: (caseConverter.getValueWithFallback<num>(json, 'precio', 'precio') ?? 0).toDouble(),
      imagenUrl: caseConverter.getValueWithFallback<String>(json, 'imagenUrl', 'imagen_url'),
      categoria: caseConverter.getValueWithFallback<String>(json, 'categoria', 'categoria') ?? '',
      disponible: caseConverter.getValueWithFallback<bool>(json, 'disponible', 'disponible') ?? true,
      fechaInicio: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaInicio', 'fecha_inicio')),
      fechaFin: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaFin', 'fecha_fin')),
      horaInicio: caseConverter.getValueWithFallback<String>(json, 'horaInicio', 'hora_inicio'),
      horaFin: caseConverter.getValueWithFallback<String>(json, 'horaFin', 'hora_fin'),
      capacidad: caseConverter.getValueWithFallback<int>(json, 'capacidad', 'capacidad'),
      ubicacion: caseConverter.getValueWithFallback<String>(json, 'ubicacion', 'ubicacion'),
      imagenes: _parseImagenes(caseConverter.getValueWithFallback<List<dynamic>>(json, 'imagenes', 'imagenes')),
      horarios: _parseHorarios(caseConverter.getValueWithFallback<List<dynamic>>(json, 'horarios', 'horarios')),
      fechaCreacion: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaCreacion', 'fecha_creacion')),
      fechaActualizacion: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaActualizacion', 'fecha_actualizacion')),
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

  static List<String>? _parseImagenes(List<dynamic>? imagenesJson) {
    if (imagenesJson == null) return null;
    return imagenesJson.map((x) => x.toString()).toList();
  }

  static List<ServicioHorario>? _parseHorarios(List<dynamic>? horariosJson) {
    if (horariosJson == null) return null;
    return horariosJson.map((x) => ServicioHorario.fromJson(x)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emprendedor_id': emprendedorId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen_url': imagenUrl,
      'categoria': categoria,
      'disponible': disponible,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'capacidad': capacidad,
      'ubicacion': ubicacion,
      'imagenes': imagenes,
      'horarios': horarios?.map((x) => x.toJson()).toList(),
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  /// Crear copia con nuevos valores
  Servicio copyWith({
    int? id,
    int? emprendedorId,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    String? categoria,
    bool? disponible,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? horaInicio,
    String? horaFin,
    int? capacidad,
    String? ubicacion,
    List<String>? imagenes,
    List<ServicioHorario>? horarios,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Servicio(
      id: id ?? this.id,
      emprendedorId: emprendedorId ?? this.emprendedorId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      categoria: categoria ?? this.categoria,
      disponible: disponible ?? this.disponible,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      capacidad: capacidad ?? this.capacidad,
      ubicacion: ubicacion ?? this.ubicacion,
      imagenes: imagenes ?? this.imagenes,
      horarios: horarios ?? this.horarios,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  /// Obtener imagen principal
  String? get imagenPrincipal => imagenUrl ?? (imagenes?.isNotEmpty == true ? imagenes!.first : null);

  /// Obtener precio formateado
  String get precioFormateado => 'S/ ${precio.toStringAsFixed(2)}';

  /// Verificar si tiene horarios
  bool get tieneHorarios => horarios != null && horarios!.isNotEmpty;

  /// Verificar si tiene imágenes
  bool get tieneImagenes => imagenes != null && imagenes!.isNotEmpty;

  /// Verificar si tiene capacidad limitada
  bool get tieneCapacidadLimitada => capacidad != null && capacidad! > 0;

  /// Verificar si tiene fechas específicas
  bool get tieneFechasEspecificas => fechaInicio != null || fechaFin != null;

  /// Verificar si tiene horarios específicos
  bool get tieneHorariosEspecificos => horaInicio != null || horaFin != null;

  /// Obtener duración estimada
  String? get duracionEstimada {
    if (horaInicio == null || horaFin == null) return null;
    
    try {
      final inicio = _parseTime(horaInicio!);
      final fin = _parseTime(horaFin!);
      final duracion = fin.difference(inicio);
      
      if (duracion.inHours > 0) {
        return '${duracion.inHours}h ${duracion.inMinutes % 60}m';
      } else {
        return '${duracion.inMinutes}m';
      }
    } catch (e) {
      return null;
    }
  }

  /// Parsear tiempo desde string HH:MM
  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) throw FormatException('Invalid time format');
    
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(2024, 1, 1, hour, minute);
  }

  /// Verificar si está disponible en una fecha específica
  bool estaDisponibleEnFecha(DateTime fecha) {
    if (!disponible) return false;
    
    if (fechaInicio != null && fecha.isBefore(fechaInicio!)) return false;
    if (fechaFin != null && fecha.isAfter(fechaFin!)) return false;
    
    return true;
  }

  /// Verificar si está disponible en un horario específico
  bool estaDisponibleEnHorario(String hora) {
    if (!disponible) return false;
    if (horaInicio == null || horaFin == null) return true;
    
    try {
      final horaSolicitada = _parseTime(hora);
      final inicio = _parseTime(horaInicio!);
      final fin = _parseTime(horaFin!);
      
      return horaSolicitada.isAfter(inicio) && horaSolicitada.isBefore(fin);
    } catch (e) {
      return false;
    }
  }
}

/// Modelo de horario de servicio
class ServicioHorario {
  final int id;
  final int servicioId;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool activo;

  ServicioHorario({
    required this.id,
    required this.servicioId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    this.activo = true,
  });

  factory ServicioHorario.fromJson(Map<String, dynamic> json) {
    final caseConverter = CaseConverter();
    
    return ServicioHorario(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      servicioId: caseConverter.getValueWithFallback<int>(json, 'servicioId', 'servicio_id') ?? 0,
      diaSemana: caseConverter.getValueWithFallback<String>(json, 'diaSemana', 'dia_semana') ?? '',
      horaInicio: caseConverter.getValueWithFallback<String>(json, 'horaInicio', 'hora_inicio') ?? '',
      horaFin: caseConverter.getValueWithFallback<String>(json, 'horaFin', 'hora_fin') ?? '',
      activo: caseConverter.getValueWithFallback<bool>(json, 'activo', 'activo') ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicio_id': servicioId,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'activo': activo,
    };
  }

  /// Crear copia con nuevos valores
  ServicioHorario copyWith({
    int? id,
    int? servicioId,
    String? diaSemana,
    String? horaInicio,
    String? horaFin,
    bool? activo,
  }) {
    return ServicioHorario(
      id: id ?? this.id,
      servicioId: servicioId ?? this.servicioId,
      diaSemana: diaSemana ?? this.diaSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      activo: activo ?? this.activo,
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