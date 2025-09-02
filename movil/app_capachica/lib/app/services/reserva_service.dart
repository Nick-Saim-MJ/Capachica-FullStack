import 'package:get/get.dart';
import '../core/config/backend_config.dart';
import 'auth_service.dart';

class ReservaService extends GetxService {
  final _authService = Get.find<AuthService>();

  // Getter para obtener la URL actual
  String get baseUrl => BackendConfig.getBaseUrl();

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => _authService.token != null;

  // Lista local para simular el carrito
  final List<Map<String, dynamic>> _carritoLocal = [];
  final List<Map<String, dynamic>> _reservasLocal = [];

  // Obtener reservas del carrito
  List<Map<String, dynamic>> get reservasCarrito => _carritoLocal;

  // Obtener carrito
  Future<Map<String, dynamic>> obtenerCarrito() async {
    try {
      final total = _carritoLocal.fold(0.0, (sum, item) => sum + (item['precioTotal'] ?? 0.0));
      return {
        'items': _carritoLocal,
        'total': total,
        'cantidadItems': _carritoLocal.length,
      };
    } catch (e) {
      print('Error al obtener carrito: $e');
      return {
        'items': [],
        'total': 0.0,
        'cantidadItems': 0,
      };
    }
  }

  // Obtener total del carrito
  double get totalCarrito {
    return _carritoLocal.fold(0.0, (sum, item) => sum + (item['precioTotal'] ?? 0.0));
  }

  // Agregar al carrito
  Future<Map<String, dynamic>> agregarAlCarrito(Map<String, dynamic> reserva) async {
    try {
      _carritoLocal.add(reserva);
      return {
        'success': true,
        'message': 'Servicio agregado al carrito exitosamente',
        'data': reserva,
      };
    } catch (e) {
      print('Error al agregar al carrito: $e');
      return {
        'success': false,
        'message': 'Error al agregar al carrito: $e',
      };
    }
  }

  // Eliminar del carrito
  Future<Map<String, dynamic>> eliminarDelCarrito(Map<String, dynamic> reserva) async {
    try {
      _carritoLocal.removeWhere((item) => item['servicioId'] == reserva['servicioId']);
      return {
        'success': true,
        'message': 'Servicio eliminado del carrito exitosamente',
      };
    } catch (e) {
      print('Error al eliminar del carrito: $e');
      return {
        'success': false,
        'message': 'Error al eliminar del carrito: $e',
      };
    }
  }

  // Vaciar carrito
  Future<Map<String, dynamic>> vaciarCarrito() async {
    try {
      _carritoLocal.clear();
      return {
        'success': true,
        'message': 'Carrito vaciado exitosamente',
      };
    } catch (e) {
      print('Error al vaciar carrito: $e');
      return {
        'success': false,
        'message': 'Error al vaciar carrito: $e',
      };
    }
  }

  // Confirmar reserva
  Future<Map<String, dynamic>> confirmarReserva(Map<String, dynamic> request) async {
    try {
      // Simular confirmación exitosa
      final reserva = {
        ...request,
        'id': DateTime.now().millisecondsSinceEpoch,
        'estado': 'confirmada',
        'createdAt': DateTime.now().toIso8601String(),
      };
      _reservasLocal.add(reserva);
      return {
        'success': true,
        'message': 'Reserva confirmada exitosamente',
        'data': reserva,
      };
    } catch (e) {
      print('Error al confirmar reserva: $e');
      return {
        'success': false,
        'message': 'Error al confirmar reserva: $e',
      };
    }
  }

  // Limpiar carrito
  void limpiarCarrito() {
    _carritoLocal.clear();
  }

  // Confirmar reservas del carrito
  Future<bool> confirmarReservas(String metodoPago, {String? notas}) async {
    try {
      // Simular confirmación exitosa
      for (var reserva in _carritoLocal) {
        reserva['estado'] = 'confirmada';
        _reservasLocal.add(reserva);
      }
      _carritoLocal.clear();
      return true;
    } catch (e) {
      print('Error al confirmar reservas: $e');
      return false;
    }
  }

  // Obtener mis reservas
  Future<List<Map<String, dynamic>>> obtenerMisReservas() async {
    try {
      return _reservasLocal;
    } catch (e) {
      print('Error al obtener reservas: $e');
      return [];
    }
  }

  // Obtener reservas por emprendedor
  Future<List<Map<String, dynamic>>> obtenerReservasEmprendedor(int emprendedorId) async {
    try {
      return _reservasLocal.where((r) => r['emprendedorId'] == emprendedorId).toList();
    } catch (e) {
      print('Error al obtener reservas del emprendedor: $e');
      return [];
    }
  }

  // Obtener reservas por servicio
  Future<List<Map<String, dynamic>>> obtenerReservasServicio(int servicioId) async {
    try {
      return _reservasLocal.where((r) => r['servicioId'] == servicioId).toList();
    } catch (e) {
      print('Error al obtener reservas del servicio: $e');
      return [];
    }
  }

  // Obtener reserva por ID
  Future<Map<String, dynamic>?> obtenerReservaPorId(int id) async {
    try {
      return _reservasLocal.firstWhere((r) => r['id'] == id);
    } catch (e) {
      print('Error al obtener reserva por ID: $e');
      return null;
    }
  }

  // Actualizar estado de reserva
  Future<bool> actualizarEstadoReserva(int reservaId, String nuevoEstado) async {
    try {
      final reserva = _reservasLocal.firstWhere((r) => r['id'] == reservaId);
      reserva['estado'] = nuevoEstado;
      return true;
    } catch (e) {
      print('Error al actualizar estado de reserva: $e');
      return false;
    }
  }

  // Eliminar reserva
  Future<bool> eliminarReserva(int reservaId) async {
    try {
      _reservasLocal.removeWhere((r) => r['id'] == reservaId);
      return true;
    } catch (e) {
      print('Error al eliminar reserva: $e');
      return false;
    }
  }
} 