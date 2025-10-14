part of 'user_list_bloc.dart';

abstract class UserListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserListLoad extends UserListEvent {
  final String? search;
  final String? estado; // 'activo' | 'inactivo'
  final String? rol;
  final bool reset;
  UserListLoad({this.search, this.estado, this.rol, this.reset = false});
}

class UserListRefresh extends UserListEvent {
  final String? search;
  final String? estado;
  final String? rol;
  UserListRefresh({this.search, this.estado, this.rol});
}

class UserActivate extends UserListEvent {
  final int id;
  final String? search, estado, rol;
  UserActivate(this.id, {this.search, this.estado, this.rol});
}

class UserDeactivate extends UserListEvent {
  final int id;
  final String? search, estado, rol;
  UserDeactivate(this.id, {this.search, this.estado, this.rol});
}

class UserDelete extends UserListEvent {
  final int id;
  final String? search, estado, rol;
  UserDelete(this.id, {this.search, this.estado, this.rol});
}

class UserAssignRoles extends UserListEvent {
  final int id;
  final List<String> roles;
  final String? search, estado, rol;
  UserAssignRoles(this.id, this.roles, {this.search, this.estado, this.rol});
}
