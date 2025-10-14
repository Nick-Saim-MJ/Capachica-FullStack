part of 'permission_list_bloc.dart';

abstract class PermissionListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PermissionListLoad extends PermissionListEvent {}
