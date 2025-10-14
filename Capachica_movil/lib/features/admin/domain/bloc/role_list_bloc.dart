import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/role_model.dart';
import '../../data/repositories/role_repository.dart';

part 'role_list_event.dart';
part 'role_list_state.dart';

class RoleListBloc extends Bloc<RoleListEvent, RoleListState> {
  final RoleRepository repo;
  RoleListBloc(this.repo) : super(RoleListInitial()) {
    on<RoleListLoad>((event, emit) async {
      emit(RoleListLoading());
      final res = await repo.list();
      res.fold(
            (err) => emit(RoleListError(err)),
            (list) => emit(RoleListLoaded(list)),
      );
    });
  }
}
