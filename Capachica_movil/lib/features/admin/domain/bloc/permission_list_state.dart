part of 'permission_list_bloc.dart';

abstract class PermissionListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PermissionListInitial extends PermissionListState {}
class PermissionListLoading extends PermissionListState {}
class PermissionListLoaded extends PermissionListState {
  final List<PermissionModel> items;
  PermissionListLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class PermissionListError extends PermissionListState {
  final String message;
  PermissionListError(this.message);
  @override
  List<Object?> get props => [message];
}
