import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/servicio_detail_controller.dart';

class ServicioDetailView extends StatelessWidget {
  const ServicioDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle del Servicio',
          style: textTheme.headlineSmall?.copyWith(
            color: Get.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.colorScheme.primary,
        elevation: 0,
      ),
      body: GetX<ServicioDetailController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const _LoadingState();
          }

          if (controller.error.value.isNotEmpty) {
            return _ErrorState(
              message: controller.error.value,
              onRetry: controller.loadServicio,
            );
          }

          if (controller.servicio.value == null) {
            return const Center(child: Text('Servicio no encontrado'));
          }

          return _buildServicioDetail(context, controller);
        },
      ),
    );
  }

  Widget _buildServicioDetail(
      BuildContext context,
      ServicioDetailController controller,
      ) {
    final textTheme = Theme.of(context).textTheme;
    final servicio = controller.servicio.value!;

    final String? imagen = (servicio.imagenPrincipal as String?);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          if (imagen != null && imagen.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imagen),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Info básica
          Text(
            servicio.nombre as String? ?? 'Servicio',
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            servicio.descripcion as String? ?? '',
            style: textTheme.bodyLarge,
          ),

          const SizedBox(height: 16),

          // Precio
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Precio', style: textTheme.titleMedium),
                Text(
                  controller.precioTotalFormateado, // muestra precio formateado calculado
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Emprendedor (si existe)
          if (servicio.emprendedorId != null) _buildEmprendedorInfo(context, servicio),

          const SizedBox(height: 16),

          // Horarios (si existen)
          if ((servicio.horarios as List?)?.isNotEmpty ?? false)
            _buildHorariosSection(context, servicio),

          const SizedBox(height: 16),

          // Formulario de reserva
          _buildReservaForm(context, controller),

          const SizedBox(height: 16),

          // Botón agregar carrito
          _buildAddToCartButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildEmprendedorInfo(BuildContext context, dynamic servicio) {
    final textTheme = Theme.of(context).textTheme;
    final empr = servicio.emprendedor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Get.theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Emprendedor',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(empr.nombre as String? ?? '', style: textTheme.bodyLarge),
          if ((empr.ubicacion as String?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              empr.ubicacion as String,
              style: textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorariosSection(BuildContext context, dynamic servicio) {
    final textTheme = Theme.of(context).textTheme;
    final List horarios = (servicio.horarios as List);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Get.theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horarios de Atención',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...horarios.map((h) {
            final dia = h.dia ?? '';
            final hi = h.horaInicio ?? '';
            final hf = h.horaFin ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('$dia: $hi - $hf', style: textTheme.bodyMedium),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReservaForm(BuildContext context, ServicioDetailController controller) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Get.theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reserva',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Fecha
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Fecha de reserva',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            readOnly: true,
            onTap: () => _selectDate(controller),
            controller: TextEditingController(
              text: controller.fechaReserva.value != null
                  ? '${controller.fechaReserva.value!.day.toString().padLeft(2, '0')}/'
                  '${controller.fechaReserva.value!.month.toString().padLeft(2, '0')}/'
                  '${controller.fechaReserva.value!.year}'
                  : '',
            ),
          ),

          const SizedBox(height: 16),

          // Hora
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Hora de reserva',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: controller.setHoraReserva,
          ),

          const SizedBox(height: 16),

          // Cantidad
          Row(
            children: [
              const Text('Cantidad: '),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => controller.changeCantidad(controller.cantidad.value - 1),
              ),
              Text('${controller.cantidad.value}'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => controller.changeCantidad(controller.cantidad.value + 1),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notas
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Notas adicionales',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
            onChanged: controller.setNotas,
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, ServicioDetailController controller) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isAddingToCart.value ? null : controller.agregarAlCarrito,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: controller.isAddingToCart.value
            ? CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary)
            : Text(
          'Agregar al Carrito - ${controller.precioTotalFormateado}',
          style: textTheme.titleMedium?.copyWith(
            color: Get.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(ServicioDetailController controller) async {
    final fecha = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      controller.setFechaReserva(fecha);
    }
  }
}

/// ====== Mini widgets locales para estados ======

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