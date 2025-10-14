import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/permission_model.dart';
import '../../data/repositories/permission_repository.dart';

part 'permission_list_event.dart';
part 'permission_list_state.dart';

class PermissionListBloc extends Bloc<PermissionListEvent, PermissionListState> {
  final PermissionRepository repo;
  PermissionListBloc(this.repo) : super(PermissionListInitial()) {
    on<PermissionListLoad>((event, emit) async {
      emit(PermissionListLoading());
      final res = await repo.list();
      res.fold(
            (err) => emit(PermissionListError(err)),
            (list) => emit(PermissionListLoaded(list)),
      );
    });
  }
}
