import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/bloc/role_list_bloc.dart';
import '../../data/models/role_model.dart';

class RolesListScreen extends StatelessWidget {
  const RolesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<RoleListBloc, RoleListState>(
        builder: (context, state) {
          if (state is RoleListLoading || state is RoleListInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RoleListError) {
            return Center(child: Text(state.message));
          }
          final items = (state as RoleListLoaded).items;
          if (items.isEmpty) {
            return const Center(child: Text('No hay roles'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) => _RoleCard(role: items[i]),
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final RoleModel role;
  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: -6,
              children: [
                for (final p in role.permissions.take(8))
                  Chip(label: Text(p), visualDensity: VisualDensity.compact),
                if (role.permissions.length > 8)
                  Text('+${role.permissions.length - 8} más', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
