// lib/features/municipalidades/presentation/pages/municipalidad_page.dart
import 'package:aplicativo_capachica/features/municipalidades/presentation/pages/municipalidad_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/municipalidad_bloc.dart';
import '../bloc/municipalidad_event.dart';
import '../bloc/municipalidad_state.dart';
import 'MunicipalidadFormEditPage.dart';

class MunicipalidadPage extends StatefulWidget {
  const MunicipalidadPage({super.key});

  @override
  State<MunicipalidadPage> createState() => _MunicipalidadPageState();
}

class _MunicipalidadPageState extends State<MunicipalidadPage> {
  @override
  void initState() {
    super.initState();
    // Cargar las municipalidades al iniciar la página
    context.read<MunicipalidadBloc>().add(LoadMunicipalidades());
  }

  Future<void> _editarMunicipalidad(municipalidad) async {
    // Navegar al formulario de edición y esperar resultado
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MunicipalidadFormEditPage(municipalidad: municipalidad),
      ),
    );

    // Si el resultado es true, recargar la lista
    if (result == true) {
      context.read<MunicipalidadBloc>().add(LoadMunicipalidades());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Municipalidades'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
      ),
      body: BlocBuilder<MunicipalidadBloc, MunicipalidadState>(
        builder: (context, state) {
          if (state is MunicipalidadLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MunicipalidadLoaded) {
            if (state.municipalidades.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_city, size: 56, color: Colors.amber[800]),
                    const SizedBox(height: 8),
                    const Text('No hay municipalidades'),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.municipalidades.length,
              itemBuilder: (context, index) {
                final municipalidad = state.municipalidades[index];
                return MunicipalidadCard(
                  municipalidad: municipalidad,
                  onTap: () {
                    // Aquí puedes navegar a la página de detalle
                  },
                  onEdit: () {
                    _editarMunicipalidad(municipalidad);
                  },
                );
              },
            );
          } else if (state is MunicipalidadError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
