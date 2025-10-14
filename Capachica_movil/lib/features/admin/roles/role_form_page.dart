import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class RoleFormPage extends StatefulWidget {
  final Map<String, dynamic>? role;
  const RoleFormPage({super.key, this.role});

  @override
  State<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends State<RoleFormPage> {
  late final ApiClient _api;
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  List<dynamic> _allPermissions = [];
  final Set<String> _selectedPerms = {};

  bool _loading = true;
  bool get _isEdit => widget.role != null;

  @override
  void initState() {
    super.initState();
    _api = ApiClient(AppSecureStorage());
    _init();
  }

  Future<void> _init() async {
    if (_isEdit) {
      final r = widget.role!;
      _name.text = r['name'] ?? '';
      final perms = (r['permissions'] as List?)?.map((e) => e['name'].toString()).toList() ?? [];
      _selectedPerms.addAll(perms);
    }
    await _loadPermissions();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadPermissions() async {
    try {
      final res = await _api.get('/permissions');
      if (res.data['success'] == true) {
        _allPermissions = res.data['data'] as List;
      }
    } catch (_) {}
  }

  void _show(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final body = {
      'name': _name.text.trim(),
      'permissions': _selectedPerms.toList(),
    };

    try {
      if (_isEdit) {
        final res = await _api.put('/roles/${widget.role!['id']}', data: body);
        if (res.data['success'] == true) {
          _show('Rol actualizado');
          if (!mounted) return;
          Navigator.pop(context, true);
        } else {
          _show(res.data['message'] ?? 'No se pudo actualizar');
        }
      } else {
        final res = await _api.post('/roles', data: body);
        if (res.data['success'] == true) {
          _show('Rol creado');
          if (!mounted) return;
          Navigator.pop(context, true);
        } else {
          _show(res.data['message'] ?? 'No se pudo crear');
        }
      }
    } catch (e) {
      _show('Error guardando: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar Rol' : 'Nuevo Rol')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre del rol'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 16),
            const Text('Permisos', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allPermissions.map((p) {
                final name = p['name']?.toString() ?? '';
                final sel = _selectedPerms.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: sel,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedPerms.add(name);
                      } else {
                        _selectedPerms.remove(name);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
