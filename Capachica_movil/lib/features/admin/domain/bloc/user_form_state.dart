part of 'user_form_bloc.dart';

abstract class UserFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserFormInitial extends UserFormState {}
class UserFormLoading extends UserFormState {}
class UserFormError extends UserFormState {
  final String message;
  UserFormError(this.message);
  @override
  List<Object?> get props => [message];
}
class UserFormSuccess extends UserFormState {
  final AdminUserModel user;
  UserFormSuccess(this.user);
  @override
  List<Object?> get props => [user];
}
