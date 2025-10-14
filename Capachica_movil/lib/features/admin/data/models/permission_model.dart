import 'package:equatable/equatable.dart';

class PermissionModel extends Equatable {
  final int id;
  final String name;

  const PermissionModel({required this.id, required this.name});

  String get group {
    // agrupa por prefijo antes del "_"
    final idx = name.indexOf('_');
    return idx > 0 ? name.substring(0, idx) : name;
  }

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}
