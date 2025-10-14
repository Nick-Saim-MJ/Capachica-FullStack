import 'package:equatable/equatable.dart';

class RoleModel extends Equatable {
  final int id;
  final String name;
  final List<String> permissions;

  const RoleModel({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final perms = (json['permissions'] as List?)
        ?.map((e) => e is Map ? (e['name'] ?? e['permission'] ?? '').toString() : e.toString())
        .where((e) => e.isNotEmpty)
        .toList() ??
        const <String>[];
    return RoleModel(
      id: json['id'],
      name: json['name'] ?? '',
      permissions: perms,
    );
  }

  @override
  List<Object?> get props => [id, name, permissions];
}
