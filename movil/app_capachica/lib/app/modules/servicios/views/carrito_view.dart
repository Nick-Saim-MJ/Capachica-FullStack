import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/carrito_controller.dart';

class CarritoView extends StatelessWidget {
  const CarritoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carrito',
          style: textTheme.headlineSmall?.copyWith(
            color: Get.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.colorScheme.primary,
        elevation: 0,
        actions: [
          GetX<CarritoController>(
            builder: (controller) => IconButton(
              icon: Icon(Icons.refresh, color: Get.theme.colorScheme.onPrimary),
              onPressed: controller.refreshData,
            ),
          ),
        ],
      ),
      body: GetX<CarritoController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const _LoadingState();
          }

          if (controller.hasError.value) {
            return _ErrorState(
              message: controller.errorMessage.value,
              onRetry: controller.refreshData,
            );
          }

          if (controller.items.isEmpty) {
            return _EmptyState(
              title: 'Tu carrito está vacío',
              subtitle: 'Agrega algunos servicios para comenzar',
              icon: Icons.shopping_cart_outlined,
              onAction: () => Get.offAllNamed('/servicios'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildCarritoItem(context, item, controller),
                    );
                  },
                ),
              ),
              _buildTotalSection(context, controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarritoItem(
      BuildContext context,
      dynamic item,
      CarritoController controller,
      ) {
    final textTheme = Theme.of(context).textTheme;

    // Soportar tanto modelo embebido como string directo
    final String? imageUrl =
        (item.servicio?.imagenPrincipal as String?) ?? (item.imagenUrl as String?);

    final String titulo = item.servicio?.nombre ?? (item.nombre as String? ?? 'Servicio');

    final String? emprendedorNombre =
        (item.servicio?.emprendedor?.nombre as String?) ?? item.emprendedorNombre as String?;

    // En el modelo de carrito tenemos 'subtotal' (no 'precioTotal')
    final double subtotal = (item.subtotal as double?) ??
        ((item.precio as double? ?? 0.0) * (item.cantidad as int? ?? 1));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            if (imageUrl != null && imageUrl.isNotEmpty)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.work_outline,
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (emprendedorNombre != null && emprendedorNombre.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      emprendedorNombre,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text('Cantidad: ${item.cantidad}', style: textTheme.bodyMedium),
                  if (item.fechaReserva != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Fecha: '
                          '${item.fechaReserva!.day.toString().padLeft(2, '0')}/'
                          '${item.fechaReserva!.month.toString().padLeft(2, '0')}/'
                          '${item.fechaReserva!.year}',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                  if (item.horaReserva != null && item.horaReserva!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Hora: ${item.horaReserva}', style: textTheme.bodyMedium),
                  ],
                  if (item.notas != null && item.notas!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Notas: ${item.notas}', style: textTheme.bodyMedium),
                  ],
                ],
              ),
            ),

            // Precio + borrar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'S/ ${subtotal.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Get.theme.colorScheme.error),
                  onPressed: () => controller.eliminarItem(item.id as int),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context, CarritoController controller) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                'S/ ${controller.total.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botón pagar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.puedeProcederAlPago ? controller.procederAlPago : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Proceder al Pago',
                style: textTheme.titleMedium?.copyWith(
                  color: Get.theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== Mini widgets locales para no depender de imports inexistentes ======

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text('Ocurrió un error', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle, style: textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Explorar servicios'),
            ),
          ],
        ),
      ),
    );
  }
}