import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class AdminPermissionsPage extends StatefulWidget {
  const AdminPermissionsPage({super.key});

  @override
  State<AdminPermissionsPage> createState() => _AdminPermissionsPageState();
}

class _AdminPermissionsPageState extends State<AdminPermissionsPage> {
  late final ApiClient _api;

  List<Map<String, dynamic>> _allPerms = [];
  List<Map<String, dynamic>> _visiblePerms = [];
  bool _loading = true;

  final TextEditingController _qCtrl = TextEditingController();
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

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get('/permissions');
      if (res.data['success'] == true) {
        final list = (res.data['data'] as List)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _allPerms = list;
        _applyFilter();
      }
    } catch (e) {
      _show('Error al cargar permisos: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _applyFilter);
  }

  void _applyFilter() {
    final q = _qCtrl.text.trim().toLowerCase();

    final filtered = _allPerms.where((p) {
      if (q.isEmpty) return true;
      final name = (p['name'] ?? '').toString().toLowerCase();
      final id = (p['id'] ?? '').toString();
      return name.contains(q) || id.contains(q);
    }).toList();

    if (mounted) setState(() => _visiblePerms = filtered);
  }

  void _show(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Widget _searchBar() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: _qCtrl,
          decoration: InputDecoration(
            hintText: 'Buscar permiso o ID...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _qCtrl.text.isEmpty
                ? null
                : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _qCtrl.clear();
                _applyFilter();
              },
            ),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onSubmitted: (_) => _applyFilter(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perms = _visiblePerms;

    return Scaffold(
      appBar: AppBar(title: const Text('Permisos del Sistema')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _searchBar()),
            if (perms.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Sin resultados')),
              )
            else
              SliverList.separated(
                itemCount: perms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = perms[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.vpn_key),
                        title: Text(p['name']?.toString() ?? ''),
                        subtitle: Text('ID: ${p['id']}'),
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
