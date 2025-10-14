// Archivo: lib/presentation/widgets/servicios_relacionados_widget.dart

import 'package:aplicativo_capachica/features/servicio/data/models/servicio_model.dart';
import 'package:aplicativo_capachica/features/servicio/domain/entities/servicio.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicios_relacionados_cubit.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicios_relacionados_state.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/pages/servicio_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiciosRelacionadosWidget extends StatefulWidget {
  final ServiceEntity servicioActual;

  const ServiciosRelacionadosWidget({
    Key? key,
    required this.servicioActual,
  }) : super(key: key);

  @override
  State<ServiciosRelacionadosWidget> createState() => _ServiciosRelacionadosWidgetState();
}

class _ServiciosRelacionadosWidgetState extends State<ServiciosRelacionadosWidget> {

  @override
  void initState() {
    super.initState();
    final categoriaId = widget.servicioActual.categorias.isNotEmpty
        ? widget.servicioActual.categorias.first.id
        : 0;
    print('Categoria: $categoriaId');
    print(widget.servicioActual.id);

    context.read<ServiciosRelacionadosCubit>().fetchServiciosRelacionados(
      categoriaId,
      widget.servicioActual.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ServiciosRelacionadosCubit, ServiciosRelacionadosState>(
      builder: (context, state) {
        if (state is ServiciosRelacionadosLoading) {
          return _buildLoadingState(isDark);
        }

        if (state is ServiciosRelacionadosError) {
          return const SizedBox.shrink();
        }

        if (state is ServiciosRelacionadosLoaded) {
          if (state.servicios.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildContent(context, isDark, state.servicios);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildContent(
      BuildContext context,
      bool isDark,
      List<ServiceEntity> serviciosRelacionados,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Servicios Relacionados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Column(
                children: serviciosRelacionados.map((servicioRel) {
                  return Column(
                    children: [
                      _buildRelatedItem(context, isDark, servicioRel),
                      if (servicioRel != serviciosRelacionados.last)
                        const Divider(height: 1, thickness: 0.5),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedItem(
      BuildContext context,
      bool isDark,
      ServiceEntity servicioRel,
      ) {
    void verOtroServicio() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(servicio: servicioRel),
        ),
      );
    }

    return InkWell(
      onTap: verOtroServicio,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              servicioRel.nombre,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              servicioRel.emprendedor.nombre,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),

            if (servicioRel.precioReferencial.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'S/. ${servicioRel.precioReferencial}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}