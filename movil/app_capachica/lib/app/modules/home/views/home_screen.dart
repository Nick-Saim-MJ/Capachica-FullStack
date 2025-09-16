import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import '../controllers/home_controller.dart';
import '../../../core/widgets/cart_bottom_sheet.dart';
import '../../../core/controllers/cart_controller.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import 'dart:math';

class HomeScreen extends GetView<HomeController> {
  final List<String> assetImages = [
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
    'assets/lugar-turistico1.jpg',
    'assets/lugar-turistico2.jpg',
    'assets/lugar-turistico3.jpg',
    'assets/lugar-turistico4.jpg',
    'assets/lugar-turistico5.jpg',
    'assets/lugar-turistico6.jpg',
    'assets/paquete-turistico-line1-1.jpg',
    'assets/paquete-turistico-line1-2.jpg',
    'assets/paquete-turistico-line2-1.jpg',
    'assets/paquete-turistico-line2-2.jpg',
    'assets/paquete-turistico-line3-1.jpg',
    'assets/paquete-turistico-line3-2.jpg',
    'assets/paquete-turistico-line4-1.jpg',
    'assets/paquete-turistico-line4-2.jpg',
    'assets/paquete-turistico1.jpg',
    'assets/paquete-turistico2.jpg',
    'assets/paquete-turistico3.jpg',
    'assets/paquete-turistico4.jpg',
  ];

