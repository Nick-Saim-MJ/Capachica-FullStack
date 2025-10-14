import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_plan_form_page.dart';
import '../../data/models/admin_plan_model.dart';
import '../bloc/admin_plans_bloc.dart';
import '../bloc/admin_plans_event.dart';
import '../bloc/admin_plans_state.dart';

class AdminPlansListPage extends StatefulWidget {
  const AdminPlansListPage({super.key});

  @override
  State<AdminPlansListPage> createState() => _AdminPlansListPageState();
}

class _AdminPlansListPageState extends State<AdminPlansListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<AdminPlanModel> _filteredPlans = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    context.read<AdminPlansBloc>().add(LoadAdminPlans());

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToForm({AdminPlanModel? plan}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminPlansBloc>(),
          child: AdminPlanFormPage(initialPlan: plan),
        ),
      ),
    ).then((result) {
      if (result == true) {
        context.read<AdminPlansBloc>().add(LoadAdminPlans());
      }
    });
  }

  // >>> MÉTODO _deletePlan COMPLETADO <<<
  void _deletePlan(AdminPlanModel plan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el plan "${plan.title}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
              onPressed: () {
                context.read<AdminPlansBloc>().add(DeletePlan(plan.id!));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Planes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminPlansBloc>().add(LoadAdminPlans());
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminPlansBloc, AdminPlansState>(
        // >>> LISTENER COMPLETADO <<<
        listener: (context, state) {
          if (state is AdminPlanOperationSuccess) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            // Después de una operación exitosa (Crear, Actualizar, Borrar),
            // volvemos a cargar la lista para ver los cambios.
            context.read<AdminPlansBloc>().add(LoadAdminPlans());
          } else if (state is AdminPlansError) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is AdminPlansLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminPlansLoaded) {
            List<AdminPlanModel> currentPlans = state.plans;

            if (_searchTerm.isNotEmpty) {
              _filteredPlans = currentPlans.where((plan) {
                return plan.title.toLowerCase().contains(_searchTerm.toLowerCase());
              }).toList();
            } else {
              _filteredPlans = List.from(currentPlans);
            }

            _filteredPlans.sort((a, b) {
              if (a.updatedAt == null || b.updatedAt == null) return 0;
              return b.updatedAt!.compareTo(a.updatedAt!);
            });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar plan por nombre...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredPlans.isEmpty
                      ? Center(
                    child: Text(
                      _searchTerm.isNotEmpty
                          ? 'No se encontraron planes con ese nombre.'
                          : "No hay planes creados.\n¡Añade uno nuevo con el botón '+'!",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // Espacio para el FAB
                    itemCount: _filteredPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _filteredPlans[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: (plan.imagenPrincipalUrl != null && plan.imagenPrincipalUrl!.isNotEmpty)
                                ? NetworkImage(plan.imagenPrincipalUrl!)
                                : null,
                            child: (plan.imagenPrincipalUrl == null || plan.imagenPrincipalUrl!.isEmpty)
                                ? const Icon(Icons.image_outlined, color: Colors.white)
                                : null,
                          ),
                          title: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.attach_money_rounded, size: 16, color: Colors.green.shade800),
                                  const SizedBox(width: 4),
                                  Text('S/ ${plan.price.toStringAsFixed(2)}'),
                                  const SizedBox(width: 12),
                                  Icon(Icons.calendar_today_rounded, size: 14, color: Colors.blue.shade800),
                                  const SizedBox(width: 4),
                                  Text('${plan.duration} día${plan.duration > 1 ? 's' : ''}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.groups_rounded, size: 16, color: Colors.orange.shade800),
                                  const SizedBox(width: 4),
                                  Text('${plan.capacidad} pers.'),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: plan.isActive ? Colors.green.shade100 : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      plan.isActive ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        color: plan.isActive ? Colors.green.shade900 : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                                onPressed: () => _navigateToForm(plan: plan),
                                tooltip: 'Editar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                                onPressed: () => _deletePlan(plan),
                                tooltip: 'Eliminar',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          if (state is AdminPlansError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No se pudieron cargar los planes.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Añadir Plan',
        child: const Icon(Icons.add),
      ),
    );
  }
}