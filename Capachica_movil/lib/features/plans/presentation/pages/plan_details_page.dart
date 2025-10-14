import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/core/routes/app_routes.dart';
import 'package:aplicativo_capachica/features/admin/data/models/admin_plan_model.dart' as admin_model;
import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_bloc.dart';
import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_state.dart';
import 'package:aplicativo_capachica/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/plan.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_event.dart';

class PlanDetailsPage extends StatelessWidget {
  final PlanEntity plan;

  const PlanDetailsPage({Key? key, required this.plan}) : super(key: key);

  void _navigateToEditForm(BuildContext context, admin_model.AdminPlanModel adminPlan) {
    Navigator.pushNamed(
      context,
      AppRoutes.adminPlanForm,
      arguments: adminPlan,
    ).then((result) {
      if (result == true) {
        context.read<PlanBloc>().add(FetchPublicPlans());
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const String baseUrl = BackendConfig.baseUrl;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider.value(
      value: context.read<AdminPlansBloc>(),
      child: BlocListener<AdminPlansBloc, AdminPlansState>(
        listener: (context, state) {
          if (state is AdminPlanOperationSuccess) {
            context.read<PlanBloc>().add(FetchPublicPlans());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ ${state.message}')),
            );
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            bool isAdmin = authState is AuthAuthenticated &&
                authState.user.roles.map((r) => r.toLowerCase()).contains('admin');

            return Scaffold(
              backgroundColor: Colors.grey[50],
              body: CustomScrollView(
                slivers: [
                  // App Bar con imagen
                  SliverAppBar(
                    expandedHeight: screenHeight * 0.35,
                    pinned: true,
                    backgroundColor: Colors.amber[800],
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.amber[800], size: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      if (isAdmin)
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit_note_rounded, color: Colors.amber[800], size: 20),
                          ),
                          onPressed: () {
                            final adminPlan = admin_model.AdminPlanModel(
                              id: plan.id,
                              title: plan.nombre,
                              description: plan.descripcion,
                              price: plan.precioTotal ?? 0.0,
                              duration: plan.duracionDias,
                              isActive: plan.estado == 'activo',
                              capacidad: plan.capacidad,
                              imagenPrincipalUrl: plan.imagenPrincipalUrl,
                              updatedAt: plan.updatedAt,
                              createdAt: plan.createdAt,
                            );
                            _navigateToEditForm(context, adminPlan);
                          },
                        ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (plan.imagenPrincipalUrl != null && plan.imagenPrincipalUrl!.isNotEmpty)
                            Image.network(
                              '$baseUrl/storage${plan.imagenPrincipalUrl}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
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
                                  child: Icon(Icons.landscape_outlined, color: Colors.white.withOpacity(0.3), size: 80),
                                );
                              },
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
                              child: Icon(Icons.landscape_outlined, color: Colors.white.withOpacity(0.3), size: 80),
                            ),
                          // Gradiente oscuro en la parte inferior
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 100,
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
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Contenido
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título y descripción
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      plan.nombre,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: plan.estado == 'activo'
                                            ? [Colors.green.shade400, Colors.green.shade600]
                                            : [Colors.grey.shade400, Colors.grey.shade600],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (plan.estado == 'activo' ? Colors.green : Colors.grey).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      plan.estado == 'activo' ? 'Activo' : 'Inactivo',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                plan.descripcion,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Cards de información
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoCard(
                                      icon: Icons.access_time_rounded,
                                      title: 'Duración',
                                      value: '${plan.duracionDias} día${plan.duracionDias > 1 ? 's' : ''}',
                                      gradient: [Colors.amber.shade600, Colors.amber.shade800],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoCard(
                                      icon: Icons.people_rounded,
                                      title: 'Capacidad',
                                      value: '${plan.cuposDisponibles}/${plan.capacidad}',
                                      gradient: [Colors.amber.shade600, Colors.amber.shade800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildPriceCard(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: _buildBottomBar(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade600,
            Colors.amber.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio Total',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'S/. ${plan.precioTotal?.toStringAsFixed(2) ?? 'N/A'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: plan.cuposDisponibles > 0
                  ? [Colors.amber.shade600, Colors.amber.shade800]
                  : [Colors.grey.shade400, Colors.grey.shade600],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: (plan.cuposDisponibles > 0 ? Colors.orange : Colors.grey).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: plan.cuposDisponibles > 0
                  ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Funcionalidad de reserva en desarrollo'),
                    backgroundColor: Colors.amber[800],
                  ),
                );
              }
                  : null,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      plan.cuposDisponibles > 0 ? Icons.calendar_today_rounded : Icons.block,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      plan.cuposDisponibles > 0 ? 'Reservar ahora' : 'Sin cupos disponibles',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}