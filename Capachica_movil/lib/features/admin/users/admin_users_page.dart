import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'user_form_page.dart';
import '../permissions/admin_user_permissions_page.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late final ApiClient _api;

  // data
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _roles = [];

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String? _roleNameById(int id) {
    try {
      final r = _roles.firstWhere(
            (e) => _asInt(e['id']) == id,
        orElse: () => {},
      );
      final n = r['name'];
      return n == null ? null : n.toString();
    } catch (_) {
      return null;
    }
  }

  // ui
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _status = 'Todos'; // Todos | Activo | Inactivo
  int? _roleId;            // null => Todos

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
      // await _loadRoles(); // opcional; /users nos da available_roles
      await _loadUsers();
    } catch (e) {
      _show('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


// 2) Helper: valida si el usuario tiene el rol (por id o nombre)
  bool _userHasRole(Map<String, dynamic> u, int roleId) {
    final roleName = _roleNameById(roleId);

    final rolesInfo = u['roles_info'];
    if (rolesInfo is List) {
      final anyId   = rolesInfo.any((e) => e is Map && _asInt(e['id']) == roleId);
      if (anyId) return true;
      if (roleName != null) {
        final anyName = rolesInfo.any((e) =>
        e is Map &&
            (e['name']?.toString().toLowerCase() ?? '') ==
                roleName.toLowerCase());
        if (anyName) return true;
      }
    }

    final roles = u['roles'];
    if (roles is List && roleName != null) {
      final anyName =
      roles.any((e) => e.toString().toLowerCase() == roleName.toLowerCase());
      if (anyName) return true;
    }
    return false;
  }
  // 3) Helper: aplica Filtro local sobre la lista completa
  List<Map<String, dynamic>> _applyLocalFilters(List<Map<String, dynamic>> rows) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return rows.where((u) {
      // Buscar (nombre o email)
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final matchSearch = q.isEmpty || name.contains(q) || email.contains(q);

      // Estado
      final isActive = (u['active'] == true);
      final matchStatus = (_status == 'Todos') ||
          (_status == 'Activo' && isActive) ||
          (_status == 'Inactivo' && !isActive);

      // Rol
      final matchRole = (_roleId == null) || _userHasRole(u, _roleId!);

      return matchSearch && matchStatus && matchRole;
    }).map((e) => Map<String, dynamic>.from(e)).toList();
  }


  Future<void> _loadRoles() async {
    try {
      final res = await _api.get('/roles');
      List<Map<String, dynamic>> newRoles = [];
      if (res.data['success'] == true) {
        final data = res.data['data'];
        final list = data is List ? data : (data['data'] as List? ?? []);
        newRoles = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      setState(() {
        _roles = newRoles;
        // si el rol seleccionado ya no existe, resetea
        if (_roleId != null &&
            !_roles.any((r) => _asInt(r['id']) == _roleId)) {
          _roleId = null;
        }
      });
    } catch (_) {
      setState(() {
        _roles = [];
        _roleId = null;
      });
    }
  }

  // Lógica de filtrado: Totalmente correcta. Solo necesita ser llamada
  // cuando los parámetros (_searchCtrl.text, _status, _roleId) cambian.
// 4) Reemplaza tu _loadUsers por este:
  Future<void> _loadUsers() async {
    if (!mounted) return;

    final q = _searchCtrl.text.trim();
    final params = <String, dynamic>{};

    if (q.isNotEmpty) {
      params['q'] = q;
      params['search'] = q; // compatibilidad
    }
    if (_status != 'Todos') {
      params['active'] = _status == 'Activo' ? '1' : '0';
    }

    // 👉 si hay rol elegido, traducir ID -> nombre y ENVIAR NOMBRE
    if (_roleId != null) {
      final roleName = _roleNameById(_roleId!);
      if (roleName != null && roleName.isNotEmpty) {
        params['role'] = roleName;       // <- esta es la clave que tu API entiende
        params['role_name'] = roleName;  // <- por compatibilidad
      }
    }

    try {
      final res = await _api.get('/users', queryParameters: params.isEmpty ? null : params);
      if (!mounted) return;

      if (res.data['success'] == true) {
        // Actualiza opciones de roles desde available_roles si viene
        final avail = res.data['available_roles'];
        if (avail is List) {
          final newRoles = avail.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
          setState(() {
            _roles = newRoles;
            // si el rol escogido ya no existe en la lista, resetea
            if (_roleId != null && !_roles.any((r) => _asInt(r['id']) == _roleId)) {
              _roleId = null;
            }
          });
        }

        // Usuarios
        final data = res.data['data'];
        final List<dynamic> raw =
        (data is Map && data.containsKey('data')) ? (data['data'] as List) : (data as List);

        final all = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        // Aplica filtro local por si el backend no filtró algo
        final filtered = _applyLocalFilters(all);

        setState(() => _users = filtered);
      } else {
        setState(() => _users = []);
        _show(res.data['message']?.toString() ?? 'No se pudo cargar usuarios');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _users = []);
      _show('Error al cargar usuarios: $e');
    }
  }


  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _create() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const UserFormPage()),
    );
    if (ok == true) _load();
  }

  Future<void> _edit(Map<String, dynamic> user) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => UserFormPage(user: user)),
    );
    if (ok == true) _load();
  }

  Future<void> _openPermissions(Map<String, dynamic> user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminUserPermissionsPage(user: user)),
    );
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('¿Desea eliminar este usuario?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await _api.delete('/users/$id');
      if (res.data['success'] == true) {
        _show('Usuario eliminado');
        _load();
      } else {
        _show(res.data['message']?.toString() ?? 'No se pudo eliminar');
      }
    } catch (e) {
      _show('Error eliminando: $e');
    }
  }

  String _rolesToString(Map<String, dynamic> u) {
    final rolesRaw = u['roles'];
    if (rolesRaw is List && rolesRaw.isNotEmpty) {
      return rolesRaw.map((e) => e.toString()).join(', ');
    }
    final rolesInfo = u['roles_info'];
    if (rolesInfo is List && rolesInfo.isNotEmpty) {
      final names = rolesInfo
          .map((e) => (e is Map && e['name'] != null) ? e['name'].toString() : null)
          .whereType<String>()
          .toList();
      return names.join(', ');
    }
    return '';
  }

  // ---------- UI: Filtros (Buscador y Botones) ----------

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          // 1. Buscador (como en la imagen)
          Container(
            height: 48,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar (nombre o email)',
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.amber[800]),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                isDense: true,
              ),
              onChanged: (_) => _loadUsers(),
              // *** RECARGA INMEDIATA AQUÍ ***
            ),
          ),

          // 2. Botones de filtro de Estado y Rol
          Row(
            children: [
              // Dropdown de Estado (filtrado inmediato)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _status,
                      isExpanded: true,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Estado: Todos')),
                        DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                        DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                      ],
                      onChanged: (v) {
                        setState(() => _status = v ?? 'Todos');
                        // *** FILTRADO INMEDIATO AL CAMBIAR EL ESTADO ***
                        _loadUsers();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Dropdown de Rol (filtrado inmediato)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _roleId,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Rol: Todos')),
                        ..._roles.map((r) => DropdownMenuItem<int?>(
                          value: _asInt(r['id']),
                          child: Text((r['name'] ?? '').toString()),
                        )),
                      ],
                      onChanged: (v) {
                        setState(() => _roleId = v);
                        _loadUsers(); // recarga con el nombre del rol
                      },
                    ),
                  ),
                ),
              ),

              // *** BOTÓN 'FILTRAR' ELIMINADO PARA FORZAR EL FILTRADO INMEDIATO/ON SUBMITTED ***
            ],
          ),
          const SizedBox(height: 8), // Espacio al final de los filtros
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ---------- UI: Build (Ajustado para eliminar el botón "Filtrar") ----------
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo'),
        backgroundColor: Colors.amber[800],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // Filtros (Buscador + Botones)
            SliverToBoxAdapter(child: _filters()),

            // Contenido
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_users.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(child: Text(_searchCtrl.text.isEmpty ? 'Sin usuarios' : 'No se encontraron resultados')),
                ),
              )
            else
              SliverList.separated(
                itemCount: _users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final u = _users[i];
                  final name = (u['name'] ?? '').toString();
                  final email = (u['email'] ?? '').toString();
                  final roles = _rolesToString(u);
                  final active = (u['active'] == true) ? 'Activo' : 'Inactivo';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber[800]!.withOpacity(0.15),
                            child: Text(initial, style: const TextStyle(color: Colors.black)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email),
                              if (roles.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: -6,
                                    children: roles
                                        .split(',')
                                        .map((r) => Chip(
                                              label: Text(r.trim()),
                                              backgroundColor: Colors.amber[800]!.withOpacity(0.1),
                                              labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      active == 'Activo' ? Icons.check_circle : Icons.cancel,
                                      size: 16,
                                      color: active == 'Activo' ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    Text('Estado: $active'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: -10,
                            children: [
                              IconButton(
                                tooltip: 'Permisos',
                                icon: Icon(Icons.vpn_key_outlined, color: Colors.amber[800]),
                                onPressed: () => _openPermissions(u),
                              ),
                              IconButton(
                                tooltip: 'Editar',
                                icon: Icon(Icons.edit, color: Colors.amber[800]),
                                onPressed: () => _edit(u),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _delete(u['id'] as int),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}