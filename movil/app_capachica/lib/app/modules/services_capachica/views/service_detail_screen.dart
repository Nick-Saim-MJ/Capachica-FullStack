import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/services_capachica_model.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../services/auth_service.dart';
import '../../../services/reserva_service.dart';
import '../../../core/widgets/auth_redirect_dialog.dart';
import '../../../core/widgets/reservation_form_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServicioCapachica servicio;
  const ServiceDetailScreen({Key? key, required this.servicio}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  // Lista de imágenes de assets para asignar rotativamente
  static const List<String> _assetImages = [
    'assets/lugar-turistico1.jpg',
    'assets/lugar-turistico2.jpg',
    'assets/lugar-turistico3.jpg',
    'assets/lugar-turistico4.jpg',
    'assets/lugar-turistico5.jpg',
    'assets/lugar-turistico6.jpg',
    'assets/lugar-turistico-line1-1.jpg',
    'assets/lugar-turistico-line1-2.jpg',
    'assets/lugar-turistico-line2-1.jpg',
    'assets/lugar-turistico-line2-2.jpg',
    'assets/lugar-turistico-line3-1.jpg',
    'assets/lugar-turistico-line3-2.jpg',
    'assets/lugar-turistico-line4-1.jpg',
    'assets/lugar-turistico-line4-2.jpg',
    'assets/lugar-turistico-line5-1.jpg',
    'assets/lugar-turistico-line5-2.jpg',
  ];

  String _getAssetImage(int index) {
    return _assetImages[index % _assetImages.length];
  }

  String capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categoria = widget.servicio.categorias.isNotEmpty ? widget.servicio.categorias[0].nombre : 'Servicio';
    final dias = widget.servicio.horarios.map((h) => capitalizeFirst(h.diaSemana)).toSet().toList();

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F1419) : Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Detalle del Servicio',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal optimizada
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 240,
                width: double.infinity,
                margin: EdgeInsets.all(16),
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
                      _getAssetImage(widget.servicio.id.hashCode),
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
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
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  widget.servicio.nombre,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Color(0xFF1A202C),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'S/. ${widget.servicio.precioReferencial}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  categoria,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.servicio.estado ? Colors.green[100] : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.servicio.estado ? 'Disponible' : 'No disponible',
                                  style: TextStyle(
                                    color: widget.servicio.estado ? Colors.green[900] : Colors.red[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Descripción
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
                            'Descripción',
                            style: TextStyle(
                              color: isDark ? Colors.white : Color(0xFF1A202C),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.servicio.descripcion,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Color(0xFF718096),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Información del servicio
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
                            'Información del Servicio',
                            style: TextStyle(
                              color: isDark ? Colors.white : Color(0xFF1A202C),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _infoRow(
                            Icons.people,
                            'Capacidad',
                            '${widget.servicio.capacidad} personas',
                            isDark,
                          ),
                          SizedBox(height: 8),
                          _infoRow(
                            Icons.location_on,
                            'Ubicación',
                            widget.servicio.ubicacionReferencia,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Emprendedor
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
                            'Emprendedor',
                            style: TextStyle(
                              color: isDark ? Colors.white : Color(0xFF1A202C),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.servicio.emprendedor.nombre,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Color(0xFF1A202C),
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      widget.servicio.emprendedor.tipoServicio,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white70 : Color(0xFF718096),
                                      ),
                                    ),
                                    Text(
                                      widget.servicio.emprendedor.ubicacion,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white60 : Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.verified,
                                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Horarios de disponibilidad
                  if (widget.servicio.horarios.isNotEmpty) ...[
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
                              'Horarios de Disponibilidad',
                              style: TextStyle(
                                color: isDark ? Colors.white : Color(0xFF1A202C),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.servicio.horarios.map((h) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today, color: Colors.green, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          capitalizeFirst(h.diaSemana),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green[900],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '${h.horaInicio} - ${h.horaFin}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  
                  // Botones de acción
                  Card(
                    color: isDark ? Color(0xFF1E293B) : Colors.white,
                    elevation: 2,
                    shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF25D366), // Verde WhatsApp
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 18),
                                  label: Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    final telefono = widget.servicio.emprendedor.telefono;
                                    if (telefono != null && telefono.isNotEmpty) {
                                      final url = 'https://wa.me/$telefono';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        Get.snackbar('Error', 'No se pudo abrir WhatsApp', backgroundColor: Colors.red, colorText: Colors.white);
                                      }
                                    } else {
                                      Get.snackbar('Sin número', 'El emprendedor no tiene número de WhatsApp disponible', backgroundColor: Colors.orange, colorText: Colors.white);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Obx(() {
                                  final authService = Get.find<AuthService>();
                                  return ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    icon: Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                                    label: Text(
                                      authService.isLoggedInRx.value ? 'Reservar' : 'Iniciar Sesión',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () => _handleReservar(context, authService.isLoggedInRx.value),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
          size: 20,
        ),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white70 : Color(0xFF718096),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleReservar(BuildContext context, bool isLoggedIn) async {
    final box = GetStorage();
    final currentRoute = '/services-capachica/detail/${widget.servicio.id}';

    if (!isLoggedIn) {
      // Guardar ruta pendiente y mostrar diálogo de login
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

    // Mostrar el nuevo formulario de reserva moderno
    showDialog(
      context: context,
      builder: (context) => ReservationFormDialog(
        servicio: widget.servicio,
        onReservationAdded: () {
          // Callback cuando se agrega una reserva
          setState(() {});
        },
      ),
    );
  }
} 