  String getRandomAssetImage([int? seed]) {
    final rand = Random(seed);
    return assetImages[rand.nextInt(assetImages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF101A30) : Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Imagen de fondo con overlay mejorado
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_home.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Gradient overlay profesional
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E).withOpacity(isDark ? 0.5 : 0.3),
                  Color(0xFF3949AB).withOpacity(isDark ? 0.4 : 0.2),
                  Color(0xFF1976D2).withOpacity(isDark ? 0.5 : 0.3),
                  Colors.black.withOpacity(isDark ? 0.6 : 0.4),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Barra superior moderna
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 18),
                    child: const CartIconWithBadge(iconColor: Colors.white, iconSize: 22),
                  ),
                ),
                // Expanded con cards modernas para sliders y municipalidades
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card de municipalidades (Tus búsquedas recientes)
                        Obx(() {
                          final resumen = controller.resumenData.value;
                          if (resumen == null || resumen.municipalidades.isEmpty) return SizedBox.shrink();
                          return _buildModernCardSection(
                            context,
                            title: 'Tus búsquedas recientes',
                            child: SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: resumen.municipalidades.length,
                                separatorBuilder: (_, __) => SizedBox(width: 16),
                                itemBuilder: (ctx, i) {
                                  final muni = resumen.municipalidades[i];
                                  return _buildMunicipalidadCard(muni, isDark);
                                },
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 18),
                        // El contenido original (título, subtítulo, botones)
                        _buildBottomContentCentered(screenWidth, screenHeight),
                      ],
                    ),
                  ),
                ),
                // Bottom Navigation (ahora con las opciones superiores)
                _buildBottomNavigation(screenWidth),
              ],
            ),
          ),

          // Overlay para cerrar dropdown
          Obx(() => controller.showProfileDropdown.value
              ? GestureDetector(
                  onTap: () => controller.hideProfileDropdown(),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : SizedBox.shrink()),
                
          // Profile Dropdown Menu MEJORADO
          Obx(() => controller.showProfileDropdown.value
              ? _buildProfileDropdownBottom(screenWidth, screenHeight)
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBottomContentCentered(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: screenHeight * 0.16, left: screenWidth * 0.08, right: screenWidth * 0.08, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal alineado a la izquierda
          Text(
            'Turismo\nCapachica',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth < 400 ? 48 : 64,
              fontWeight: FontWeight.w900,
              height: 1.0,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.7),
                ),
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.4),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Subtítulo alineado a la izquierda
          Text(
            'Descubre la magia del lago Titicaca',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: screenWidth < 400 ? 20 : 24,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              shadows: [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.6),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.08),
          // Botones de acción alineados a la izquierda
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildActionButton(
                'Ver Planes',
                Icons.map,
                false,
                () => controller.onHotelsTap(),
                screenWidth,
              ),
              SizedBox(width: 16),
              _buildActionButton(
                'Servicios',
                Icons.explore_outlined,
                true,
                () => controller.onToursTap(),
                screenWidth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, bool isFilled, VoidCallback onTap, double screenWidth) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth < 400 ? 140 : 160,
        height: 60,
        child: Stack(
          children: [
            // Fondo base del botón
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: isFilled
                    ? Color(0xFFFF9100).withOpacity(0.9)
                    : Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            
            // Efecto neón tipo serpiente/gusano
            AnimatedBuilder(
              animation: controller.neonAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(double.infinity, double.infinity),
                  painter: NeonSnakePainter(
                    progress: controller.neonAnimation.value,
                    color: isFilled
                        ? Color(0xFFFF9100)
                        : Colors.cyan,
                    secondaryColor: isFilled
                        ? Color(0xFFFFE082)
                        : Colors.purple,
                  ),
                );
              },
            ),
            
            // Contenido del botón
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: screenWidth < 400 ? 20 : 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth < 400 ? 15 : 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: isFilled
                              ? Color(0xFFFF9100).withOpacity(0.8)
                              : Colors.cyan.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
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

  Widget _buildBottomNavigation(double screenWidth) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Obx(
            () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(
                Icons.home_outlined,
                Icons.home,
                'Inicio',
                controller.selectedTopNav.value == 'Inicio',
                screenWidth
            ),
            _buildBottomNavItem(
                Icons.store_outlined,
                Icons.store,
                'Emprendimientos',
                controller.selectedTopNav.value == 'Emprendimientos',
                screenWidth
            ),
            _buildBottomNavItem(
                Icons.event_outlined,
                Icons.event,
                'Eventos',
                controller.selectedTopNav.value == 'Eventos',
                screenWidth
            ),
            _buildBottomNavItem(
                Icons.person_outline,
                Icons.person,
                'Mi Perfil',
                controller.selectedTopNav.value == 'Mi Perfil',
                screenWidth
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData outlinedIcon, IconData filledIcon, String label, bool isSelected, double screenWidth) {
    final selectedColor = Color(0xFFFF9100);
    return GestureDetector(
      onTap: () {
        if (label == 'Mi Perfil') {
          controller.toggleProfileDropdown();
        } else {
          controller.onTopNavTap(label);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: label == 'Inicio' && controller.isLoadingResumen.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(selectedColor),
                      ),
                    )
                  : Icon(
                      isSelected ? filledIcon : outlinedIcon,
                      key: ValueKey(isSelected),
                      color: isSelected ? selectedColor : Colors.white,
                      size: isSelected ? 26 : 24,
                    ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : Colors.white,
                fontSize: screenWidth < 400 ? 10 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // MENÚ DE PERFIL COMPACTO Y ELEGANTE
  Widget _buildProfileDropdownBottom(double screenWidth, double screenHeight) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 110, // Justo encima de la navegación inferior
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, -8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF8F9FA),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header compacto
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1976D2).withOpacity(0.05),
                        Color(0xFF3949AB).withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar compacto
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1976D2),
                              Color(0xFF3949AB),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1976D2).withOpacity(0.25),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.authService.isLoggedIn ? 'Mi Cuenta' : '¡Hola!',
                              style: TextStyle(
                                color: Color(0xFF1A237E),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              controller.authService.isLoggedIn ? 'Gestiona tu perfil' : 'Inicia sesión para continuar',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón de cierre compacto
                      GestureDetector(
                        onTap: () => controller.hideProfileDropdown(),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu items compactos
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Obx(
                    () => Column(
                      children: controller.authService.isLoggedIn
                          ? [
                              _buildCompactDropdownItem(
                                icon: Icons.account_circle_rounded,
                                title: 'Mi Cuenta',
                                onTap: () => controller.onMyAccountTap(),
                                color: Color(0xFF1976D2),
                              ),
                              _buildCompactDropdownItem(
                                icon: Icons.bookmark_rounded,
                                title: 'Mis Reservas',
                                onTap: () => controller.onMyReservationsTap(),
                                color: Color(0xFFFF9100),
                              ),
                              _buildCompactDropdownItem(
                                icon: Icons.shopping_cart_rounded,
                                title: 'Mi Carrito',
                                onTap: () => controller.onMyCartTap(),
                                color: Color(0xFFE91E63),
                              ),
                              _buildCompactDropdownItem(
                                icon: Icons.settings_rounded,
                                title: 'Configuración',
                                onTap: () => controller.onSettingsTap(),
                                color: Color(0xFF424242),
                              ),
                              // Separador sutil
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                height: 1,
                                color: Colors.grey[200],
                              ),
                              _buildCompactDropdownItem(
                                icon: Icons.logout_rounded,
                                title: 'Cerrar Sesión',
                                onTap: () => controller.onLogoutTap(),
                                color: Color(0xFFD32F2F),
                                isLogout: true,
                              ),
                            ]
                          : [
                              // Botón de Iniciar Sesión compacto
                              _buildCompactLoginButton(),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Item compacto del dropdown
  Widget _buildCompactDropdownItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Icono compacto
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLogout ? Color(0xFFD32F2F) : Color(0xFF1A237E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Flecha compacta
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Botón compacto para iniciar sesión
  Widget _buildCompactLoginButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.onLoginTap(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF43A047),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2E7D32).withOpacity(0.25),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Agregar widgets auxiliares para cards modernas
  Widget _buildModernCardSection(BuildContext context, {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF222B45),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF22325A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.18) : Colors.grey.withOpacity(0.10),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalidadCard(muni, bool isDark) {
    String url = 'https://images.unsplash.com/photo-1464983953574-0892a716854b';
    if (muni.slidersPrincipales.isNotEmpty &&
        muni.slidersPrincipales.first.imageUrl.isNotEmpty) {
      url = muni.slidersPrincipales.first.imageUrl;
    }

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      muni.nombre,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (muni.descripcion != null && muni.descripcion.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          muni.descripcion,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter personalizado para el efecto neón tipo serpiente
class NeonSnakePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color secondaryColor;

  NeonSnakePainter({
    required this.progress,
    required this.color,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = 30.0;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    // Crear el path del perímetro del botón
    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;
    
    // Configurar el paint para el efecto neón
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    
    // Configurar el paint para el resplandor
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    
    // Longitud del "gusano" neón (30% del perímetro)
    final snakeLength = pathLength * 0.3;
    
    // Posición actual del gusano basada en el progreso
    final currentPosition = progress * pathLength;
    
    // Dibujar el rastro del gusano con degradado
    final segments = 20; // Número de segmentos para el degradado
    
    for (int i = 0; i < segments; i++) {
      final segmentProgress = i / segments;
      final segmentPosition = currentPosition - (snakeLength * segmentProgress);
      
      // Asegurar que la posición esté dentro del rango
      final normalizedPosition = segmentPosition % pathLength;
      if (normalizedPosition < 0) continue;
      
      final segmentStart = normalizedPosition;
      final segmentEnd = (segmentStart + snakeLength / segments).clamp(0.0, pathLength);
      
      if (segmentStart >= segmentEnd) continue;
      
      // Calcular la opacidad del segmento (más brillante al frente)
      final opacity = (1.0 - segmentProgress) * 0.8;
      
      // Color del segmento con degradado
      final segmentColor = Color.lerp(
        secondaryColor.withOpacity(opacity * 0.3),
        color.withOpacity(opacity),
        1.0 - segmentProgress,
      )!;
      
      // Dibujar resplandor
      glowPaint.color = segmentColor.withOpacity(opacity * 0.3);
      final glowPath = _extractPathSegment(pathMetrics, segmentStart, segmentEnd);
      canvas.drawPath(glowPath, glowPaint);
      
      // Dibujar línea principal
      paint.color = segmentColor;
      final mainPath = _extractPathSegment(pathMetrics, segmentStart, segmentEnd);
      canvas.drawPath(mainPath, paint);
    }
    
    // Dibujar la "cabeza" del gusano más brillante
    final headPosition = currentPosition % pathLength;
    final headLength = snakeLength * 0.1;
    final headEnd = (headPosition + headLength).clamp(0.0, pathLength);
    
    // Resplandor de la cabeza
    glowPaint.color = color.withOpacity(0.6);
    glowPaint.strokeWidth = 12.0;
    final headGlowPath = _extractPathSegment(pathMetrics, headPosition, headEnd);
    canvas.drawPath(headGlowPath, glowPaint);
    
    // Cabeza principal
    paint.color = color;
    paint.strokeWidth = 6.0;
    final headPath = _extractPathSegment(pathMetrics, headPosition, headEnd);
    canvas.drawPath(headPath, paint);
  }
  
  Path _extractPathSegment(ui.PathMetric pathMetric, double start, double end) {
    if (start >= end) return Path();
    return pathMetric.extractPath(start, end);
  }

  @override
  bool shouldRepaint(covariant NeonSnakePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.secondaryColor != secondaryColor;
  }
}