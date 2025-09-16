import '../../core/utils/case_converter.dart';

/// Modelo resumido de Emprendedor para listas
class EmprendedorResumen {
  final int id;
  final String nombre;
  final String tipoServicio;
  final String ubicacion;
  final String? descripcion;
  final String? telefono;
  final String? email;
  final String? imagen;
  final bool estado;
  final DateTime? fechaCreacion;
  final int? totalServicios;
  final double? precioMinimo;

  EmprendedorResumen({
    required this.id,
    required this.nombre,
    required this.tipoServicio,
    required this.ubicacion,
    this.descripcion,
    this.telefono,
    this.email,
    this.imagen,
    required this.estado,
    this.fechaCreacion,
    this.totalServicios,
    this.precioMinimo,
  });

  factory EmprendedorResumen.fromJson(Map<String, dynamic> json) {
    final caseConverter = CaseConverter();
    
    return EmprendedorResumen(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      nombre: caseConverter.getValueWithFallback<String>(json, 'nombre', 'nombre') ?? '',
      tipoServicio: caseConverter.getValueWithFallback<String>(json, 'tipoServicio', 'tipo_servicio') ?? '',
      ubicacion: caseConverter.getValueWithFallback<String>(json, 'ubicacion', 'ubicacion') ?? '',
      descripcion: caseConverter.getValueWithFallback<String>(json, 'descripcion', 'descripcion'),
      telefono: caseConverter.getValueWithFallback<String>(json, 'telefono', 'telefono'),
      email: caseConverter.getValueWithFallback<String>(json, 'email', 'email'),
      imagen: caseConverter.getValueWithFallback<String>(json, 'imagen', 'imagen'),
      estado: caseConverter.getValueWithFallback<bool>(json, 'estado', 'estado') ?? false,
      fechaCreacion: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaCreacion', 'fecha_creacion')),
      totalServicios: caseConverter.getValueWithFallback<int>(json, 'totalServicios', 'total_servicios'),
      precioMinimo: caseConverter.getValueWithFallback<double>(json, 'precioMinimo', 'precio_minimo'),
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
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'total_servicios': totalServicios,
      'precio_minimo': precioMinimo,
    };
  }

  /// Crear copia con nuevos valores
  EmprendedorResumen copyWith({
    int? id,
    String? nombre,
    String? tipoServicio,
    String? ubicacion,
    String? descripcion,
    String? telefono,
    String? email,
    String? imagen,
    bool? estado,
    DateTime? fechaCreacion,
    int? totalServicios,
    double? precioMinimo,
  }) {
    return EmprendedorResumen(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      ubicacion: ubicacion ?? this.ubicacion,
      descripcion: descripcion ?? this.descripcion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      imagen: imagen ?? this.imagen,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      totalServicios: totalServicios ?? this.totalServicios,
      precioMinimo: precioMinimo ?? this.precioMinimo,
    );
  }

  /// Obtener imagen principal
  String? get imagenPrincipal => imagen;

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

  /// Obtener precio mínimo formateado
  String? get precioMinimoFormateado {
    if (precioMinimo == null) return null;
    return 'S/ ${precioMinimo!.toStringAsFixed(2)}';
  }

  /// Obtener descripción truncada
  String get descripcionTruncada {
    if (descripcion == null || descripcion!.isEmpty) return '';
    if (descripcion!.length <= 100) return descripcion!;
    return '${descripcion!.substring(0, 100)}...';
  }

  /// Verificar si tiene servicios
  bool get tieneServicios => totalServicios != null && totalServicios! > 0;

  /// Verificar si tiene precio mínimo
  bool get tienePrecioMinimo => precioMinimo != null && precioMinimo! > 0;

  /// Obtener información de servicios
  String get infoServicios {
    if (totalServicios == null || totalServicios! == 0) {
      return 'Sin servicios';
    } else if (totalServicios! == 1) {
      return '1 servicio';
    } else {
      return '$totalServicios servicios';
    }
  }

  /// Convertir a Emprendedor completo (para compatibilidad)
  Map<String, dynamic> toEmprendedorJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo_servicio': tipoServicio,
      'ubicacion': ubicacion,
      'descripcion': descripcion,
      'telefono': telefono,
      'email': email,
      'imagen': imagen,
      'imagenes': imagen,
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaCreacion?.toIso8601String(),
      'servicios': [],
      'relaciones': [],
    };
  }
}
