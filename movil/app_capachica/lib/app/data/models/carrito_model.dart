import '../../core/utils/case_converter.dart';
import 'servicio_model.dart';

/// Modelo de item del carrito
class CarritoItem {
  final int id;
  final int servicioId;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagenUrl;
  final int cantidad;
  final DateTime? fechaReserva;
  final String? horaReserva;
  final String? notas;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  CarritoItem({
    required this.id,
    required this.servicioId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl,
    required this.cantidad,
    this.fechaReserva,
    this.horaReserva,
    this.notas,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    final caseConverter = CaseConverter();
    
    return CarritoItem(
      id: caseConverter.getValueWithFallback<int>(json, 'id', 'id') ?? 0,
      servicioId: caseConverter.getValueWithFallback<int>(json, 'servicioId', 'servicio_id') ?? 0,
      nombre: caseConverter.getValueWithFallback<String>(json, 'nombre', 'nombre') ?? '',
      descripcion: caseConverter.getValueWithFallback<String>(json, 'descripcion', 'descripcion') ?? '',
      precio: (caseConverter.getValueWithFallback<num>(json, 'precio', 'precio') ?? 0).toDouble(),
      imagenUrl: caseConverter.getValueWithFallback<String>(json, 'imagenUrl', 'imagen_url'),
      cantidad: caseConverter.getValueWithFallback<int>(json, 'cantidad', 'cantidad') ?? 1,
      fechaReserva: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaReserva', 'fecha_reserva')),
      horaReserva: caseConverter.getValueWithFallback<String>(json, 'horaReserva', 'hora_reserva'),
      notas: caseConverter.getValueWithFallback<String>(json, 'notas', 'notas'),
      fechaCreacion: _parseDateTime(caseConverter.getValueWithFallback<String>(json, 'fechaCreacion', 'fecha_creacion')) ?? DateTime.now(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicio_id': servicioId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen_url': imagenUrl,
      'cantidad': cantidad,
      'fecha_reserva': fechaReserva?.toIso8601String(),
      'hora_reserva': horaReserva,
      'notas': notas,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  /// Crear copia con nuevos valores
  CarritoItem copyWith({
    int? id,
    int? servicioId,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    int? cantidad,
    DateTime? fechaReserva,
    String? horaReserva,
    String? notas,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return CarritoItem(
      id: id ?? this.id,
      servicioId: servicioId ?? this.servicioId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      cantidad: cantidad ?? this.cantidad,
      fechaReserva: fechaReserva ?? this.fechaReserva,
      horaReserva: horaReserva ?? this.horaReserva,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  /// Obtener subtotal
  double get subtotal => precio * cantidad;

  /// Obtener subtotal formateado
  String get subtotalFormateado => 'S/ ${subtotal.toStringAsFixed(2)}';

  /// Obtener precio formateado
  String get precioFormateado => 'S/ ${precio.toStringAsFixed(2)}';

  /// Verificar si tiene fecha de reserva
  bool get tieneFechaReserva => fechaReserva != null;

  /// Verificar si tiene hora de reserva
  bool get tieneHoraReserva => horaReserva != null && horaReserva!.isNotEmpty;

  /// Verificar si tiene notas
  bool get tieneNotas => notas != null && notas!.isNotEmpty;

  /// Obtener fecha de reserva formateada
  String? get fechaReservaFormateada {
    if (fechaReserva == null) return null;
    return '${fechaReserva!.day.toString().padLeft(2, '0')}/${fechaReserva!.month.toString().padLeft(2, '0')}/${fechaReserva!.year}';
  }

  /// Obtener información de reserva
  String get infoReserva {
    if (tieneFechaReserva && tieneHoraReserva) {
      return '$fechaReservaFormateada a las $horaReserva';
    } else if (tieneFechaReserva) {
      return fechaReservaFormateada!;
    } else if (tieneHoraReserva) {
      return 'A las $horaReserva';
    } else {
      return 'Sin fecha específica';
    }
  }

  /// Crear desde servicio
  factory CarritoItem.fromServicio(
    Servicio servicio, {
    int cantidad = 1,
    DateTime? fechaReserva,
    String? horaReserva,
    String? notas,
  }) {
    return CarritoItem(
      id: 0, // Se asignará al guardar
      servicioId: servicio.id,
      nombre: servicio.nombre,
      descripcion: servicio.descripcion,
      precio: servicio.precio,
      imagenUrl: servicio.imagenPrincipal,
      cantidad: cantidad,
      fechaReserva: fechaReserva,
      horaReserva: horaReserva,
      notas: notas,
      fechaCreacion: DateTime.now(),
    );
  }
}

/// Modelo de respuesta del carrito
class CarritoResponse {
  final List<CarritoItem> items;
  final double subtotal;
  final double total;
  final int totalItems;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  CarritoResponse({
    required this.items,
    required this.subtotal,
    required this.total,
    required this.totalItems,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory CarritoResponse.fromJson(Map<String, dynamic> json) {
    final caseConverter = CaseConverter();
    
    final itemsJson = caseConverter.getValueWithFallback<List<dynamic>>(json, 'items', 'items') ?? [];
    final items = itemsJson.map((x) => CarritoItem.fromJson(x)).toList();
    
    return CarritoResponse(
      items: items,
      subtotal: (caseConverter.getValueWithFallback<num>(json, 'subtotal', 'subtotal') ?? 0).toDouble(),
      total: (caseConverter.getValueWithFallback<num>(json, 'total', 'total') ?? 0).toDouble(),
      totalItems: caseConverter.getValueWithFallback<int>(json, 'totalItems', 'total_items') ?? items.length,
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

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((x) => x.toJson()).toList(),
      'subtotal': subtotal,
      'total': total,
      'total_items': totalItems,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  /// Crear copia con nuevos valores
  CarritoResponse copyWith({
    List<CarritoItem>? items,
    double? subtotal,
    double? total,
    int? totalItems,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return CarritoResponse(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      totalItems: totalItems ?? this.totalItems,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  /// Verificar si el carrito está vacío
  bool get estaVacio => items.isEmpty;

  /// Obtener subtotal formateado
  String get subtotalFormateado => 'S/ ${subtotal.toStringAsFixed(2)}';

  /// Obtener total formateado
  String get totalFormateado => 'S/ ${total.toStringAsFixed(2)}';

  /// Obtener información de items
  String get infoItems {
    if (totalItems == 0) {
      return 'Carrito vacío';
    } else if (totalItems == 1) {
      return '1 servicio';
    } else {
      return '$totalItems servicios';
    }
  }

  /// Calcular totales
  CarritoResponse calcularTotales() {
    final subtotalCalculado = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final totalCalculado = subtotalCalculado; // Aquí se podrían agregar impuestos, descuentos, etc.
    final totalItemsCalculado = items.fold<int>(0, (sum, item) => sum + item.cantidad);
    
    return copyWith(
      subtotal: subtotalCalculado,
      total: totalCalculado,
      totalItems: totalItemsCalculado,
    );
  }

  /// Agregar item al carrito
  CarritoResponse agregarItem(CarritoItem nuevoItem) {
    final itemsActualizados = List<CarritoItem>.from(items);
    
    // Verificar si ya existe un item con el mismo servicio
    final indiceExistente = itemsActualizados.indexWhere((item) => item.servicioId == nuevoItem.servicioId);
    
    if (indiceExistente >= 0) {
      // Actualizar cantidad del item existente
      itemsActualizados[indiceExistente] = itemsActualizados[indiceExistente].copyWith(
        cantidad: itemsActualizados[indiceExistente].cantidad + nuevoItem.cantidad,
        fechaActualizacion: DateTime.now(),
      );
    } else {
      // Agregar nuevo item
      itemsActualizados.add(nuevoItem);
    }
    
    return CarritoResponse(
      items: itemsActualizados,
      subtotal: 0, // Se calculará
      total: 0, // Se calculará
      totalItems: 0, // Se calculará
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
    ).calcularTotales();
  }

  /// Remover item del carrito
  CarritoResponse removerItem(int servicioId) {
    final itemsActualizados = items.where((item) => item.servicioId != servicioId).toList();
    
    return CarritoResponse(
      items: itemsActualizados,
      subtotal: 0, // Se calculará
      total: 0, // Se calculará
      totalItems: 0, // Se calculará
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
    ).calcularTotales();
  }

  /// Actualizar cantidad de un item
  CarritoResponse actualizarCantidad(int servicioId, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      return removerItem(servicioId);
    }
    
    final itemsActualizados = items.map((item) {
      if (item.servicioId == servicioId) {
        return item.copyWith(
          cantidad: nuevaCantidad,
          fechaActualizacion: DateTime.now(),
        );
      }
      return item;
    }).toList();
    
    return CarritoResponse(
      items: itemsActualizados,
      subtotal: 0, // Se calculará
      total: 0, // Se calculará
      totalItems: 0, // Se calculará
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
    ).calcularTotales();
  }

  /// Limpiar carrito
  CarritoResponse limpiar() {
    return CarritoResponse(
      items: [],
      subtotal: 0,
      total: 0,
      totalItems: 0,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
    );
  }
}
