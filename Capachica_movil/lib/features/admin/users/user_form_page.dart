import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class UserFormPage extends StatefulWidget {
  final Map<String, dynamic>? user; // null = crear
  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  late final ApiClient _api;
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _active = true;

  List<dynamic> _allRoles = [];
  final Set<String> _selectedRoles = {};

  bool _loading = true;
  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _api = ApiClient(AppSecureStorage());
    _init();
  }

  Future<void> _init() async {
    if (_isEdit) {
      final u = widget.user!;
      _name.text = u['name'] ?? '';
      _email.text = u['email'] ?? '';
      _phone.text = u['phone'] ?? '';
      _active = (u['active'] == true);
      final roles = (u['roles'] as List?)?.map((e) => e.toString()).toList() ?? [];
      _selectedRoles.addAll(roles);
    }
    await _loadRoles();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadRoles() async {
    try {
      final res = await _api.get('/roles');
      if (res.data['success'] == true) {
        _allRoles = (res.data['data'] as List).map((e) => e).toList();
      }
    } catch (_) {}
  }

  void _show(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    try {
      if (_isEdit) {
        // update básico
        final body = {
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'active': _active ? 1 : 0,
        };
        final res = await _api.put('/users/${widget.user!['id']}', data: body);
        if (res.data['success'] != true) {
          _show(res.data['message'] ?? 'No se pudo actualizar');
          return;
        }

        // asignar roles
        await _api.post('/users/${widget.user!['id']}/roles', data: {
          'roles': _selectedRoles.toList(),
        });

        _show('Usuario actualizado');
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        // crear
        final body = {
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'password': _password.text.trim(),
          'password_confirmation': _password.text.trim(),
          'phone': _phone.text.trim(),
          'active': _active ? 1 : 0,
          'roles': _selectedRoles.toList(),
        };
        final res = await _api.post('/users', data: body);
        if (res.data['success'] == true) {
          _show('Usuario creado');
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
      appBar: AppBar(title: Text(_isEdit ? 'Editar Usuario' : 'Nuevo Usuario')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
            ),
            const SizedBox(height: 12),
            if (!_isEdit)
              Column(
                children: [
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: const Text('Activo'),
            ),
            const SizedBox(height: 12),
            const Text('Roles', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allRoles.map((r) {
                final name = r['name']?.toString() ?? '';
                final sel = _selectedRoles.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: sel,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedRoles.add(name);
                      } else {
                        _selectedRoles.remove(name);
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
