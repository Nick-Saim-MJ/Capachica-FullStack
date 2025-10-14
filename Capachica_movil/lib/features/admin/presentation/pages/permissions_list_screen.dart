import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/bloc/permission_list_bloc.dart';
import '../../data/models/permission_model.dart';

class PermissionsListScreen extends StatelessWidget {
  const PermissionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PermissionListBloc, PermissionListState>(
        builder: (context, state) {
          if (state is PermissionListLoading || state is PermissionListInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PermissionListError) {
            return Center(child: Text(state.message));
          }
          final items = (state as PermissionListLoaded).items;
          if (items.isEmpty) return const Center(child: Text('No hay permisos'));

          // Agrupar por "grupo"
          final Map<String, List<PermissionModel>> groups = {};
          for (final p in items) {
            groups.putIfAbsent(p.group, () => []).add(p);
          }
          final keys = groups.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: keys.length,
            itemBuilder: (_, i) {
              final k = keys[i];
              final list = groups[k]!..sort((a,b)=>a.name.compareTo(b.name));
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text(k[0].toUpperCase() + k.substring(1)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: -6,
                        children: [
                          for (final p in list) Chip(label: Text(p.name), visualDensity: VisualDensity.compact),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
