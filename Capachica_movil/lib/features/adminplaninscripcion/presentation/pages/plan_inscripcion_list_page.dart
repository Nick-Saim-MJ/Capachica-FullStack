import 'package:aplicativo_capachica/features/adminplaninscripcion/presentation/pages/plan_inscripcion_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aplicativo_capachica/features/adminplaninscripcion/data/model/plan_inscripcion_model.dart';
import '../bloc/plan_inscripcion_bloc.dart';
import '../bloc/plan_inscripcion_event.dart';
import '../bloc/plan_inscripcion_state.dart';


class PlanInscripcionListPage extends StatefulWidget {
  const PlanInscripcionListPage({super.key});

  @override
  State<PlanInscripcionListPage> createState() => _PlanInscripcionListPageState();
}

class _PlanInscripcionListPageState extends State<PlanInscripcionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PlanInscripcionBloc>().add(LoadInscripciones());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Inscripciones'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PlanInscripcionBloc>().add(LoadInscripciones()),
          ),
        ],
      ),
      body: BlocBuilder<PlanInscripcionBloc, PlanInscripcionState>(
        builder: (context, state) {
          if (state is PlanInscripcionLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          if (state is PlanInscripcionLoaded) {
            if (state.inscripciones.isEmpty) {
              return const Center(
                child: Text(
                  'No hay inscripciones.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.inscripciones.length,
              itemBuilder: (context, index) {
                final inscripcion = state.inscripciones[index];

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade50, Colors.teal.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      title: Text(
                        'Inscripción #${inscripcion.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.teal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Plan ID: ${inscripcion.planId}'),
                          Text('Usuario ID: ${inscripcion.userId}'),
                          Text('Estado: ${inscripcion.estado}'),
                          Text('Fecha de inscripción: ${inscripcion.fechaInscripcion}'),
                          if (inscripcion.notasUsuario != null && inscripcion.notasUsuario!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Notas: ${inscripcion.notasUsuario}',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.teal),
                      onTap: () {
                        // Navegar a la página de detalle
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlanInscripcionDetailPage(inscripcion: inscripcion),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }

          if (state is PlanInscripcionError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          return const Center(
            child: Text(
              'Cargando inscripciones...',
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
