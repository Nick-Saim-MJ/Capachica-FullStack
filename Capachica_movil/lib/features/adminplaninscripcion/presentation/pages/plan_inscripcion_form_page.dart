import 'package:flutter/material.dart';
import '../../data/model/plan_inscripcion_model.dart';

class PlanInscripcionDetailPage extends StatelessWidget {
  final PlanInscripcionModel inscripcion;

  const PlanInscripcionDetailPage({super.key, required this.inscripcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Inscripción #${inscripcion.id}'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              shadowColor: Colors.tealAccent,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Inscripción #${inscripcion.id}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    buildRow(icon: Icons.person, label: 'Usuario ID', value: '${inscripcion.userId}'),
                    buildRow(icon: Icons.event_note, label: 'Plan ID', value: '${inscripcion.planId}'),
                    buildRow(icon: Icons.check_circle_outline, label: 'Estado', value: '${inscripcion.estado}'),
                    buildRow(icon: Icons.calendar_today, label: 'Fecha de inscripción', value: '${inscripcion.fechaInscripcion}'),
                    buildRow(icon: Icons.people, label: 'Participantes', value: '${inscripcion.numeroParticipantes}'),
                    buildRow(icon: Icons.monetization_on, label: 'Precio pagado', value: 'S/ ${inscripcion.precioPagado?.toStringAsFixed(2) ?? '0.00'}'),

                    if (inscripcion.comentariosAdicionales != null && inscripcion.comentariosAdicionales!.isNotEmpty)
                      buildRow(icon: Icons.comment, label: 'Comentarios adicionales', value: inscripcion.comentariosAdicionales!),

                    if (inscripcion.metodoPago != null)
                      buildRow(icon: Icons.payment, label: 'Método de pago', value: inscripcion.metodoPago!),

                    if (inscripcion.notasUsuario != null && inscripcion.notasUsuario!.isNotEmpty)
                      buildRow(icon: Icons.directions_bus, label: 'Notas transporte', value: inscripcion.notasUsuario!),

                    if (inscripcion.fechaInicioPlan != null)
                      buildRow(icon: Icons.date_range, label: 'Fecha del plan', value: inscripcion.fechaInicioPlan!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper para crear filas seguras
  Widget buildRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
