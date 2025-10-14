import 'package:flutter/widgets.dart';
import '../storage/secure_storage.dart';


class RoleVisibility extends StatefulWidget {
  final List<String> anyOf;
  final Widget child;
  final Widget? fallback;
  const RoleVisibility({super.key, required this.anyOf, required this.child, this.fallback});


  @override
  State<RoleVisibility> createState() => _RoleVisibilityState();
}


class _RoleVisibilityState extends State<RoleVisibility> {
  final storage = AppSecureStorage();
  List<String> roles = [];


  @override
  void initState() {
    super.initState();
    storage.getRoles().then((r) => mounted ? setState(() => roles = r) : null);
  }


  @override
  Widget build(BuildContext context) {
    final ok = roles.any((r) => widget.anyOf.contains(r));
    if (ok) return widget.child;
    return widget.fallback ?? const SizedBox.shrink();
  }
}