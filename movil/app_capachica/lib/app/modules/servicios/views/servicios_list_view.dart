import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/servicios_controller.dart';
import '../widgets/servicio_card.dart';

class ServiciosListView extends StatelessWidget {
  const ServiciosListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Servicios',
          style: textTheme.headlineSmall?.copyWith(
            color: Get.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Get.theme.colorScheme.onPrimary),
            onPressed: () => Get.toNamed('/carrito'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final controller = Get.find<ServiciosController>();
          await controller.refreshData();
        },
        child: Column(
          children: [
            _buildFiltersSection(),
            Expanded(
              child: GetX<ServiciosController>(
                builder: (controller) {
                  if (controller.isLoading.value && controller.servicios.isEmpty) {
                    return const _LoadingState();
                  }

                  if (controller.hasError.value) {
                    return _ErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.refreshData,
                    );
                  }

                  if (controller.showEmptyState) {
                    return _EmptyState(
                      title: 'No hay servicios disponibles',
                      subtitle: 'Intenta ajustar los filtros de búsqueda',
                      icon: Icons.work_outline,
                      onAction: controller.refreshData,
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                    controller.servicios.length + (controller.showLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.servicios.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final servicio = controller.servicios[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ServicioCard(
                          servicio: servicio,
                          onTap: () => Get.toNamed('/servicio-detalle', arguments: servicio.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return GetX<ServiciosController>(
      builder: (controller) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          boxShadow: [
            // ~10% alpha
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar servicios...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: controller.onSearchChanged,
            ),

            const SizedBox(height: 16),

            // Filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.categorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: controller.onCategorySelected,
                    initialValue: controller.selectedCategoria.value.isEmpty
                        ? null
                        : controller.selectedCategoria.value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    decoration: InputDecoration(
                      labelText: 'Emprendedor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: controller.emprendedores.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.nombre),
                      );
                    }).toList(),
                    onChanged: controller.onEmprendedorSelected,
                    initialValue: controller.selectedEmprendedorId.value == 0
                        ? null
                        : controller.selectedEmprendedorId.value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Rango de precios
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Precio mínimo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: controller.onPrecioMinChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Precio máximo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: controller.onPrecioMaxChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Ocurrió un error', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
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
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}