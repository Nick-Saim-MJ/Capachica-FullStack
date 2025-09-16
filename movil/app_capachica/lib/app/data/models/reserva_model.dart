class ReservaModel {
  final int id;
  final int servicioId;
  final int emprendedorId;
  final String fechaInicio;
  final String fechaFin;
  final String horaInicio;
  final String horaFin;
  final int duracionMinutos;
  final int cantidad;
  final String? notasCliente;
  final String estado;
  final String? metodoPago;
  final double precioTotal;
  final DateTime createdAt;
  final ServicioReserva? servicio;
  final EmprendedorReserva? emprendedor;

  ReservaModel({
    required this.id,
    required this.servicioId,
    required this.emprendedorId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionMinutos,
    required this.cantidad,
    this.notasCliente,
    required this.estado,
    this.metodoPago,
    required this.precioTotal,
    required this.createdAt,
    this.servicio,
    this.emprendedor,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: json['id'] ?? 0,
      servicioId: json['servicio_id'] ?? 0,
      emprendedorId: json['emprendedor_id'] ?? 0,
      fechaInicio: json['fecha_inicio'] ?? '',
      fechaFin: json['fecha_fin'] ?? '',
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      duracionMinutos: json['duracion_minutos'] ?? 0,
      cantidad: json['cantidad'] ?? 1,
      notasCliente: json['notas_cliente'],
      estado: json['estado'] ?? 'pendiente',
      metodoPago: json['metodo_pago'],
      precioTotal: (json['precio_total'] ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      servicio: json['servicio'] != null ? ServicioReserva.fromJson(json['servicio']) : null,
      emprendedor: json['emprendedor'] != null ? EmprendedorReserva.fromJson(json['emprendedor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicio_id': servicioId,
      'emprendedor_id': emprendedorId,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'duracion_minutos': duracionMinutos,
      'cantidad': cantidad,
      'notas_cliente': notasCliente,
      'estado': estado,
      'metodo_pago': metodoPago,
      'precio_total': precioTotal,
      'created_at': createdAt.toIso8601String(),
      'servicio': servicio?.toJson(),
      'emprendedor': emprendedor?.toJson(),
    };
  }
}

class ServicioReserva {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioReferencial;
  final String? imagenUrl;

  ServicioReserva({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioReferencial,
    this.imagenUrl,
  });

  factory ServicioReserva.fromJson(Map<String, dynamic> json) {
    return ServicioReserva(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioReferencial: (json['precio_referencial'] ?? 0.0).toDouble(),
      imagenUrl: json['imagen_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio_referencial': precioReferencial,
      'imagen_url': imagenUrl,
    };
  }
}

class EmprendedorReserva {
  final int id;
  final String nombre;
  final String tipoServicio;

  EmprendedorReserva({
    required this.id,
    required this.nombre,
    required this.tipoServicio,
  });

  factory EmprendedorReserva.fromJson(Map<String, dynamic> json) {
    return EmprendedorReserva(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      tipoServicio: json['tipo_servicio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo_servicio': tipoServicio,
    };
  }
}

// Modelo para agregar al carrito
class AgregarAlCarritoRequest {
  final int servicioId;
  final int emprendedorId;
  final String fechaInicio;
  final String fechaFin;
  final String horaInicio;
  final String horaFin;
  final int duracionMinutos;
  final int cantidad;
  final String? notasCliente;

  AgregarAlCarritoRequest({
    required this.servicioId,
    required this.emprendedorId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionMinutos,
    required this.cantidad,
    this.notasCliente,
  });

  Map<String, dynamic> toJson() {
    return {
      'servicio_id': servicioId,
      'emprendedor_id': emprendedorId,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'duracion_minutos': duracionMinutos,
      'cantidad': cantidad,
      if (notasCliente != null) 'notas_cliente': notasCliente,
    };
  }
}

// Modelo para confirmar reserva
class ConfirmarReservaRequest {
  final String? notas;
  final String metodoPago;

  ConfirmarReservaRequest({
    this.notas,
    required this.metodoPago,
  });

  Map<String, dynamic> toJson() {
    return {
      if (notas != null) 'notas': notas,
      'metodo_pago': metodoPago,
    };
  }
}

// Respuesta del carrito
class CarritoResponse {
  final List<ReservaModel> items;
  final double total;
  final int cantidadItems;

  CarritoResponse({
    required this.items,
    required this.total,
    required this.cantidadItems,
  });

  factory CarritoResponse.fromJson(Map<String, dynamic> json) {
    return CarritoResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => ReservaModel.fromJson(item))
          .toList() ?? [],
      total: (json['total'] ?? 0.0).toDouble(),
      cantidadItems: json['cantidad_items'] ?? 0,
    );
  }
} 