// lib/features/asociaciones/presentation/pages/emprendedores_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/asociacion_bloc.dart';
import '../bloc/asociacion_event.dart';
import '../bloc/asociacion_state.dart';

class EmprendedoresPage extends StatefulWidget {
  final int asociacionId;
  final String? asociacionNombre;

  const EmprendedoresPage({
    super.key,
    required this.asociacionId,
    this.asociacionNombre,
  });

  @override
  State<EmprendedoresPage> createState() => _EmprendedoresPageState();
}

class _EmprendedoresPageState extends State<EmprendedoresPage> {
  @override
  void initState() {
    super.initState();
    // Fallback por si no se envió el evento al navegar
    context
        .read<AsociacionBloc>()
        .add(LoadEmprendedoresByAsociacion(widget.asociacionId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Emprendedores',
          style: const TextStyle(
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
                  ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
                  : [Colors.lightBlue.shade400, Colors.lightBlue.shade600],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header con nombre de asociación
          if (widget.asociacionNombre != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Row(
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
                    child: const Icon(
                      Icons.business_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Asociación',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.asociacionNombre!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Contenido
          Expanded(
            child: BlocBuilder<AsociacionBloc, AsociacionState>(
              builder: (context, state) {
                if (state is EmprendedoresLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                    ),
                  );
                }

                if (state is EmprendedoresError) {
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
                            onPressed: () {
                              context.read<AsociacionBloc>().add(
                                  LoadEmprendedoresByAsociacion(widget.asociacionId));
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade400,
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

                if (state is EmprendedoresLoaded) {
                  final items = state.emprendedores;
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
                                color: Colors.lightBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.people_outline_rounded,
                                size: 64,
                                color: Colors.lightBlue.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No hay emprendedores',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Esta asociación aún no tiene emprendedores registrados',
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
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final e = items[i];
                      return _EmprendedorCard(
                        emprendedor: e,
                        isDark: isDark,
                      );
                    },
                  );
                }

                // Fallback defensivo: si llegamos aquí, disparamos carga
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context
                        .read<AsociacionBloc>()
                        .add(LoadEmprendedoresByAsociacion(widget.asociacionId));
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmprendedorCard extends StatelessWidget {
  final dynamic emprendedor;
  final bool isDark;

  const _EmprendedorCard({
    required this.emprendedor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final foto = (emprendedor.foto is String && (emprendedor.foto as String).isNotEmpty)
        ? emprendedor.foto as String
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
              : [Colors.lightBlue.shade50, Colors.white],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlue.withOpacity(0.2),
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
            // TODO: Navegar a detalle del emprendedor si existe la página
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto del emprendedor
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.lightBlue.shade400,
                        Colors.lightBlue.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: foto != null
                        ? Image.network(
                            foto,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Información del emprendedor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emprendedor.nombreCompleto ?? emprendedor.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (emprendedor.descripcion != null && emprendedor.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          emprendedor.descripcion!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Información de contacto
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.white.withOpacity(0.05)
                              : Colors.lightBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            if (emprendedor.telefono != null && emprendedor.telefono!.isNotEmpty)
                              _ContactRow(
                                icon: Icons.phone_rounded,
                                text: emprendedor.telefono!,
                                color: Colors.green,
                                isDark: isDark,
                              ),
                            if (emprendedor.email != null && emprendedor.email!.isNotEmpty) ...[
                              if (emprendedor.telefono != null && emprendedor.telefono!.isNotEmpty)
                                const SizedBox(height: 6),
                              _ContactRow(
                                icon: Icons.email_rounded,
                                text: emprendedor.email!,
                                color: Colors.orange,
                                isDark: isDark,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Icono de flecha
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isDark;

  const _ContactRow({
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
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
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
