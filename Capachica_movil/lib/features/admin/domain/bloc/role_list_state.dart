part of 'role_list_bloc.dart';

abstract class RoleListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleListInitial extends RoleListState {}
class RoleListLoading extends RoleListState {}
class RoleListLoaded extends RoleListState {
  final List<RoleModel> items;
  RoleListLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class RoleListError extends RoleListState {
  final String message;
  RoleListError(this.message);
  @override
  List<Object?> get props => [message];
}
