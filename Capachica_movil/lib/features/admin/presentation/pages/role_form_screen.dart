import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/role_model.dart';
import '../../domain/bloc/role_form_bloc.dart';
import '../../domain/bloc/permission_list_bloc.dart';
import '../../data/models/permission_model.dart';

class RoleFormScreen extends StatefulWidget {
  final RoleModel? role; // null => crear
  const RoleFormScreen({super.key, this.role});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final Set<String> _selectedPerms = {};

  bool get _isEditing => widget.role != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _name.text = widget.role!.name;
      _selectedPerms.addAll(widget.role!.permissions);
    }
    // asegurar que permisos estén listados
    final ps = context.read<PermissionListBloc>().state;
    if (ps is! PermissionListLoaded) {
      context.read<PermissionListBloc>().add(PermissionListLoad());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPerms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione al menos un permiso')));
      return;
    }
    final bloc = context.read<RoleFormBloc>();
    if (_isEditing) {
      bloc.add(RoleUpdateRequested(widget.role!.id, _name.text.trim(), _selectedPerms.toList()));
    } else {
      bloc.add(RoleCreateRequested(_name.text.trim(), _selectedPerms.toList()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Rol' : 'Nuevo Rol'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<RoleFormBloc, RoleFormState>(
            listener: (context, state) {
              if (state is RoleFormError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
              }
              if (state is RoleFormSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'Rol actualizado' : 'Rol creado'), backgroundColor: Colors.green));
                Navigator.pop(context, true);
              }
            },
          ),
        ],
        child: BlocBuilder<PermissionListBloc, PermissionListState>(
          builder: (context, pstate) {
            if (pstate is PermissionListLoading || pstate is PermissionListInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (pstate is PermissionListError) {
              return Center(child: Text(pstate.message));
            }
            final items = (pstate as PermissionListLoaded).items;

            // Agrupar por grupo
            final Map<String, List<PermissionModel>> groups = {};
            for (final p in items) {
              groups.putIfAbsent(p.group, () => []).add(p);
            }
            final keys = groups.keys.toList()..sort();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nombre del rol'),
                      validator: (v)=> v==null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    for (final k in keys)
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ExpansionTile(
                          title: Text(k[0].toUpperCase()+k.substring(1)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: -6,
                                children: [
                                  for (final p in groups[k]!..sort((a,b)=>a.name.compareTo(b.name)))
                                    FilterChip(
                                      label: Text(p.name),
                                      selected: _selectedPerms.contains(p.name),
                                      onSelected: (sel){
                                        setState(() {
                                          sel ? _selectedPerms.add(p.name) : _selectedPerms.remove(p.name);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(_isEditing ? 'Actualizar' : 'Crear'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
