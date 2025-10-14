part of 'user_list_bloc.dart';

abstract class UserListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserListInitial extends UserListState {}
class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final List<AdminUserModel> items;
  final bool hasMore;
  UserListLoaded({required this.items, required this.hasMore});
  @override
  List<Object?> get props => [items, hasMore];
}

class UserListError extends UserListState {
  final String message;
  UserListError(this.message);
  @override
  List<Object?> get props => [message];
}

class UserListActionError extends UserListState {
  final String message;
  UserListActionError(this.message);
  @override
  List<Object?> get props => [message];
}
