import 'package:app_capachica/app/modules/emprendedores/controllers/emprendedores_controller.dart';
import 'package:app_capachica/app/modules/emprendedores/views/emprendedor_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import 'emprendedor_card.dart';

class EmprendedoresScreen extends GetView<EmprendedoresController> {
  const EmprendedoresScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Emprendedores',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                  : [const Color(0xFFFF6B35), const Color(0xFFFF8E53)], // Naranja para modo claro
            ),
          ),
        ),
        actions: const [
          CartIconWithBadge(),
          ThemeToggleButton(),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          _buildSearchBar(isDark),

          // Filtros
          _buildFilters(isDark),

          // Contenido principal
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(isDark);
              }

              if (controller.error.value.isNotEmpty) {
                return _buildErrorState(isDark);
              }

              if (controller.emprendedores.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return _buildEmprendedoresList(isDark);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDark ? Colors.white60 : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: controller.searchQuery.value),
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Buscar emprendedores...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey[600],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: Icon(Icons.clear),
                      // 🔑 Aquí está la corrección: llamar al método clearSearch del controller
                      onPressed: () {
                        controller.clearSearch();
                        FocusManager.instance.primaryFocus?.unfocus(); // Opcional: ocultar el teclado
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Filtro por categoría
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedCategoria.value.isEmpty ? null : controller.selectedCategoria.value,
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white30 : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white30 : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                  ),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('Todas las categorías'),
                ),
                ...controller.categoriasUnicas.map((categoria) => DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                )),
              ],
              onChanged: (value) {
                controller.filterByCategoria(value ?? '');
              },
            )),
          ),

          const SizedBox(width: 8),

          // Botón limpiar filtros
          Obx(() {
            if (controller.selectedCategoria.value.isNotEmpty || controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                onPressed: () => controller.clearFilters(),
                icon: Icon(
                  Icons.clear_all,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
                tooltip: 'Limpiar filtros',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildEmprendedoresList(bool isDark) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshEmprendedores(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.emprendedores.length,
        itemBuilder: (context, index) {
          final emprendedorResumen = controller.emprendedores[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EmprendedorCard(
              emprendedor: emprendedorResumen,
              onTap: () {
                // Show a loading indicator while fetching the full data
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  barrierDismissible: false,
                );

                // Fetch the complete Emprendedor object
                controller.fetchEmprendedorById(emprendedorResumen.id).then((fullEmprendedor) {
                  Get.back(); // Dismiss the loading dialog
                  if (fullEmprendedor != null) {
                    Get.to(() => EmprendedorDetailScreen(emprendedor: fullEmprendedor));
                  } else {
                    // Handle the case where the full data couldn't be fetched
                    Get.snackbar(
                      'Error',
                      'No se pudo cargar los detalles del emprendedor.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35)
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando emprendedores...',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: isDark ? Colors.red[400] : Colors.red[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar emprendedores',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error.value,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshEmprendedores(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay emprendedores disponibles',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pronto tendremos más emprendedores para ti',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF718096),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.refreshEmprendedores(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Recargar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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