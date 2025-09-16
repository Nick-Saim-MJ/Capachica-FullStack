import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/plan_detalle_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/cart_bottom_sheet.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../services/auth_service.dart';
import '../../../data/models/reserva_model.dart';
import '../../../core/widgets/auth_redirect_dialog.dart';

class PlanDetalleScreen extends GetView<PlanDetalleController> {
  const PlanDetalleScreen({super.key});

  // Lista de imágenes de assets para asignar rotativamente
  static const List<String> _assetImages = [
    'assets/paquete-turistico1.jpg',
    'assets/paquete-turistico2.jpg',
    'assets/paquete-turistico3.jpg',
    'assets/paquete-turistico4.jpg',
    'assets/paquete-turistico-line1-1.jpg',
    'assets/paquete-turistico-line1-2.jpg',
    'assets/paquete-turistico-line2-1.jpg',
    'assets/paquete-turistico-line2-2.jpg',
    'assets/paquete-turistico-line3-1.jpg',
    'assets/paquete-turistico-line3-2.jpg',
    'assets/paquete-turistico-line4-1.jpg',
    'assets/paquete-turistico-line4-2.jpg',
  ];

  String _getAssetImage(int index) {
    return _assetImages[index % _assetImages.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F1419) : Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Detalle del Plan',
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
                ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                : [Color(0xFFFF6B35), Color(0xFFFF8E53)], // Naranja para modo claro
            ),
          ),
        ),
        actions: [
          const CartIconWithBadge(),
          const ThemeToggleButton(),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(isDark);
        } else if (controller.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar detalles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Color(0xFF718096),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: controller.loadDetalle,
                    icon: Icon(Icons.refresh_rounded, size: 20),
                    label: Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (controller.planDetalle.value == null) {
          return Center(child: Text('No hay datos para mostrar', style: AppTheme.lightTextTheme.bodyLarge));
        }
        final detalle = controller.planDetalle.value!;
        return RefreshIndicator(
          onRefresh: controller.loadDetalle,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Imagen principal optimizada
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        _getAssetImage(detalle.plan.id.hashCode),
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 240,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Título y precio
              Card(
                color: isDark ? Color(0xFF1E293B) : Colors.white,
                elevation: 2,
                shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              detalle.plan.titulo,
                              style: TextStyle(
                                color: isDark ? Colors.white : Color(0xFF1A202C),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (detalle.plan.precio != null)
                            Text(
                              '\$${detalle.plan.precio!.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      if (detalle.plan.descripcion != null && detalle.plan.descripcion!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          detalle.plan.descripcion!,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Color(0xFF4A5568),
                            fontSize: 16,
                          ),
                        ),
                      ],
                      SizedBox(height: 12),
                      Row(
                        children: [
                          if (detalle.plan.duracion != null)
                            _infoIcon(Icons.schedule, '${detalle.plan.duracion} días'),
                          if (detalle.plan.ubicacion != null) ...[
                            const SizedBox(width: 16),
                            _infoIcon(Icons.location_on, detalle.plan.ubicacion!),
                          ],
                          if (detalle.plan.rating != null) ...[
                            const SizedBox(width: 16),
                            _infoIcon(Icons.star, detalle.plan.rating!.toStringAsFixed(1), color: Colors.amber),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Itinerario
              if (detalle.itinerario.isNotEmpty) ...[
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Itinerario',
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1A202C),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...detalle.itinerario.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.event_note,
                                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.titulo,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Color(0xFF1A202C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.descripcion != null && item.descripcion!.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        item.descripcion!,
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Color(0xFF4A5568),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                item.horaInicio != null ? '${item.horaInicio} - ${item.horaFin}' : '',
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : Color(0xFF718096),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Incluye / No incluye
              if (detalle.incluye.isNotEmpty || detalle.noIncluye.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incluye',
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1A202C),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...detalle.incluye.map((inc) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inc.nombre,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Color(0xFF1A202C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (inc.descripcion != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        inc.descripcion!,
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Color(0xFF4A5568),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        if (detalle.noIncluye.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'No incluye',
                            style: TextStyle(
                              color: isDark ? Colors.white : Color(0xFF1A202C),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...detalle.noIncluye.map((inc) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inc.nombre,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Color(0xFF1A202C),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (inc.descripcion != null) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          inc.descripcion!,
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Color(0xFF4A5568),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              // Información adicional
              if (detalle.informacionAdicional != null && detalle.informacionAdicional!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información adicional',
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1A202C),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...detalle.informacionAdicional!.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.key.toString(),
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Color(0xFF1A202C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      e.value?.toString() ?? '',
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Color(0xFF4A5568),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ],
              // Emprendedores asociados
              if (controller.emprendedores.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  elevation: 2,
                  shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emprendedores asociados',
                          style: TextStyle(
                            color: isDark ? Colors.white : Color(0xFF1A202C),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...controller.emprendedores.map((emp) => Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xFF1A1F2E) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              emp.imagen != null && emp.imagen!.isNotEmpty
                                ? CircleAvatar(backgroundImage: NetworkImage(emp.imagen!))
                                : CircleAvatar(
                                    backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      emp.nombre,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Color(0xFF1A202C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      emp.tipoServicio,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Color(0xFF4A5568),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: emp.estado 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      emp.estado ? Icons.check_circle : Icons.cancel,
                                      color: emp.estado ? Colors.green : Colors.red,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      emp.estado ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        color: emp.estado ? Colors.green : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
                        decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [Color(0xFF1E3A8A), Color(0xFF3B82F6)]  // Azul noche para modo oscuro
                    : [Color(0xFFFF6B35), Color(0xFFFF8E53)], // Naranja para modo claro
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                      ? Color(0xFF1E3A8A).withValues(alpha: 0.3)
                      : Color(0xFFFF6B35).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
          child: ElevatedButton.icon(
            icon: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
            label: Text(
              'Reservar este plan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              final authService = Get.find<AuthService>();
              final cartController = Get.find<CartController>();
              if (!authService.isLoggedIn) {
                // Guardar ruta pendiente y mostrar diálogo de login
                final box = GetStorage();
                final currentRoute = '/plan-detalle';
                box.write('pending_route', currentRoute);
                Get.dialog(AuthRedirectDialog(
                  onLoginPressed: () {
                    Get.toNamed('/login');
                  },
                  onRegisterPressed: () {
                    Get.toNamed('/register');
                  },
                ));
                return;
              }

              final fechaController = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);
              final horaInicioController = TextEditingController(text: '09:00');
              final horaFinController = TextEditingController(text: '10:00');
              final notasController = TextEditingController();
              final cantidadController = TextEditingController(text: '1');
              final duracionController = TextEditingController(text: '60');

              await Get.dialog(
                StatefulBuilder(
                  builder: (context, setState) {
                    final detalle = controller.planDetalle.value!;
                    final theme = Theme.of(context);
                    final isDark = Get.isDarkMode;
                    
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header con imagen y título
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                gradient: LinearGradient(
                                  colors: isDark
                                    ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
                                    : [const Color(0xFFFF6B35), const Color(0xFFFF8E53)],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: AssetImage(_getAssetImage(detalle.plan.id.hashCode)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Confirmar Reserva',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          detalle.plan.titulo,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '\$${detalle.plan.precio?.toStringAsFixed(2) ?? '0.00'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Formulario
                            Flexible(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    // Fecha
                                    _buildFormField(
                                      controller: fechaController,
                                      label: 'Fecha',
                                      hint: 'YYYY-MM-DD',
                                      icon: Icons.calendar_today_rounded,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Horarios
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            controller: horaInicioController,
                                            label: 'Hora Inicio',
                                            hint: 'HH:MM',
                                            icon: Icons.access_time_rounded,
                                            isDark: isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildFormField(
                                            controller: horaFinController,
                                            label: 'Hora Fin',
                                            hint: 'HH:MM',
                                            icon: Icons.access_time_filled_rounded,
                                            isDark: isDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Cantidad y duración
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFormField(
                                            controller: cantidadController,
                                            label: 'Cantidad',
                                            hint: 'Personas',
                                            icon: Icons.people_rounded,
                                            keyboardType: TextInputType.number,
                                            isDark: isDark,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildFormField(
                                            controller: duracionController,
                                            label: 'Duración',
                                            hint: 'Minutos',
                                            icon: Icons.timer_rounded,
                                            keyboardType: TextInputType.number,
                                            isDark: isDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Notas
                                    _buildFormField(
                                      controller: notasController,
                                      label: 'Notas adicionales',
                                      hint: 'Comentarios especiales (opcional)',
                                      icon: Icons.note_add_rounded,
                                      maxLines: 3,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Botones
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? const Color(0xFF334155).withOpacity(0.3)
                                  : const Color(0xFFF8FAFC),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => Get.back(),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final reserva = {
                                          'servicioId': detalle.plan.id,
                                          'emprendedorId': detalle.plan.emprendedorId,
                                          'fechaInicio': fechaController.text,
                                          'fechaFin': fechaController.text,
                                          'horaInicio': horaInicioController.text,
                                          'horaFin': horaFinController.text,
                                          'duracionMinutos': int.tryParse(duracionController.text) ?? 60,
                                          'cantidad': int.tryParse(cantidadController.text) ?? 1,
                                          'notasCliente': notasController.text.isNotEmpty ? notasController.text : null,
                                          'precioTotal': detalle.plan.precio ?? 0,
                                          'servicio': detalle.plan.toJson(),
                                        };
                                        await cartController.agregarAlCarrito(reserva);
                                        Get.back();
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          cartController.mostrarDialogoConfirmacion();
                                        });
                                      },
                                      icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                                      label: const Text(
                                        'Agregar al Carrito',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
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
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoIcon(IconData icon, String text, {Color? color}) {
    final isDark = Get.isDarkMode;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color ?? (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35))),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF1A202C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111827),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade500,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
              size: 20,
            ),
            filled: true,
            fillColor: isDark 
              ? const Color(0xFF334155).withOpacity(0.3)
              : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFFF6B35),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark 
            ? Color(0xFF2D3748).withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
              ),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando detalles...',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Obteniendo información completa',
              style: TextStyle(
                color: isDark ? Colors.white70 : Color(0xFF718096),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 