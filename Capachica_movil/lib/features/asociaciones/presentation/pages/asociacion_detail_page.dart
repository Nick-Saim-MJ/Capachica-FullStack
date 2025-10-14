// lib/features/asociaciones/presentation/pages/asociacion_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/asociacion_bloc.dart';
import '../bloc/asociacion_event.dart';
import '../bloc/asociacion_state.dart';
import 'emprendedores_page.dart';

// Para crear un Bloc propio al navegar a Emprendedores
import '../../../../injection_container.dart' as di;

class AsociacionDetailPage extends StatefulWidget {
  final int asociacionId;

  const AsociacionDetailPage({
    super.key,
    required this.asociacionId,
  });

  @override
  State<AsociacionDetailPage> createState() => _AsociacionDetailPageState();
}

class _AsociacionDetailPageState extends State<AsociacionDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<AsociacionBloc>().add(LoadAsociacionById(widget.asociacionId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : Colors.grey.shade50,
      body: BlocBuilder<AsociacionBloc, AsociacionState>(
        builder: (context, state) {
          if (state is AsociacionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            );
          }

          if (state is AsociacionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error al cargar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<AsociacionBloc>()
                          .add(LoadAsociacionById(widget.asociacionId)),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AsociacionLoaded) {
            final asociacion = state.asociacion;
            final bool isActive = asociacion.estado ?? true;

            return CustomScrollView(
              slivers: [
                // AppBar con imagen de fondo
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (asociacion.imagen != null)
                          Image.network(
                            asociacion.imagen!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.amber.shade600,
                                    Colors.amber.shade800,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.business_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.amber.shade600,
                                  Colors.amber.shade800,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        // Gradiente oscuro para legibilidad
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Contenido
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: Column(
                      children: [
                        // Card principal con nombre y badges
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                asociacion.nombre,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              // Badges
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isActive 
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive ? Colors.green : Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isActive ? Icons.check_circle : Icons.cancel,
                                          size: 16,
                                          color: isActive ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isActive ? 'Activa' : 'Inactiva',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (asociacion.municipalidadNombre != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.amber,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_city,
                                            size: 16,
                                            color: Colors.amber.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            asociacion.municipalidadNombre!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Descripción
                        if (asociacion.descripcion.isNotEmpty)
                          _SectionCard(
                            isDark: isDark,
                            title: 'Descripción',
                            icon: Icons.description_rounded,
                            child: Text(
                              asociacion.descripcion,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        
                        // Información de contacto
                        _SectionCard(
                          isDark: isDark,
                          title: 'Información de Contacto',
                          icon: Icons.contact_phone_rounded,
                          child: Column(
                            children: [
                              if (asociacion.direccion != null && asociacion.direccion!.isNotEmpty)
                                _DetailInfoRow(
                                  icon: Icons.location_on_rounded,
                                  label: 'Dirección',
                                  value: asociacion.direccion!,
                                  color: Colors.amber.shade800,
                                  isDark: isDark,
                                ),
                              if (asociacion.telefono != null && asociacion.telefono!.isNotEmpty)
                                _DetailInfoRow(
                                  icon: Icons.phone_rounded,
                                  label: 'Teléfono',
                                  value: asociacion.telefono!,
                                  color: Colors.green,
                                  isDark: isDark,
                                ),
                              if (asociacion.email != null && asociacion.email!.isNotEmpty)
                                _DetailInfoRow(
                                  icon: Icons.email_rounded,
                                  label: 'Email',
                                  value: asociacion.email!,
                                  color: Colors.orange,
                                  isDark: isDark,
                                ),
                            ],
                          ),
                        ),
                        
                        // Ubicación
                        if (asociacion.latitud != null && asociacion.longitud != null)
                          _SectionCard(
                            isDark: isDark,
                            title: 'Ubicación',
                            icon: Icons.map_rounded,
                            child: Column(
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? Colors.grey.shade800.withOpacity(0.3)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.amber.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.map_rounded,
                                          size: 64,
                                          color: Colors.amber.shade700,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Mapa de ubicación',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.grey.shade900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lat: ${asociacion.latitud?.toStringAsFixed(6)}\nLng: ${asociacion.longitud?.toStringAsFixed(6)}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Botón Ver Emprendedores
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (_) => di.sl<AsociacionBloc>()
                                      ..add(LoadEmprendedoresByAsociacion(asociacion.id)),
                                    child: EmprendedoresPage(
                                      asociacionId: asociacion.id,
                                      asociacionNombre: asociacion.nombre,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people_rounded, size: 24, color: Colors.white),
                            label: const Text(
                              'Ver Emprendedores',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: Colors.amber.withOpacity(0.4),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Text(
              'No hay datos disponibles',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widget para secciones con título
class _SectionCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.isDark,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightBlue.shade400,
                        Colors.lightBlue.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// Widget para filas de información detallada
class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
