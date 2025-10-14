import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/widgets/evento_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/bloc/user_list_bloc.dart';
import '../../data/repositories/admin_user_repository.dart';
import '../../data/models/admin_user_model.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _searchCtrl = TextEditingController();
  String? _estado; // 'activo' | 'inactivo' | null
  String? _rol;    // nombre del rol
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<UserListBloc>().add(UserListLoad(reset: true));
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final st = context.read<UserListBloc>().state;
    if (st is UserListLoaded &&
        st.hasMore &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent * 0.8) {
      context.read<UserListBloc>().add(UserListLoad(
        search: _searchCtrl.text,
        estado: _estado,
        rol: _rol,
      ));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<UserListBloc>().add(UserListLoad(
      search: _searchCtrl.text,
      estado: _estado,
      rol: _rol,
      reset: true,
    ));
  }

  Future<void> _confirmDelete(AdminUserModel u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Seguro que deseas eliminar a “${u.name}”?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      context.read<UserListBloc>().add(UserDelete(u.id,
          search: _searchCtrl.text, estado: _estado, rol: _rol));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _applyFilters),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a formulario crear usuario (pendiente/tu pantalla)
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _Filters(
              searchCtrl: _searchCtrl,
              estado: _estado,
              rol: _rol,
              onEstado: (v) => setState(() => _estado = v),
              onRol: (v) => setState(() => _rol = v),
              onFilter: _applyFilters,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocConsumer<UserListBloc, UserListState>(
                listener: (context, state) {
                  if (state is UserListActionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is UserListLoading || state is UserListInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is UserListError) {
                    return Center(child: Text(state.message));
                  }
                  final items = (state as UserListLoaded).items;
                  final hasMore = state.hasMore;

                  if (items.isEmpty) {
                    return const Center(child: Text('No hay usuarios'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _applyFilters(),
                    child: ListView.builder(
                      controller: _scroll,
                      itemCount: items.length + (hasMore ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final u = items[i];
                        return _UserTile(
                          user: u,
                          onEdit: () {
                            // Ir a editar usuario
                          },
                          onToggleActive: () {
                            if (u.active) {
                              context.read<UserListBloc>().add(UserDeactivate(u.id,
                                  search: _searchCtrl.text, estado: _estado, rol: _rol));
                            } else {
                              context.read<UserListBloc>().add(UserActivate(u.id,
                                  search: _searchCtrl.text, estado: _estado, rol: _rol));
                            }
                          },
                          onRoles: () async {
                            // Mostrar bottom-sheet para asignar roles (simple demo)
                            final _roles = <String>{...u.roles};
                            final res = await showModalBottomSheet<List<String>>(
                              context: context,
                              isScrollControlled: true,
                              builder: (ctx) {
                                final all = const ['admin','user','emprendedor','moderador']; // opcional: traer desde /roles
                                return SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Asignar Roles', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                        for (final r in all)
                                          CheckboxListTile(
                                            title: Text(r),
                                            value: _roles.contains(r),
                                            onChanged: (v) {
                                              if (v == true) {
                                                _roles.add(r);
                                              } else {
                                                _roles.remove(r);
                                              }
                                              (ctx as Element).markNeedsBuild();
                                            },
                                          ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.pop(ctx),
                                                child: const Text('Cancelar'),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.pop(ctx, _roles.toList()),
                                                child: const Text('Guardar'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            if (res != null) {
                              context.read<UserListBloc>().add(UserAssignRoles(u.id, res,
                                  search: _searchCtrl.text, estado: _estado, rol: _rol));
                            }
                          },
                          onDelete: () => _confirmDelete(u),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String? estado;
  final String? rol;
  final ValueChanged<String?> onEstado;
  final ValueChanged<String?> onRol;
  final VoidCallback onFilter;

  const _Filters({
    required this.searchCtrl,
    required this.estado,
    required this.rol,
    required this.onEstado,
    required this.onRol,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nombre o email',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: estado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    hint: const Text('Todos'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(value: 'activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                    ],
                    onChanged: onEstado,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: rol,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    hint: const Text('Todos'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(value: 'admin', child: Text('admin')),
                      DropdownMenuItem(value: 'user', child: Text('user')),
                      DropdownMenuItem(value: 'emprendedor', child: Text('emprendedor')),
                      DropdownMenuItem(value: 'moderador', child: Text('moderador')),
                    ],
                    onChanged: onRol,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onFilter,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Filtrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final VoidCallback? onRoles;
  final VoidCallback? onDelete;

  const _UserTile({
    required this.user,
    this.onEdit,
    this.onToggleActive,
    this.onRoles,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final initials = user.name.isNotEmpty ? user.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase() : '?';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text(initials)),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                for (final r in user.roles) Chip(label: Text(r), visualDensity: VisualDensity.compact),
                Chip(
                  label: Text(user.active ? 'Activo' : 'Inactivo'),
                  backgroundColor: user.active ? Colors.green[100] : Colors.red[100],
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 160,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: const Icon(Icons.block), tooltip: user.active ? 'Desactivar' : 'Activar', onPressed: onToggleActive),
              IconButton(icon: const Icon(Icons.edit), tooltip: 'Editar', onPressed: onEdit),
              IconButton(icon: const Icon(Icons.vpn_key), tooltip: 'Roles', onPressed: onRoles),
              IconButton(icon: const Icon(Icons.delete), tooltip: 'Eliminar', onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
