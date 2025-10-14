// lib/features/asociaciones/presentation/pages/asociaciones_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/asociacion_bloc.dart';
import '../bloc/asociacion_event.dart';
import '../bloc/asociacion_state.dart';

import 'asociacion_detail_page.dart';
import 'asociaciones_by_municipalidad_page.dart';
import 'asociaciones_by_location_page.dart';
import 'asociacion_form_page.dart';

// ⚠️ Ajusta esta ruta si tu estructura cambia
import '../../../../injection_container.dart' as di;
import '../../../../core/widgets/role_visibility.dart';

class AsociacionesPage extends StatefulWidget {
  const AsociacionesPage({super.key});

  @override
  State<AsociacionesPage> createState() => _AsociacionesPageState();
}

class _AsociacionesPageState extends State<AsociacionesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AsociacionBloc>().add(LoadAsociaciones());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.8) {
      context.read<AsociacionBloc>().add(LoadMoreAsociaciones());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Asociaciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.amber.shade700, Colors.amber.shade800]
                  : [Colors.amber.shade600, Colors.amber.shade800],
            ),
          ),
        ),
        actions: [
          // Botón para crear nueva asociación (solo admin)
          RoleVisibility(
            anyOf: ['admin'],
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Crear nueva asociación',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AsociacionBloc>(),
                      child: const AsociacionFormPage(),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            tooltip: 'Buscar por ubicación',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AsociacionesByLocationPage(),
                ),
              );
              // Si quieres refrescar al volver:
              // ignore: use_build_context_synchronously
              // context.read<AsociacionBloc>().add(LoadAsociaciones());
            },
          ),
          IconButton(
            icon: const Icon(Icons.location_city),
            tooltip: 'Por municipalidad',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AsociacionesByMunicipalidadPage(),
                ),
              );
              // Opcional refrescar:
              // ignore: use_build_context_synchronously
              // context.read<AsociacionBloc>().add(LoadAsociaciones());
            },
          ),
        ],
      ),
      body: BlocListener<AsociacionBloc, AsociacionState>(
        listener: (context, state) {
          if (state is AsociacionCrudError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Error: ${state.message}')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is AsociacionDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Asociación eliminada exitosamente'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar asociaciones...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.amber[800],
                    size: 24,
                  ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade400,
                          ),
                  onPressed: () {
                    _searchController.clear();
                            setState(() {});
                    context.read<AsociacionBloc>().add(ClearFilter());
                  },
                )
                    : null,
                  filled: true,
                  fillColor: isDark 
                      ? Colors.grey.shade800.withOpacity(0.3)
                      : Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.amber.shade800,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
              ),
              onChanged: (value) {
                  setState(() {});
                if (value.isEmpty) {
                  context.read<AsociacionBloc>().add(ClearFilter());
                } else {
                  context.read<AsociacionBloc>().add(FilterAsociaciones(value));
                }
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<AsociacionBloc, AsociacionState>(
              buildWhen: (previous, current) {
                // Reconstruir cuando cambie a estados de lista
                return current is AsociacionesLoading ||
                       current is AsociacionesLoaded ||
                       current is AsociacionesError ||
                       current is AsociacionesFiltered;
              },
              builder: (context, state) {
                if (state is AsociacionesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AsociacionesError) {
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
                            'Oops! Algo salió mal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                              state.message,
                            textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                          onPressed: () {
                            context.read<AsociacionBloc>().add(LoadAsociaciones());
                          },
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

                if (state is AsociacionesLoaded) {
                  final items = state.asociaciones.data;
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.business_rounded,
                                size: 64,
                                color: Colors.amber.shade700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No hay asociaciones',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no se han registrado asociaciones en el sistema',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AsociacionBloc>().add(RefreshAsociaciones());
                      await Future<void>.delayed(const Duration(milliseconds: 250));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: items.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _AsociacionCard(asociacion: items[index]);
                      },
                    ),
                  );
                }

                if (state is AsociacionesFiltered) {
                  final items = state.filteredAsociaciones;
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Colors.orange.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No hay coincidencias',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Intenta con otros términos de búsqueda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) => _AsociacionCard(asociacion: items[i]),
                  );
                }

                // Fallback defensivo: si el estado no es de lista, recarga.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<AsociacionBloc>().add(LoadAsociaciones());
                  }
                });
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _AsociacionCard extends StatelessWidget {
  final dynamic asociacion;
  const _AsociacionCard({required this.asociacion});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Confirmar eliminación'),
            ],
          ),
          content: Text('¿Estás seguro de que quieres eliminar la asociación "${asociacion.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AsociacionBloc>().add(DeleteAsociacion(asociacion.id));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String? logo = (asociacion.logo is String && (asociacion.logo as String).isNotEmpty)
        ? asociacion.logo as String
        : null;
    final bool isActive = asociacion.estado ?? true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.amber.shade700, Colors.amber.shade800]
              : [Colors.amber.shade50, Colors.white],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<AsociacionBloc>(),
                  child: AsociacionDetailPage(asociacionId: asociacion.id),
                ),
              ),
            ).then((_) {
              context.read<AsociacionBloc>().add(LoadAsociaciones());
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con logo y badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo con decoración
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.amber.shade600,
                            Colors.amber.shade800,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: logo != null
                            ? Image.network(
                                logo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.business_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              )
                            : const Icon(
                                Icons.business_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Nombre y badges
                    Expanded(
                      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          Text(
                            asociacion.nombre,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Badge de estado
              Row(
                children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                      size: 14,
                                      color: isActive ? Colors.green : Colors.red,
                                    ),
                  const SizedBox(width: 4),
                                    Text(
                                      isActive ? 'Activa' : 'Inactiva',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (asociacion.municipalidadNombre != null) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                children: [
                                        Icon(
                                          Icons.location_city,
                                          size: 12,
                                          color: Colors.amber.shade700,
                                        ),
                  const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            asociacion.municipalidadNombre,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.amber.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
              ),
            ],
          ],
        ),
                        ],
                      ),
                    ),
                    // Botones admin
            RoleVisibility(
              anyOf: ['admin'],
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.white : Colors.grey.shade700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(Icons.edit, color: Colors.blue, size: 20),
                                SizedBox(width: 12),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
              child: Row(
                              children: const [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 12),
                                Text('Eliminar'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AsociacionBloc>(),
                            child: AsociacionFormPage(asociacion: asociacion),
                          ),
                        ),
                      );
                          } else if (value == 'delete') {
                            _showDeleteDialog(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Descripción
                if (asociacion.descripcion != null && asociacion.descripcion.isNotEmpty)
                  Text(
                    asociacion.descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (asociacion.descripcion != null && asociacion.descripcion.isNotEmpty)
                  const SizedBox(height: 12),
                // Información de contacto
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.05)
                        : Colors.lightBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (asociacion.direccion != null && asociacion.direccion!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          text: asociacion.direccion!,
                          color: Colors.lightBlue,
                          isDark: isDark,
                        ),
                      if (asociacion.telefono != null && (asociacion.telefono as String).isNotEmpty) ...[
                        if (asociacion.direccion != null && asociacion.direccion!.isNotEmpty)
                          const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.phone_rounded,
                          text: asociacion.telefono,
                          color: Colors.green,
                          isDark: isDark,
                        ),
                      ],
                      if (asociacion.email != null && (asociacion.email as String).isNotEmpty) ...[
                        if ((asociacion.direccion != null && asociacion.direccion!.isNotEmpty) ||
                            (asociacion.telefono != null && (asociacion.telefono as String).isNotEmpty))
                          const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.email_rounded,
                          text: asociacion.email,
                          color: Colors.orange,
                          isDark: isDark,
                        ),
                      ],
                ],
              ),
            ),
                const SizedBox(height: 12),
                // Footer con acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.lightBlue.shade400,
                            Colors.lightBlue.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Ver detalles',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
