import 'package:flutter/material.dart';
import '../../../core/storage/secure_storage.dart';

class AdminGuard extends StatefulWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  final _storage = AppSecureStorage();
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final roles = await _storage.getRoles();
    if (!mounted) return;
    setState(() {
      _isAdmin = roles.map((e) => e.toLowerCase()).contains('admin');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdmin == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isAdmin == false) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso restringido')),
        body: const Center(child: Text('Esta sección es solo para administradores.')),
      );
    }
    return widget.child;
  }
}
