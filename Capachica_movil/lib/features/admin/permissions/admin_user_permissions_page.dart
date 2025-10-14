import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class AdminUserPermissionsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminUserPermissionsPage({super.key, required this.user});

  @override
  State<AdminUserPermissionsPage> createState() => _AdminUserPermissionsPageState();
}

class _AdminUserPermissionsPageState extends State<AdminUserPermissionsPage> {
  late final ApiClient _api;

  bool _loading = true;
  List<String> _allPermissions = [];
  Set<String> _selected = {}; // permisos directos asignados al usuario
  List<String> _viaRoles = []; // informativo

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _api = ApiClient(AppSecureStorage());
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await _api.get('/permissions');
      if (all.data['success'] == true) {
        final list = all.data['data'] as List;
        _allPermissions = list
            .map((e) => (e['name'] ?? '').toString())
            .where((e) => e.isNotEmpty)
            .toList()
          ..sort();
      }

      final userId = widget.user['id'];
      final up = await _api.get('/users/$userId/permissions');
      if (up.data['success'] == true) {
        final data = up.data['data'];
        final direct = (data['direct_permissions'] as List).map((e) => e.toString()).toList();
        final via = (data['permissions_via_roles'] as List).map((e) => e.toString()).toList();
        _selected = {...direct};
        _viaRoles = via;
      }
    } catch (e) {
      _toast('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      // Asegura que todos los permisos sean strings válidos
      final perms = _selected.where((p) => p.trim().isNotEmpty).toList();

      final body = {
        'user_id': widget.user['id'],
        if (perms.isNotEmpty) 'permissions': perms,
      };

      final res = await _api.post('/permissions/assign-to-user', data: body);

      if (res.statusCode == 200 && res.data['success'] == true) {
        _toast('✅ Permisos actualizados correctamente');
        Navigator.pop(context, true);
      } else if (res.statusCode == 422) {
        final msg = res.data['errors']?['permissions']?.join(', ') ??
            res.data['message']?.toString() ??
            'Error de validación';
        _toast('⚠️ $msg');
      } else {
        _toast(res.data['message']?.toString() ?? 'No se pudo guardar');
      }
    } catch (e) {
      _toast('❌ Error al guardar: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.user['name'] ?? '').toString();
    final email = (widget.user['email'] ?? '').toString();

    final filtered = _allPermissions.where((p) {
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Permisos de Usuario')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save),
        label: const Text('Guardar'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
            title: Text(name),
            subtitle: Text(email),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              labelText: 'Buscar permiso...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: -8,
            children: filtered.map((perm) {
              final checked = _selected.contains(perm);
              final locked = _viaRoles.contains(perm); // informativo: via rol
              return FilterChip(
                label: Text(perm),
                selected: checked,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selected.add(perm);
                    } else {
                      _selected.remove(perm);
                    }
                  });
                },
                avatar: locked ? const Icon(Icons.lock, size: 16) : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          if (_viaRoles.isNotEmpty) ...[
            const Text('Permisos desde roles (solo lectura):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children: _viaRoles.map((e) => Chip(label: Text(e))).toList(),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
