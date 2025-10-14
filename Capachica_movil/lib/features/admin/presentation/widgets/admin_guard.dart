import 'package:flutter/material.dart';
import '../../../../core/storage/secure_storage.dart';

class AdminGuard extends StatefulWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  @override
  State<AdminGuard> createState() => _AdminGuardState();
}

class _AdminGuardState extends State<AdminGuard> {
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final roles = await AppSecureStorage().getRoles();
    final ok = roles.map((e) => e.toLowerCase().trim()).contains('admin');
    if (mounted) setState(() => _isAdmin = ok);
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdmin == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_isAdmin == false) {
      return const Scaffold(
        body: Center(child: Text('No tienes permisos para acceder.')),
      );
    }
    return widget.child;
  }
}
