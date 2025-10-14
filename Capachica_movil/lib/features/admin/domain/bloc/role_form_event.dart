part of 'role_form_bloc.dart';

abstract class RoleFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleCreateRequested extends RoleFormEvent {
  final String name;
  final List<String> permissions;
  RoleCreateRequested(this.name, this.permissions);
}

class RoleUpdateRequested extends RoleFormEvent {
  final int id;
  final String name;
  final List<String> permissions;
  RoleUpdateRequested(this.id, this.name, this.permissions);
}
