import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'role_form_page.dart';

class AdminRolesPage extends StatefulWidget {
  const AdminRolesPage({super.key});

  @override
  State<AdminRolesPage> createState() => _AdminRolesPageState();
}

class _AdminRolesPageState extends State<AdminRolesPage> {
  late final ApiClient _api;

  // Datos
  List<Map<String, dynamic>> _allRoles = [];
  List<Map<String, dynamic>> _visibleRoles = [];
  bool _loading = true;

  // Filtros / orden
  final TextEditingController _qCtrl = TextEditingController();
  String _order = 'name_asc';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _api = ApiClient(AppSecureStorage());
    _load();
    _qCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _qCtrl.removeListener(_onSearchChanged);
    _qCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // =========================
  //  Helper: reintentos GET
  // =========================
  Future<dynamic> _getJsonWithRetry(
      String path, {
        Map<String, dynamic>? queryParameters,
        int retries = 3,
      }) async {
    Object? last;
    for (int i = 0; i < retries; i++) {
      try {
        final res = await _api.get(path, queryParameters: queryParameters);
        return res.data; // ya viene decodificado por Dio
      } catch (e) {
        last = e;
        final msg = e.toString();
        final isFormat = msg.contains('FormatException') || msg.contains('Unexpected end of input');
        // Solo reintenta si es el fallo de parseo/truncado; si no, relanza
        if (!isFormat) rethrow;
        // backoff: 200ms, 400ms, 800ms...
        await Future.delayed(Duration(milliseconds: 200 * (1 << i)));
      }
    }
    throw last ?? Exception('No se pudo obtener $path');
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _getJsonWithRetry('/roles');

      // data puede ser List o Map con data: [...]
      final listDynamic =
      data is List ? data : (data is Map ? (data['data'] as List? ?? <dynamic>[]) : <dynamic>[]);

      final list = listDynamic
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      _allRoles = list;
      _applyFilters();
    } catch (e) {
      _show('Error al cargar roles. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged() {
    // Debounce: espera 300ms tras teclear
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _applyFilters);
  }

  void _applyFilters() {
    final q = _qCtrl.text.trim().toLowerCase();

    // Filtrado local: por nombre de rol y nombre de permisos
    List<Map<String, dynamic>> filtered = _allRoles.where((r) {
      if (q.isEmpty) return true;
      final name = (r['name'] ?? '').toString().toLowerCase();

      final perms = (r['permissions'] as List?)
          ?.map((e) => (e is Map ? (e['name'] ?? '') : e).toString().toLowerCase())
          .toList() ??
          const <String>[];

      return name.contains(q) || perms.any((p) => p.contains(q));
    }).toList();

    // Orden
    filtered.sort((a, b) {
      int permCountA = ((a['permissions'] as List?) ?? const []).length;
      int permCountB = ((b['permissions'] as List?) ?? const []).length;

      switch (_order) {
        case 'name_desc':
          return (b['name'] ?? '').toString().toLowerCase().compareTo(
            (a['name'] ?? '').toString().toLowerCase(),
          );
        case 'perms_desc':
          return permCountB.compareTo(permCountA);
        case 'perms_asc':
          return permCountA.compareTo(permCountB);
        case 'name_asc':
        default:
          return (a['name'] ?? '').toString().toLowerCase().compareTo(
            (b['name'] ?? '').toString().toLowerCase(),
          );
      }
    });

    if (!mounted) return;
    setState(() => _visibleRoles = filtered);
  }

  void _show(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _create() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RoleFormPage()),
    );
    if (ok == true) _load();
  }

  Future<void> _edit(Map<String, dynamic> role) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RoleFormPage(role: role)),
    );
    if (ok == true) _load();
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar rol'),
        content: const Text('¿Desea eliminar este rol?'),
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
      final res = await _api.delete('/roles/$id');
      if (res.data['success'] == true) {
        _show('Rol eliminado');
        _load();
      } else {
        _show(res.data['message'] ?? 'No se pudo eliminar');
      }
    } catch (e) {
      _show('Error eliminando: $e');
    }
  }

  Widget _filters() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Buscador por nombre/permiso (debounced por _qCtrl listener)
            TextField(
              controller: _qCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar rol o permiso',
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.amber.shade800),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.sort, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _order,
                    isDense: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name_asc',  child: Text('Nombre (A → Z)')),
                      DropdownMenuItem(value: 'name_desc', child: Text('Nombre (Z → A)')),
                      DropdownMenuItem(value: 'perms_desc', child: Text('Permisos (más → menos)')),
                      DropdownMenuItem(value: 'perms_asc',  child: Text('Permisos (menos → más)')),
                    ],
                    onChanged: (v) {
                      setState(() => _order = v ?? 'name_asc');
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = _visibleRoles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _filters()),
            if (roles.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Sin resultados')),
              )
            else
              SliverList.separated(
                itemCount: roles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final r = roles[i];
                  final perms = (r['permissions'] as List?)
                      ?.map((e) => (e is Map ? e['name'] : e).toString())
                      .toList() ??
                      const <String>[];
                  final count = perms.length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            r['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: count == 0
                              ? const Text('Sin permisos')
                              : Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: -6,
                                    children: perms
                                        .map((p) => Chip(
                                              label: Text(p),
                                              backgroundColor: Colors.amber.shade800.withOpacity(0.1),
                                              labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
                                            ))
                                        .toList(),
                                  ),
                                ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber.shade800.withOpacity(0.15),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.amber.shade800),
                                onPressed: () => _edit(r),
                                tooltip: 'Editar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _delete(r['id'] as int),
                                tooltip: 'Eliminar',
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
