part of 'role_list_bloc.dart';

abstract class RoleListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoleListLoad extends RoleListEvent {}
