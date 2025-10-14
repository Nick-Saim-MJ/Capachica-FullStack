part of 'role_form_bloc.dart';

abstract class RoleFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleFormInitial extends RoleFormState {}
class RoleFormLoading extends RoleFormState {}
class RoleFormError extends RoleFormState {
  final String message;
  RoleFormError(this.message);
  @override
  List<Object?> get props => [message];
}
class RoleFormSuccess extends RoleFormState {
  final RoleModel role;
  RoleFormSuccess(this.role);
  @override
  List<Object?> get props => [role];
}
