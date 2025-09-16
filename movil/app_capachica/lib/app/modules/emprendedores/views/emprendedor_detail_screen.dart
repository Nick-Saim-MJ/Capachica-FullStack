import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/emprendedor_model.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/cart_bottom_sheet.dart';
import '../../../core/controllers/cart_controller.dart';
import '../controllers/emprendedores_controller.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';

class EmprendedorDetailScreen extends StatefulWidget {
  final Emprendedor emprendedor;
  
  const EmprendedorDetailScreen({
    Key? key,
    required this.emprendedor,
  }) : super(key: key);

  @override
  State<EmprendedorDetailScreen> createState() => _EmprendedorDetailScreenState();
}

class _EmprendedorDetailScreenState extends State<EmprendedorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingServicios = false;
  bool _isLoadingRelaciones = false;
  List<ServicioEmprendedor> _servicios = [];
  List<RelacionEmprendedor> _relaciones = [];
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdditionalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdditionalData() async {
    await Future.wait([
      _loadServicios(),
      _loadRelaciones(),
    ]);
  }

  Future<void> _loadServicios() async {
    setState(() {
      _isLoadingServicios = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _servicios = widget.emprendedor.servicios ?? [];
        _isLoadingServicios = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar servicios: $e';
        _isLoadingServicios = false;
      });
    }
  }

  Future<void> _loadRelaciones() async {
    setState(() {
      _isLoadingRelaciones = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _relaciones = widget.emprendedor.relaciones ?? [];
        _isLoadingRelaciones = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar relaciones: $e';
        _isLoadingRelaciones = false;
      });
    }
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
          widget.emprendedor.nombre,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Información'),
            Tab(text: 'Servicios'),
            Tab(text: 'Contacto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInformacionTab(isDark),
          _buildServiciosTab(isDark),
          _buildContactoTab(isDark),
        ],
      ),
    );
  }

  Widget _buildInformacionTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmprendedorImage(isDark),
          const SizedBox(height: 20),
          _buildBasicInfo(isDark),
          const SizedBox(height: 20),
          if (widget.emprendedor.descripcion != null && widget.emprendedor.descripcion!.isNotEmpty)
            _buildDescription(isDark),
          const SizedBox(height: 20),
          _buildStatusCard(isDark),
          const SizedBox(height: 20),
          if (_relaciones.isNotEmpty) _buildRelacionesSection(isDark),
        ],
      ),
    );
  }

  Widget _buildEmprendedorImage(bool isDark) {
    String? imagenUrl;
    
    try {
      if (widget.emprendedor.imagen != null && widget.emprendedor.imagen!.isNotEmpty) {
        imagenUrl = widget.emprendedor.imagen;
      } else if (widget.emprendedor.imagenes != null && widget.emprendedor.imagenes!.isNotEmpty) {
        final imgs = widget.emprendedor.imagenes!;
        List<String> lista = [];
        
        if (imgs.startsWith('[') && imgs.endsWith(']')) {
          lista = imgs
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (imgs.contains(',')) {
          lista = imgs.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        } else {
          lista = [imgs];
        }
        
        if (lista.isNotEmpty && lista[0].isNotEmpty) {
          imagenUrl = lista[0];
        }
      }
    } catch (_) {}

    bool isValidUrl(String? url) {
      return url != null && (url.startsWith('http://') || url.startsWith('https://'));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 240,
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
            if (isValidUrl(imagenUrl))
              Image.network(
                imagenUrl!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  _getAssetImage(widget.emprendedor.id.hashCode),
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Image.asset(
                _getAssetImage(widget.emprendedor.id.hashCode),
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 240,
                  width: double.infinity,
                  color: isDark ? Color(0xFF334155) : Colors.grey[300],
                  child: Icon(
                    Icons.store,
                    size: 64,
                    color: isDark ? Colors.white30 : Colors.grey[600],
                  ),
                ),
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
    );
  }

  Widget _buildBasicInfo(bool isDark) {
    return Card(
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
              widget.emprendedor.nombre,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(
                  Icons.category, 
                  color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                  size: 20
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.emprendedor.tipoServicio,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(Icons.location_on, color: isDark ? Colors.white70 : Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.emprendedor.ubicacion,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Card(
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
              children: [
                Icon(
                  Icons.description, 
                  color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                  size: 20
                ),
                const SizedBox(width: 8),
                Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(0xFF1A202C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.emprendedor.descripcion!,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDark ? Colors.white70 : Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Card(
      color: isDark ? Color(0xFF1E293B) : Colors.white,
      elevation: 2,
      shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.emprendedor.estado ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.emprendedor.estado ? 'Emprendedor Activo' : 'Emprendedor Inactivo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.emprendedor.estado ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelacionesSection(bool isDark) {
    return Card(
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
              children: [
                Icon(
                  Icons.link, 
                  color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                  size: 20
                ),
                const SizedBox(width: 8),
                Text(
                  'Información Adicional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(0xFF1A202C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._relaciones.map((relacion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${relacion.tipo}: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      relacion.valor,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Color(0xFF718096),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildServiciosTab(bool isDark) {
    if (_isLoadingServicios) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando servicios...',
              style: TextStyle(
                fontSize: 16, 
                color: isDark ? Colors.white70 : Colors.grey[600]
              ),
            ),
          ],
        ),
      );
    }

    if (_servicios.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 64,
                      color: isDark ? Colors.white30 : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay servicios disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este emprendedor aún no ha registrado servicios',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Color(0xFF718096),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _servicios.length,
      itemBuilder: (context, index) {
        final servicio = _servicios[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                  children: [
                    Expanded(
                      child: Text(
                        servicio.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Color(0xFF1A202C),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: servicio.estado ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        servicio.estado ? 'Disponible' : 'No disponible',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  servicio.descripcion,
                  style: TextStyle(
                    fontSize: 14, 
                    height: 1.4,
                    color: isDark ? Colors.white70 : Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money, 
                      color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                      size: 16
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'S/. ${servicio.precioReferencial}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.people, color: isDark ? Colors.white70 : Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${servicio.capacidad} personas',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: isDark ? Colors.white70 : Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        servicio.ubicacionReferencia,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (servicio.categorias.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: servicio.categorias.map((categoria) => Chip(
                      label: Text(
                        categoria.nombre,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: (isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withValues(alpha: 0.1),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactoTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                    children: [
                      Icon(
                        Icons.contact_phone, 
                        color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                        size: 20
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Información de Contacto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Color(0xFF1A202C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (widget.emprendedor.telefono != null && widget.emprendedor.telefono!.isNotEmpty)
                    _buildContactItem(
                      Icons.phone,
                      'Teléfono',
                      widget.emprendedor.telefono!,
                      () => _makePhoneCall(widget.emprendedor.telefono!),
                      isDark,
                    ),
                  
                  if (widget.emprendedor.email != null && widget.emprendedor.email!.isNotEmpty)
                    _buildContactItem(
                      Icons.email,
                      'Email',
                      widget.emprendedor.email!,
                      () => _sendEmail(widget.emprendedor.email!),
                      isDark,
                    ),
                  
                  _buildContactItem(
                    Icons.location_on,
                    'Ubicación',
                    widget.emprendedor.ubicacion,
                    () => _openLocation(),
                    isDark,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
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
                    'Acciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _contactEmprendedor(),
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text('Contactar', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareEmprendedor(),
                      icon: Icon(
                        Icons.share, 
                        color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
                      ),
                      label: Text(
                        'Compartir',
                        style: TextStyle(
                          color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(
                icon, 
                color: isDark ? Color(0xFF3B82F6) : Color(0xFFFF6B35), 
                size: 20
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Color(0xFF1A202C),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios, 
                color: isDark ? Colors.white30 : Colors.grey[400], 
                size: 16
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String phone) {
    Get.snackbar(
      'Llamar',
      'Llamando a $phone',
      backgroundColor: (Get.isDarkMode ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  void _sendEmail(String email) {
    Get.snackbar(
      'Email',
      'Enviando email a $email',
      backgroundColor: (Get.isDarkMode ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  void _openLocation() {
    Get.snackbar(
      'Ubicación',
      'Abriendo ubicación en mapa',
      backgroundColor: (Get.isDarkMode ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  void _contactEmprendedor() {
    Get.snackbar(
      'Contacto',
      'Contactando con ${widget.emprendedor.nombre}',
      backgroundColor: (Get.isDarkMode ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }

  void _shareEmprendedor() {
    Get.snackbar(
      'Compartir',
      'Compartiendo información de ${widget.emprendedor.nombre}',
      backgroundColor: (Get.isDarkMode ? Color(0xFF3B82F6) : Color(0xFFFF6B35)).withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16),
    );
  }
} 