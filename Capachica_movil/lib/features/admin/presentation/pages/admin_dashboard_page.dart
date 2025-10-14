import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDashboardCard(
            context: context,
            icon: Icons.article_outlined,
            title: 'Gestionar Planes',
            subtitle: 'Crear, editar y eliminar planes turísticos.',
            routeName: AppRoutes.adminPlans, // Navega a la lista de planes
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context: context,
            icon: Icons.assignment_ind_outlined,
            title: 'Gestionar Inscripciones',
            subtitle: 'Ver y administrar las inscripciones a los planes.',
            routeName: AppRoutes.adminPlanInscripciones, // Navega a la lista de inscripciones
          ),
          // Aquí podrás añadir más opciones en el futuro (ej. Estadísticas, Usuarios, etc.)
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}