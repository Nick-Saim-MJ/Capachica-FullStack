import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/resumen_controller.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/cart_icon_with_badge.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ResumenScreen extends GetView<ResumenController> {
  const ResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF0F1419) : Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header moderno con gradiente
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 16, 
              right: 16, 
              top: MediaQuery.of(context).padding.top + 8, 
              bottom: 24
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [Color(0xFF1A2332), Color(0xFF2D3748)]
                  : [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Color(0xFFFF6B35).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra de navegación
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capachica Travel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Descubre lugares mágicos',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CartIconWithBadge(),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        onPressed: () => controller.loadResumen(),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ThemeToggleButton(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Barra de búsqueda elegante
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchText.value = value,
                    decoration: InputDecoration(
                      hintText: '🌎 ¿A dónde quieres viajar hoy?',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      prefixIcon: Container(
                        margin: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B35).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.search_rounded, 
                          color: Color(0xFFFF6B35),
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    ),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState(isDark);
              }
              if (controller.resumenError.value != null) {
                return _buildErrorState(controller.resumenError.value!, isDark);
              }
              final resumenData = controller.resumenData.value;
              if (resumenData == null) {
                return _buildEmptyState(isDark);
              }
              return RefreshIndicator(
                onRefresh: () async => controller.loadResumen(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 24),
                  children: [
                    // Categorías rápidas
                    _buildQuickCategories(context, isDark),
                    SizedBox(height: 18),
                    // Card de banners
                    if (resumenData.sliders.isNotEmpty)
                      _buildBannersSection(context, resumenData.sliders, isDark),
                    SizedBox(height: 18),
                    // Card de municipalidades
                    Obx(() {
                      final filtered = controller.filteredMunicipalidades;
                      if (filtered.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No se encontraron resultados', 
                              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: filtered.map<Widget>((muni) {
                          return _buildMunicipalidadCard(context, muni, isDark);
                        }).toList(),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBannersSection(BuildContext context, List<dynamic> sliders, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Ofertas Destacadas',
            style: TextStyle(
              color: isDark ? Colors.white : Color(0xFF1A202C),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4),
              itemCount: sliders.length,
              separatorBuilder: (_, __) => SizedBox(width: 16),
              itemBuilder: (ctx, i) {
                final slider = sliders[i];
                return _buildSliderCard(slider, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard(dynamic slider, bool isDark) {
    return Container(
      width: 320,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.3) 
              : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Imagen de fondo
            Container(
              width: double.infinity,
              height: double.infinity,
              child: slider.urlCompleta != null && slider.urlCompleta.isNotEmpty
                ? Image.network(
                    slider.urlCompleta,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/lugar-turistico6.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, assetError, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF6B35).withValues(alpha: 0.3),
                              Color(0xFFFF8E53).withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_rounded, 
                            size: 64, 
                            color: Colors.white.withValues(alpha: 0.7)
                          ),
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/lugar-turistico6.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B35).withValues(alpha: 0.3),
                            Color(0xFFFF8E53).withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_rounded, 
                          size: 64, 
                          color: Colors.white.withValues(alpha: 0.7)
                        ),
                      ),
                    ),
                  ),
            ),
            // Overlay con gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
              ),
            ),
            // Badge promocional
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, 
                         color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Destacado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Contenido inferior
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Oferta Especial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, 
                           color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Capachica, Puno',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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

  Widget _buildMunicipalidadCard(BuildContext context, dynamic muni, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A2332) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con información principal
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [Color(0xFF2D3748), Color(0xFF4A5568)]
                  : [Color(0xFFFF6B35).withValues(alpha: 0.1), Color(0xFFFF8E53).withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B35).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    color: Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        muni.nombre ?? 'Municipalidad',
                        style: TextStyle(
                          color: isDark ? Colors.white : Color(0xFF1A202C),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (muni.frase != null && muni.frase.isNotEmpty)
                        Text(
                          '"${muni.frase}"',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Color(0xFF718096),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Galería de imágenes mejorada
                if (muni.slidersPrincipales != null && muni.slidersPrincipales.isNotEmpty) ...[
                  Text(
                    '📸 Galería',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      itemCount: muni.slidersPrincipales.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12),
                      itemBuilder: (ctx, i) {
                        final slider = muni.slidersPrincipales[i];
                        return Container(
                          width: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: slider.urlCompleta != null && slider.urlCompleta.isNotEmpty
                                ? Image.network(
                                    slider.urlCompleta,
                                    fit: BoxFit.cover,
                                    width: 240,
                                    height: 160,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF6B35).withValues(alpha: 0.3),
                                            Color(0xFFFF8E53).withValues(alpha: 0.6),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.image_not_supported, 
                                               color: Colors.white, size: 48),
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B35).withValues(alpha: 0.3),
                                          Color(0xFFFF8E53).withValues(alpha: 0.6),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.image_rounded, 
                                             size: 48, color: Colors.white),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],
                // Descripción con diseño mejorado
                if (muni.descripcion != null && muni.descripcion.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                        ? Color(0xFF2D3748).withValues(alpha: 0.5)
                        : Color(0xFFFF6B35).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFFFF6B35).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFFF6B35),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Acerca de',
                              style: TextStyle(
                                color: Color(0xFFFF6B35),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          muni.descripcion,
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.9) : Color(0xFF4A5568),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                // Misión, Visión y Valores
                if ((muni.mision != null && muni.mision.isNotEmpty) || (muni.vision != null && muni.vision.isNotEmpty) || (muni.valores != null && muni.valores.isNotEmpty)) ...[
                  SizedBox(height: 16),
                  _buildMisionVisionValores(context, mision: muni.mision, vision: muni.vision, valores: muni.valores),
                ],
                // Redes sociales modernas
                if ((muni.redFacebook != null && muni.redFacebook.isNotEmpty) || 
                    (muni.redInstagram != null && muni.redInstagram.isNotEmpty) || 
                    (muni.redYoutube != null && muni.redYoutube.isNotEmpty)) ...[
                  Text(
                    '🌐 Síguenos',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                                     Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: [
                       if (muni.redFacebook != null && muni.redFacebook.isNotEmpty)
                         _buildSocialButton(
                           icon: Icons.facebook,
                           color: Color(0xFF1877F2),
                           label: 'Facebook',
                           onTap: () => launchUrlString(muni.redFacebook, mode: LaunchMode.externalApplication),
                         ),
                       if (muni.redInstagram != null && muni.redInstagram.isNotEmpty)
                         _buildSocialButton(
                           icon: Icons.camera_alt,
                           color: Color(0xFFE4405F),
                           label: 'Instagram',
                           onTap: () => launchUrlString(muni.redInstagram, mode: LaunchMode.externalApplication),
                         ),
                       if (muni.redYoutube != null && muni.redYoutube.isNotEmpty)
                         _buildSocialButton(
                           icon: Icons.play_circle_fill,
                           color: Color(0xFFFF0000),
                           label: 'YouTube',
                           onTap: () => launchUrlString(muni.redYoutube, mode: LaunchMode.externalApplication),
                         ),
                     ],
                   ),
                  SizedBox(height: 16),
                ],
                // Información adicional
                if (muni.comunidades != null && muni.comunidades.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Comunidades:', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(muni.comunidades, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                ],
                if (muni.historiaFamilias != null && muni.historiaFamilias.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Historia de las Familias:', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(muni.historiaFamilias, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                ],
                if (muni.historiaCapachica != null && muni.historiaCapachica.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Historia de Capachica:', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(muni.historiaCapachica, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                ],
                if (muni.comite != null && muni.comite.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Comité de Turismo:', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(muni.comite, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                ],
                if (muni.alianzas != null && muni.alianzas.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Alianzas:', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(muni.alianzas, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                ],
                if (muni.ordenanzaMunicipal != null && muni.ordenanzaMunicipal.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Ordenanza Municipal:', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text(muni.ordenanzaMunicipal, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                ],
                // Información de contacto mejorada
                if ((muni.correo != null && muni.correo.isNotEmpty) || 
                    (muni.horarioDeAtencion != null && muni.horarioDeAtencion.isNotEmpty)) ...[
                  Text(
                    '📞 Información de Contacto',
                    style: TextStyle(
                      color: isDark ? Colors.white : Color(0xFF1A202C),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (muni.correo != null && muni.correo.isNotEmpty)
                    _buildContactInfo(
                      icon: Icons.email_rounded,
                      label: 'Correo electrónico',
                      value: muni.correo,
                      color: Color(0xFF10B981),
                      isDark: isDark,
                    ),
                  if (muni.horarioDeAtencion != null && muni.horarioDeAtencion.isNotEmpty) ...[
                    SizedBox(height: 8),
                    _buildContactInfo(
                      icon: Icons.access_time_rounded,
                      label: 'Horario de atención',
                      value: muni.horarioDeAtencion,
                      color: Color(0xFF3B82F6),
                      isDark: isDark,
                    ),
                  ],
                  SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
          ? Color(0xFF2D3748).withValues(alpha: 0.3)
          : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Color(0xFF4A5568),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMisionVisionValores(
    BuildContext context, {
    String? mision,
    String? vision,
    String? valores,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 Propósito Institucional',
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xFF1A202C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        if (mision != null && mision.isNotEmpty) ...[
          _buildMVVCard(
            title: 'Misión',
            content: mision,
            icon: Icons.flag_rounded,
            color: Color(0xFF3B82F6),
            isDark: isDark,
          ),
          SizedBox(height: 12),
        ],
        if (vision != null && vision.isNotEmpty) ...[
          _buildMVVCard(
            title: 'Visión',
            content: vision,
            icon: Icons.visibility_rounded,
            color: Color(0xFF10B981),
            isDark: isDark,
          ),
          SizedBox(height: 12),
        ],
        if (valores != null && valores.isNotEmpty) ...[
          _buildMVVCard(
            title: 'Valores',
            content: valores,
            icon: Icons.favorite_rounded,
            color: Color(0xFFEF4444),
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildMVVCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
          ? Color(0xFF2D3748).withValues(alpha: 0.4)
          : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Color(0xFF4A5568),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories(BuildContext context, bool isDark) {
    final categories = [
      {'name': '🏨 Hospedajes', 'icon': Icons.hotel_rounded, 'color': Color(0xFF3B82F6)},
      {'name': '🍽️ Restaurantes', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFEF4444)},
      {'name': '🚣 Actividades', 'icon': Icons.directions_boat_rounded, 'color': Color(0xFF10B981)},
      {'name': '🎒 Tours', 'icon': Icons.backpack_rounded, 'color': Color(0xFFFF6B35)},
      {'name': '🛍️ Artesanías', 'icon': Icons.local_mall_rounded, 'color': Color(0xFF8B5CF6)},
      {'name': '🏛️ Cultura', 'icon': Icons.account_balance_rounded, 'color': Color(0xFFF59E0B)},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ Explorar por categoría',
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
             children: categories.map((category) {
               final color = category['color'] as Color;
               final icon = category['icon'] as IconData;
               final name = category['name'] as String;
               
               return Container(
                 decoration: BoxDecoration(
                   color: isDark 
                     ? Color(0xFF2D3748).withValues(alpha: 0.6)
                     : color.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(
                     color: color.withValues(alpha: 0.3),
                     width: 1,
                   ),
                   boxShadow: [
                     BoxShadow(
                       color: color.withValues(alpha: 0.1),
                       blurRadius: 8,
                       offset: Offset(0, 2),
                     ),
                   ],
                 ),
                 child: InkWell(
                   onTap: () {
                     // Aquí puedes agregar navegación a cada categoría
                     // Get.toNamed('/categoria', parameters: {'tipo': name});
                   },
                   borderRadius: BorderRadius.circular(16),
                   child: Container(
                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Container(
                           padding: EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: color.withValues(alpha: 0.2),
                             borderRadius: BorderRadius.circular(10),
                           ),
                           child: Icon(
                             icon,
                             color: color,
                             size: 18,
                           ),
                         ),
                         SizedBox(width: 8),
                         Text(
                           name,
                           style: TextStyle(
                             color: isDark ? Colors.white : color,
                             fontSize: 14,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               );
             }).toList(),
          ),
        ],
             ),
     );
   }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
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
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Cargando información...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Color(0xFF1A202C),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Obteniendo los datos más recientes',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Color(0xFF718096),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark 
            ? Color(0xFF2D3748).withValues(alpha: 0.5)
            : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.2),
            width: 1,
          ),
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
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Algo salió mal',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: isDark ? Colors.white70 : Color(0xFF718096),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.loadResumen(),
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark 
            ? Color(0xFF2D3748).withValues(alpha: 0.5)
            : Colors.white,
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
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.explore_off_rounded,
                color: Color(0xFFFF6B35),
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No hay datos disponibles',
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A202C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Por el momento no tenemos información para mostrar. Intenta nuevamente más tarde.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Color(0xFF718096),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.loadResumen(),
              icon: Icon(Icons.refresh_rounded, size: 20),
              label: Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}  