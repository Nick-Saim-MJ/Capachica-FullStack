import 'package:flutter/foundation.dart';

import '../data/models/carrito_model.dart';
import '../data/models/servicio_model.dart';
import '../core/config/app_config.dart';
import '../core/compatibility/api_client.dart';
import '../core/cache/cache_service.dart';
import '../core/services/base_service.dart';

class CarritoService extends BaseService {
  final _httpClient = CompatibilityApiClient.instance;
  final _cacheService = CacheService.instance;

  // GET /api/reservas/carrito - Obtener carrito actual
  Future<CarritoResponse> getCarrito() async {
    final result = await executeWithStates<CarritoResponse>(() async {
      // Modo de prueba
      if (AppConfig.isTestMode) {
        debugPrint('[CarritoService] Usando datos de prueba para getCarrito');
        await Future.delayed(const Duration(milliseconds: 300));

        return CarritoResponse(
          items: [],
          subtotal: 0.0,
          total: 0.0,
          totalItems: 0,
          fechaCreacion: DateTime.now(),
        );
      }

      const cacheKey = 'carrito_actual';

      // Intentar obtener del cache primero
      final cachedData = await _cacheService.getReservasData<CarritoResponse>(
        cacheKey,
            (json) => CarritoResponse.fromJson(json),
      );

      if (cachedData != null) {
        debugPrint('[CarritoService] Carrito obtenido del cache');
        return cachedData;
      }

      // Si no está en cache, hacer petición al servidor
      final response = await _httpClient.get<CarritoResponse>(
        AppConfig.getEndpoint('reservas', 'cart'),
        fromJson: (json) => CarritoResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        // Guardar en cache
        await _cacheService.setReservasData(
          cacheKey,
          response.data!.toJson(),
        );
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  // POST /api/reservas/carrito/agregar - Agregar servicio al carrito
  Future<CarritoResponse> agregarAlCarrito({
    required int servicioId,
    required int cantidad,
    DateTime? fechaReserva,
    String? horaReserva,
    String? notas,
  }) async {
    final result = await executeWithStates<CarritoResponse>(() async {
      if (AppConfig.isTestMode) {
        debugPrint('[CarritoService] Usando datos de prueba para agregarAlCarrito');
        await Future.delayed(const Duration(milliseconds: 400));

        final nuevoItem = CarritoItem(
          id: DateTime.now().millisecondsSinceEpoch,
          servicioId: servicioId,
          nombre: 'Servicio de prueba',
          descripcion: 'Descripción del servicio de prueba',
          precio: 50.0,
          imagenUrl: 'servicio_prueba.jpg',
          cantidad: cantidad,
          fechaReserva: fechaReserva,
          horaReserva: horaReserva,
          notas: notas,
          fechaCreacion: DateTime.now(),
        );

        return CarritoResponse(
          items: [nuevoItem],
          subtotal: nuevoItem.subtotal,
          total: nuevoItem.subtotal,
          totalItems: cantidad,
          fechaCreacion: DateTime.now(),
        );
      }

      final body = {
        'servicio_id': servicioId,
        'cantidad': cantidad,
        if (fechaReserva != null) 'fecha_reserva': fechaReserva.toIso8601String(),
        if (horaReserva != null && horaReserva.isNotEmpty) 'hora_reserva': horaReserva,
        if (notas != null && notas.isNotEmpty) 'notas': notas,
      };

      final response = await _httpClient.post<CarritoResponse>(
        AppConfig.getEndpoint('reservas', 'addToCart'),
        body: body,
        fromJson: (json) => CarritoResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _cacheService.invalidateByPattern('carrito_');
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  // PUT /api/reservas/carrito/servicio/{servicioId} - Actualizar cantidad
  Future<CarritoResponse> actualizarCantidad({
    required int servicioId,
    required int nuevaCantidad,
  }) async {
    final result = await executeWithStates<CarritoResponse>(() async {
      if (AppConfig.isTestMode) {
        debugPrint('[CarritoService] Usando datos de prueba para actualizarCantidad');
        await Future.delayed(const Duration(milliseconds: 300));

        final itemActualizado = CarritoItem(
          id: DateTime.now().millisecondsSinceEpoch,
          servicioId: servicioId,
          nombre: 'Servicio de prueba',
          descripcion: 'Descripción del servicio de prueba',
          precio: 50.0,
          imagenUrl: 'servicio_prueba.jpg',
          cantidad: nuevaCantidad,
          fechaCreacion: DateTime.now(),
        );

        return CarritoResponse(
          items: [itemActualizado],
          subtotal: itemActualizado.subtotal,
          total: itemActualizado.subtotal,
          totalItems: nuevaCantidad,
          fechaCreacion: DateTime.now(),
        );
      }

      final body = {
        'cantidad': nuevaCantidad,
      };

      final response = await _httpClient.put<CarritoResponse>(
        '${AppConfig.getEndpoint('reservas', 'removeFromCart')}/$servicioId',
        body: body,
        fromJson: (json) => CarritoResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _cacheService.invalidateByPattern('carrito_');
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  // DELETE /api/reservas/carrito/servicio/{servicioId} - Remover
  Future<CarritoResponse> removerDelCarrito(int servicioId) async {
    final result = await executeWithStates<CarritoResponse>(() async {
      if (AppConfig.isTestMode) {
        debugPrint('[CarritoService] Usando datos de prueba para removerDelCarrito');
        await Future.delayed(const Duration(milliseconds: 300));

        return CarritoResponse(
          items: [],
          subtotal: 0.0,
          total: 0.0,
          totalItems: 0,
          fechaCreacion: DateTime.now(),
        );
      }

      final response = await _httpClient.delete<CarritoResponse>(
        '${AppConfig.getEndpoint('reservas', 'removeFromCart')}/$servicioId',
        fromJson: (json) => CarritoResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _cacheService.invalidateByPattern('carrito_');
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  // DELETE /api/reservas/carrito/vaciar - Vaciar carrito
  Future<CarritoResponse> vaciarCarrito() async {
    final result = await executeWithStates<CarritoResponse>(() async {
      if (AppConfig.isTestMode) {
        debugPrint('[CarritoService] Usando datos de prueba para vaciarCarrito');
        await Future.delayed(const Duration(milliseconds: 300));

        return CarritoResponse(
          items: [],
          subtotal: 0.0,
          total: 0.0,
          totalItems: 0,
          fechaCreacion: DateTime.now(),
        );
      }

      final response = await _httpClient.delete<CarritoResponse>(
        AppConfig.getEndpoint('reservas', 'clearCart'),
        fromJson: (json) => CarritoResponse.fromJson(json),
      );

      if (response.success && response.data != null) {
        await _cacheService.invalidateByPattern('carrito_');
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  // POST /api/reservas/carrito/confirmar - Confirmar carrito
  Future<Map<String, dynamic>> confirmarCarrito({
    String? notasAdicionales,
    String? metodoPago,
  }) async {
    final result = await executeWithStates<Map<String, dynamic>>(() async {
      if (AppConfig.isTestMode) {
        debugPrint('[CarritoService] Usando datos de prueba para confirmarCarrito');
        await Future.delayed(const Duration(milliseconds: 1000));

        return {
          'success': true,
          'message': 'Reservas confirmadas exitosamente',
          'reservas_creadas': 1,
          'total_pagado': 100.0,
          'numero_reserva': 'RES-${DateTime.now().millisecondsSinceEpoch}',
        };
      }

      final body = {
        if (notasAdicionales != null && notasAdicionales.isNotEmpty)
          'notas_adicionales': notasAdicionales,
        if (metodoPago != null && metodoPago.isNotEmpty)
          'metodo_pago': metodoPago,
      };

      final response = await _httpClient.post<Map<String, dynamic>>(
        AppConfig.getEndpoint('reservas', 'confirm'),
        body: body,
        fromJson: (json) => Map<String, dynamic>.from(json),
      );

      if (response.success && response.data != null) {
        await _cacheService.invalidateByPattern('carrito_');
        return response.data!;
      } else {
        throw response.message;
      }
    });

    if (result == null) throw 'No se recibió respuesta del servidor';
    return result;
  }

  // ---------- Auxiliares ----------

  Future<CarritoResponse> agregarServicioAlCarrito({
    required Servicio servicio,
    required int cantidad,
    DateTime? fechaReserva,
    String? horaReserva,
    String? notas,
  }) async {
    return agregarAlCarrito(
      servicioId: servicio.id,
      cantidad: cantidad,
      fechaReserva: fechaReserva,
      horaReserva: horaReserva,
      notas: notas,
    );
    // (no necesita await/executeWithStates aquí)
  }

  Future<bool> estaEnCarrito(int servicioId) async {
    try {
      final carrito = await getCarrito();
      return carrito.items.any((item) => item.servicioId == servicioId);
    } catch (_) {
      return false;
    }
  }

  Future<int> getCantidadEnCarrito(int servicioId) async {
    try {
      final carrito = await getCarrito();
      final item = carrito.items.firstWhere(
            (it) => it.servicioId == servicioId,
        orElse: () => CarritoItem(
          id: 0,
          servicioId: 0,
          nombre: '',
          descripcion: '',
          precio: 0.0,
          cantidad: 0,
          fechaCreacion: DateTime.now(),
        ),
      );
      return item.cantidad;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getTotalItems() async {
    try {
      final carrito = await getCarrito();
      return carrito.totalItems;
    } catch (_) {
      return 0;
    }
  }

  Future<double> getTotalCarrito() async {
    try {
      final carrito = await getCarrito();
      return carrito.total;
    } catch (_) {
      return 0.0;
    }
  }

  Future<bool> estaVacio() async {
    try {
      final carrito = await getCarrito();
      return carrito.estaVacio;
    } catch (_) {
      return true;
    }
  }

  Future<void> limpiarCache() async {
    await _cacheService.invalidateByPattern('carrito_');
  }

  // ====== ALIAS PARA COMPATIBILIDAD CON EL CONTROLLER ======

  /// Alias de [removerDelCarrito]
  Future<CarritoResponse> eliminarItemDelCarrito(int itemId) {
    return removerDelCarrito(itemId);
  }

  /// Alias de [actualizarCantidad]
  Future<CarritoResponse> actualizarCantidadItem(int itemId, int nuevaCantidad) {
    return actualizarCantidad(servicioId: itemId, nuevaCantidad: nuevaCantidad);
  }

  /// Alias de [vaciarCarrito]
  Future<CarritoResponse> limpiarCarrito() {
    return vaciarCarrito();
  }
}