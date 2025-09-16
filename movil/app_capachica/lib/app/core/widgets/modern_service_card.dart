import 'package:app_capachica/app/data/models/servicio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../../core/controllers/cart_controller.dart';
// Ajusta esta ruta si tu modelo está en otro archivo:


import 'auth_redirect_dialog.dart';

class ModernServiceCard extends StatefulWidget {
  final Servicio servicio;
  final VoidCallback? onTap;

  const ModernServiceCard({
    super.key,
    required this.servicio,
    this.onTap,
  });

  @override
  State<ModernServiceCard> createState() => _ModernServiceCardState();
}

class _ModernServiceCardState extends State<ModernServiceCard> {
  bool isLoading = false;
  final notasController = TextEditingController();

  String fechaInicio =
  DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0];
  String fechaFin =
  DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0];
  String horaInicio = '09:00';
  String horaFin = '10:00';
  int duracionMinutos = 60;
  int cantidad = 1;

  double get precioUnitario =>
      (widget.servicio.precio is num) ? (widget.servicio.precio as num).toDouble() : 0.0;

  double get precioTotal => precioUnitario * cantidad;

  @override
  void dispose() {
    notasController.dispose();
    super.dispose();
  }

  void showAuthRedirectDialog() {
    Get.dialog(
      AuthRedirectDialog(
        onLoginPressed: () => Get.toNamed('/login'),
        onRegisterPressed: () => Get.toNamed('/register'),
      ),
    );
  }

  Future<void> _handleAgregarAlCarrito() async {
    final authService = Get.find<AuthService>();
    final cartController = Get.find<CartController>();

    if (!authService.isLoggedIn) {
      showAuthRedirectDialog();
      return;
    }

    try {
      setState(() => isLoading = true);

      final reserva = {
        'servicioId': widget.servicio.id,
        'emprendedorId': widget.servicio.emprendedorId,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'duracionMinutos': duracionMinutos,
        'cantidad': cantidad,
        'notasCliente': notasController.text,
        'precioTotal': precioTotal,
        'servicio': widget.servicio.toJson(), // ajusta si tu modelo usa toMap()
      };

      await cartController.agregarAlCarrito(reserva);

      if (!mounted) return;
      Get.snackbar(
        '¡Agregado!',
        'Servicio agregado al carrito exitosamente',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error al agregar al carrito: $e');
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'No se pudo agregar al carrito: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del servicio
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                widget.servicio.imagenUrl ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del servicio
                  Text(
                    widget.servicio.nombre ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descripción
                  Text(
                    widget.servicio.descripcion ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  // Precio y botón de reserva
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'S/ ${precioUnitario.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleAgregarAlCarrito,
                        icon: isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.add_shopping_cart),
                        label: Text(isLoading ? 'Agregando...' : 'Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}