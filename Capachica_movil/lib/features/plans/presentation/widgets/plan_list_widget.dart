import 'package:aplicativo_capachica/core/config/backend_config.dart';
import 'package:aplicativo_capachica/features/admin/data/models/admin_plan_model.dart' as admin_model;
import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_bloc.dart';
import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_event.dart';
import 'package:aplicativo_capachica/features/admin/presentation/bloc/admin_plans_state.dart';
import 'package:aplicativo_capachica/features/admin/presentation/pages/admin_plan_form_page.dart';
import 'package:aplicativo_capachica/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/plan.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_event.dart';
import '../bloc/plan_state.dart';
import '../pages/plan_details_page.dart';
import '../../../../injection_container.dart' as di;

class PlanListWidget extends StatefulWidget {
  const PlanListWidget({Key? key}) : super(key: key);

  @override
  State<PlanListWidget> createState() => _PlanListWidgetState();
}

class _PlanListWidgetState extends State<PlanListWidget> {
  String _searchQuery = "";
  late AdminPlansBloc _adminPlansBloc;

  @override
  void initState() {
    super.initState();
    _adminPlansBloc = di.sl<AdminPlansBloc>();
    // Cargar la lista pública al inicio
    context.read<PlanBloc>().add(FetchPublicPlans());
  }

  @override
  void dispose() {
    _adminPlansBloc.close();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, PlanEntity plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Deseas eliminar "${plan.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _adminPlansBloc.add(DeletePlan(plan.id));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToForm({admin_model.AdminPlanModel? plan}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _adminPlansBloc,
          child: AdminPlanFormPage(initialPlan: plan),
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<PlanBloc>().add(FetchPublicPlans());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _adminPlansBloc,
      child: BlocListener<AdminPlansBloc, AdminPlansState>(
        listener: (context, state) {
          if (state is AdminPlanOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ ${state.message}'), backgroundColor: Colors.green),
            );
            // Actualizamos la lista pública automáticamente
            context.read<PlanBloc>().add(FetchPublicPlans());
          } else if (state is AdminPlansError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            bool isAdmin = authState is AuthAuthenticated &&
                authState.user.roles.map((r) => r.toLowerCase()).contains('admin');

            return Scaffold(
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar plan por nombre...',
                        prefixIcon: Icon(Icons.search, color: Colors.amber[800]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<PlanBloc, PlanState>(
                      builder: (context, state) {
                        if (state is PlanLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is PlanLoaded) {
                          final filtered = state.plans.where((p) => p.nombre.toLowerCase().contains(_searchQuery)).toList();

                          filtered.sort((a, b) {
                            if (a.updatedAt == null || b.updatedAt == null) return 0;
                            return b.updatedAt!.compareTo(a.updatedAt!);
                          });

                          return _buildPlansList(context, filtered, isAdmin);
                        } else if (state is PlanError) {
                          return Center(child: Text('Error: ${state.message}'));
                        }
                        return const Center(child: Text('Cargando planes...'));
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: isAdmin
                  ? FloatingActionButton(
                onPressed: () => _navigateToForm(),
                tooltip: 'Crear nuevo plan',
                backgroundColor: Colors.amber[800],
                child: const Icon(Icons.add, color: Colors.white),
              )
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, List<PlanEntity> plans, bool isAdmin) {
    if (plans.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty ? 'No se encontraron planes.' : 'No hay planes disponibles.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final fullImageUrl = (plan.imagenPrincipalUrl != null && plan.imagenPrincipalUrl!.isNotEmpty)
            ? '${BackendConfig.baseUrl}${plan.imagenPrincipalUrl}'
            : null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<PlanBloc>()),
                      BlocProvider.value(value: _adminPlansBloc),
                    ],
                    child: PlanDetailsPage(plan: plan),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: fullImageUrl != null
                          ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                      )
                          : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.landscape_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.attach_money_rounded, size: 16, color: Colors.amber[800]),
                            const SizedBox(width: 4),
                            Text('S/ ${plan.precioTotal?.toStringAsFixed(2) ?? 'N/A'}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.amber[800]),
                            const SizedBox(width: 4),
                            Text('${plan.duracionDias} día${plan.duracionDias > 1 ? 's' : ''}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.groups_rounded, size: 16, color: Colors.amber[800]),
                            const SizedBox(width: 4),
                            Text('${plan.capacidad} pers.'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: plan.estado == 'activo' ? Colors.amber.shade100 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                plan.estado == 'activo' ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  color: plan.estado == 'activo' ? Colors.amber.shade900 : Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_note_rounded, color: Colors.amber[800]),
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
                              createdAt: plan.createdAt,
                              updatedAt: plan.updatedAt,
                            );
                            _navigateToForm(plan: adminPlan);
                          },
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, plan),
                          tooltip: 'Eliminar',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  
}